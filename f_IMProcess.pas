{
   File: f_IMProcess

   Project:  RoYa
   Status:   Version 4.0
   Date:     2008-09-04
   Author:   Ali Mashatan

   License:
     GNU Public License ( GPL3 ) [http://www.gnu.org/licenses/gpl-3.0.txt]
     Copyrigth (c) Mashatan Software 2002-2008

   Contact Details:
     If you use RoYa I would like to hear from you: please email me
     your comments - good and bad.
     E-mail:  ali.mashatan@gmail.com
     website: https://github.com/Mashatan

   Change History:
   Date         Author       Description
}
unit f_IMProcess;
interface
{$I RoYa.inc}
uses Contnrs,Classes,f_IMScript,f_IMPythonScript,f_IMCommon,f_IMConsts,f_IMBroadcast,f_IMContactInfo,f_IMBuffer,f_IMTransmitPacket,f_IMWebService;
type
  TResultCommand=(rcNormal,rcSend,rcIgnore);
  TIMProcess = class (TThread)
    private
      fWebSrvBuffer:TIMBuffer;
      {$Ifdef ryPlugin}
      fPlugin:THandle;
      fPluginStatus:TPluginStatus;
      {$endif}
      fStartUPTime:TDateTime;
      fIsSuspend:Boolean;
      fInputBuffer:TIMBuffer;
      {$Ifdef ryAlice}
      fAIBuffer:TIMBuffer;
      {$endif}
      {$Ifdef ryScript}
      fScript:TIMScript;
      {$endif}
      fBroadcast:IMBroadcast;
      {$Ifdef ryPlugin}
      Procedure PluginProcess(TransmitPacket:TIMTransmitPacket);
      Procedure PluginInit;
      Procedure PluginFinal;
      {$endif}
      Function  GeneralCommand(pTransmitPacket:TIMTransmitPacket):TResultCommand;
      Function  CombineMessage(pMessage:TStringList;pIndex:Byte):String;
      Procedure CmdDate(pContactInfo:TIMContactInfo);
      Procedure CmdTime(pContactInfo:TIMContactInfo);
      {$Ifdef ryPlugin}
      Procedure CmdPlugin(pContactInfo:TIMContactInfo);
      {$endif}
      Procedure CmdUpTime(pContactInfo:TIMContactInfo);
      Procedure CmdSuspend(pContactInfo:TIMContactInfo);
      Procedure CmdResume(pContactInfo:TIMContactInfo);
      Procedure CmdStatus(pContactInfo:TIMContactInfo);
      Procedure CmdSend(pContactInfo:TIMContactInfo);
    protected
      Procedure Execute; override;
    public
      Constructor Create(pInputBuffer{$ifdef ryAlice},pAIBuffer{$endif},pWebSrvBuffer:TIMBuffer);
      Destructor  Destroy;override;
  end;
implementation
uses Windows,SysUtils,DateUtils,f_RoYaDefines,GpTimezone,PersianDate;
{$Ifdef ryPlugin}
type
  TdPluginProcess = Procedure (pContactInfo:TRoYaVariables) StdCall ;
  TdInitialization = procedure(pPath:String) StdCall;
  TdFinalization = procedure StdCall;
var
  dPluginProcess  : TdPluginProcess;
  dPluginInitialization : TdInitialization;
  dPluginFinalization   : TdFinalization;
{$endif}

constructor TIMProcess.Create(pInputBuffer{$ifdef ryAlice},pAIBuffer{$endif},pWebSrvBuffer:TIMBuffer);
begin
  inherited Create(false);
  FreeOnTerminate:=true;
  fIsSuspend:=false;
  fWebSrvBuffer:=pWebSrvBuffer;
  {$Ifdef ryScript}
  fScript:=TIMPythonScript.Create;
  {$endif}
  fInputBuffer:=pInputBuffer;
  {$ifdef ryAlice}
  fAIBuffer:=pAIBuffer;
  {$endif}
  {$Ifdef ryPlugin}
  fPluginStatus:=psNotReady;
  dPluginProcess :=nil;
  dPluginInitialization:=nil;
  dPluginFinalization:=nil;
  try
    fPlugin:=LoadLibrary(Pchar(CurrentPath+'/plugin/plugin.dll'));
    if fPlugin<> 0 then begin
       dPluginProcess :=GetProcAddress(fPlugin,'Process');
       dPluginInitialization:=GetProcAddress(fPlugin,'Initial');
       dPluginFinalization:=GetProcAddress(fPlugin,'Final');
    end;
  except
    _Logger.Add('Error in loading Plugin !',lsError);
    if fPlugin<>0 then
      FreeLibrary(fPlugin);
  end;
  {$endif}
end;

destructor TIMProcess.Destroy;
begin
  {$Ifdef ryScript}
  fScript.Free;
  {$endif}
  {$Ifdef ryPlugin}
  if fPlugin<> 0 then begin
    dPluginProcess :=nil;
    dPluginInitialization:=nil;
    dPluginFinalization:=nil;
    FreeLibrary(fPlugin);
    fPlugin:=0;
  end;
  {$endif}
  inherited ;
end;

procedure TIMProcess.Execute;
var
  vTransmitPacket:TIMTransmitPacket;
  vContactInfo:TIMContactInfo;
  vOutputBuffer:TIMBuffer;
  vRsultCommand:TResultCommand;
begin
  {$Ifdef ryPlugin}
  PluginInit();
  {$endif}
  while not self.Terminated do begin
    Sleep(1);
    if fInputBuffer.Count>0 then begin
      vTransmitPacket:=fInputBuffer.POP;
      vContactInfo:=vTransmitPacket.ContactInfo;
      vOutputBuffer:=(vTransmitPacket.Buffer as TIMBuffer);
      case vContactInfo.Transport of
        trInner: begin
          vOutputBuffer.Push(vTransmitPacket);
        end;
        trOuter: begin
          vRsultCommand:=GeneralCommand(vTransmitPacket);
          case vRsultCommand of
            rcNormal:
            begin
              if not fIsSuspend then begin
                {$Ifdef ryScript}
                fScript.Process(vTransmitPacket);
                {$endif}
                {$Ifdef ryPlugin}
                PluginProcess(vTransmitPacket);
                {$else}
                vTransmitPacket.ContactInfo.Out_IsAlice:=True;
                {$endif}
              end;
              {$Ifdef ryAlice}
              if (vTransmitPacket.ContactInfo.Out_IsAlice) and (not fIsSuspend) then begin
                fAIBuffer.Push(vTransmitPacket);
              end else
              {$endif}
                vOutputBuffer.Push(vTransmitPacket);
            end;
            rcSend:
              vOutputBuffer.Push(vTransmitPacket);
          end;// Result Command
        end;//Outer
      end;//Case
    end;// If
  end;//While
  {$Ifdef ryPlugin}
  PluginFinal();
  {$endif}
end;

function TIMProcess.GeneralCommand(pTransmitPacket:TIMTransmitPacket):TResultCommand;
var
  vCmd:String;
  vContactInfo:TIMContactInfo;
begin
  Result:=rcNormal;
  vContactInfo:=pTransmitPacket.ContactInfo;
  if vContactInfo.In_ListParam.Count=0 then
    exit;
  vCmd:=Lowercase(vContactInfo.In_ListParam[0]);
  // ******** Public Command *****************
  if not fIsSuspend then begin
    if vCmd=CMD_DATE then begin
      Self.CmdDate(vContactInfo);
      Result:=rcSend;
    end;

  if vCmd=CMD_WEBSERVICE then begin
     fWebSrvBuffer.Push(pTransmitPacket);
     Result:=rcIgnore;
  end;

    if vCmd=CMD_TIME then begin
      Self.CmdTime(vContactInfo);
      Result:=rcSend;
    end;
  end; // Suspend
  // *****************************************

  // ******* Admin Command *******************
  if not  (rsOwner in vContactInfo.In_RoYaState  ) then
    exit;

  if vCmd=CMD_BROADCAST then begin
    if vContactInfo.In_ListParam.Count>1 then begin
      fBroadcast:=IMBroadcast.Create(TIMBuffer(pTransmitPacket.Buffer),vContactInfo.In_Provider,vContactInfo.In_RobotID,vContactInfo.In_Owner,CombineMessage(vContactInfo.In_ListParam,1));
    end;
    Result:=rcSend;
  end;

  if vCmd=CMD_UPTIME then begin
   CmdUpTime(vContactInfo);
   Result:=rcSend;
  end;

  if vCmd=CMD_SUSPEND then begin
   CmdSuspend(vContactInfo);
   Result:=rcSend;
  end;

  if vCmd=CMD_RESUME then begin
   CmdResume(vContactInfo);
   Result:=rcSend;
  end;

  if vCmd=CMD_SEND then begin
    CmdSend(vContactInfo);
    Result:=rcSend;
  end;

  if vCmd=CMD_STATUS then begin
    CmdStatus(vContactInfo);
    Result:=rcSend;
 end;
  {$Ifdef ryPlugin}
  if vCmd=CMD_PLUGIN then begin
    CmdPlugin(vContactInfo);
    Result:=rcSend;
  end;
  {$endif}
end;

{$Ifdef ryPlugin}
procedure TIMProcess.PluginInit;
begin
  fPluginStatus:=psNotReady;
  if (fPlugin<=0) or (@dPluginInitialization=nil) then
    exit;
  try
    dPluginInitialization(CurrentPath);
  Except
    exit;
  end;
  fPluginStatus:=psReady;
  fStartUPTime:=now;
end;

procedure TIMProcess.PluginFinal;
begin
  if (fPlugin<=0) or (@dPluginInitialization=nil) then
    exit;
  try
    dPluginFinalization;
  except
  end;
  fPluginStatus:=psNotReady;
end;

procedure TIMProcess.PluginProcess(TransmitPacket:TIMTransmitPacket);
begin
  if fPluginStatus<>psReady then
    exit;
  try
    dPluginProcess(TransmitPacket.ContactInfo);
  except
   if rsOwner in TransmitPacket.ContactInfo.In_RoYaState then
      TransmitPacket.ContactInfo.Out_InstantMessage.Add('*** An error has occurred in the Plug-in');
  end;
end;
{$endif}

function TIMProcess.CombineMessage(pMessage: TStringList;
  pIndex: Byte): String;
var
  vCont:Integer;
begin
  result:='';
  for vCont:= pIndex to pMessage.Count-1 do
    Result:=Result+pMessage.Strings[vCont]+' ';
  Result:=Trim(Result);
end;

procedure TIMProcess.CmdDate(pContactInfo: TIMContactInfo);
var
  vDateKind,vStrDate:String;
  vDate:TDateTime;
begin
  vDate:=now;
  vStrDate:='';
  vDateKind:='';
  pContactInfo.Out_InstantMessage.Clear;
  if pContactInfo.In_ListParam.Count>1 then
    vDateKind:=Lowercase(pContactInfo.In_ListParam.Strings[1]);
  if pContactInfo.In_ListParam.Count>2 then
    vStrDate:=Lowercase(pContactInfo.In_ListParam.Strings[2]);
  if vDateKind=CMD_GREGORIAN_SOLAR then begin
    if vStrDate<>'' then begin
      try
        vDate:=StrToDate(vStrDate);
      except
        pContactInfo.Out_InstantMessage.Add('Please use the format : '+ShortDateFormat);
      end;
    end;
    pContactInfo.Out_InstantMessage.Add('Solar : '+GetSolarDate(vDate));
  end else
  if (vDateKind=CMD_SOLAR_GREGORIAN) or (vDateKind='') then begin
    if vStrDate<>'' then begin
      try
        vDate:=EncodeToGregorian2(vStrDate);
      except
        pContactInfo.Out_InstantMessage.Add('Please use the format : '+ShortDateFormat);
      end;
    end;
    pContactInfo.Out_InstantMessage.Add('Gregorian : '+DateToStr(vDate));
  end;
end;

procedure TIMProcess.CmdTime(pContactInfo: TIMContactInfo);

  function IsValid(pStr:String):Boolean;
  var
    vCount:Integer;
  begin
    result:=false;
    for vCount:=1 to length(pStr) do begin
      if not (pStr[vCount] in ['0'..'9',':','+','-']) then
         exit;
    end;
    result:=true;
  end;
var
  vStrBias,vStrDate:String;
  vUTC,vTime:TDatetime;
  vBias,vSign,vMajor,vMinor:Integer;
begin
  try
    vUTC:=NowUTC;
    vTime:=now;
    if pContactInfo.In_ListParam.Count>1 then begin
      vStrBias:=pContactInfo.In_ListParam.Strings[1];
      if IsValid(vStrBias) then begin
        vSign:=1;
        if vStrBias[1]='-' then
          vSign:=-1;
        vMajor:= StrToInt(Copy(vStrBias,0,Pos(':',vStrBias)-1));
        vMinor:= StrToInt(Copy(vStrBias,Pos(':',vStrBias)+1,Length(vStrBias)));
        vBias:=((Abs(vMajor)*60)+vMinor) * vSign;
        vTime:=IncMinute(vUTC,vBias);
        DateTimeToString(vStrDate,'yyyy/mm/dd hh:nn:ss',vTime);
        pContactInfo.Out_InstantMessage.Add('Date & Time ('+vStrBias+') : '+vStrDate);
      end else begin
        pContactInfo.Out_InstantMessage.Add('Please use the format : /time [+/-Hour:Minute]');
        pContactInfo.Out_InstantMessage.Add('For example : /Time +03:30 ');
      end;
    end else begin
      DateTimeToString(vStrDate,'yyyy/mm/dd hh:nn:ss',vTime);
      pContactInfo.Out_InstantMessage.Add('Server Time : '+vStrDate);
    end;
  except
    pContactInfo.Out_InstantMessage.Add('What are you doing ?!');
  end;
end;

{$Ifdef ryPlugin}
procedure TIMProcess.CmdPlugin(pContactInfo: TIMContactInfo);
var
  vTmp:String;
begin
  if fPluginStatus=psReady then
    pContactInfo.Out_InstantMessage.Text:='OK , Plugin is ready.'
  else
    pContactInfo.Out_InstantMessage.Text:='OK , plugin is not ready.';
  if pContactInfo.In_ListParam.Count>1 then begin
    vTmp:=Lowercase(pContactInfo.In_ListParam.Strings[1]);
    if vTmp=CMD_PLUGIN_INIT then begin
      PluginInit;
      pContactInfo.Out_InstantMessage.Text:='Ok , plugin is initialized.';
    end;
    if vTmp=CMD_PLUGIN_FINAL then begin
      PluginFinal;
      pContactInfo.Out_InstantMessage.Text:='Ok , plugin is finalized.';
    end;
  end;
end;
{$endif}

procedure TIMProcess.CmdResume(pContactInfo: TIMContactInfo);
begin
   self.fIsSuspend:=false;
   pContactInfo.Out_InstantMessage.Text:='RoYa is resume';
end;

procedure TIMProcess.CmdSend(pContactInfo: TIMContactInfo);
var
  vTmp:String;
begin
  if pContactInfo.In_ListParam.Count>2 then begin
    vTmp:=pContactInfo.In_ListParam.Strings[1];
    pContactInfo.In_UserID:=vTmp;
    pContactInfo.Out_InstantMessage.Text:='<OWENER> '+CombineMessage(pContactInfo.In_ListParam,2);
  end;
end;

procedure TIMProcess.CmdStatus(pContactInfo: TIMContactInfo);
begin
  if pContactInfo.In_ListParam.Count>1 then begin
    pContactInfo.Out_StatusMessage:=CombineMessage(pContactInfo.In_ListParam,1);
    pContactInfo.Out_InstantMessage.Text:='OK , Status changed.';
  end;
end;

procedure TIMProcess.CmdSuspend(pContactInfo: TIMContactInfo);
begin
  self.fIsSuspend:=true;
  pContactInfo.Out_InstantMessage.Text:='RoYa is suspended';
end;

procedure TIMProcess.CmdUpTime(pContactInfo: TIMContactInfo);
var
  vLastDate:TDateTime;
begin
  vLastDate:=now-fStartUPTime;
  pContactInfo.Out_InstantMessage.Text:=FormatDateTime('hh:mm.ss',vLastDate);
end;


end.