{
   File: f_IMYahooProtocol

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
unit f_IMYahooProtocol;
interface
uses windows,f_IMProtocol,f_IMCommon,f_IMConsts,f_IMContactInfo;
{$I RoYa.inc}
{$ifndef CallDLLFromFile}
{$R RoYaEx.res}
{$Endif}
type
  TIMYahooProtocol = class (TIMProtocol)
    private
      Session_ID:String;
      fpassword:String;
      Function    ExtractPacket(pPacket,pPacketType: String): String;
      Function    ExtractPacketHeader(pPacket: String):TYahooPacketHeader;
      function    BulidPacket(pKey,pContent:String):string;
      Function    BulidPacketHeader(pPacket:String;pContactInfo:TIMContactInfo):String;Overload;
      Function    BulidPacketHeader(pPacket:String;pYService:Word):String;Overload;
      Function    ByteAdder(pB1,pB2: Byte): Integer;
      function    Login(pContactInfo:TIMContactInfo):String;
      function    Logout(pContactInfo:TIMContactInfo):String;
      function    PrivateMessage(pContactInfo:TIMContactInfo):String;
      function    AcceptNewFriend(pContactInfo:TIMContactInfo):String;
      function    ChangeStatus(pContactInfo:TIMContactInfo):String;
      procedure   Authentication(pContactInfo:TIMContactInfo);
      procedure   NewFriendAlert(pData:String;pContactInfo:TIMContactInfo);
    public
      constructor Create(pPassword:String);
      destructor  Destroy;override;
      procedure   Initialize(pContactInfo:TIMContactInfo);override;
      procedure   SendMessage(pContactInfo:TIMContactInfo);override;
      procedure   ReceiveMessage(pContactInfo:TIMContactInfo);override;
      Function    Ping(pUsername:String):string;override;

  end;
implementation

uses SysUtils,QStrings,f_RoYaDefines,f_IMYahooContactInfo,f_LoadDLL;

var
  GetEncryptedStrings : Function (Username, Password,ChallangeString: String; ChallangeReply1, ChallangeReply2: pchar;Mode:Integer):Bool; StdCall ;

constructor TIMYahooProtocol.Create(pPassword:String);
begin
  inherited Create();
  fPassword:=pPassword;
end;

destructor TIMYahooProtocol.Destroy;
begin

  inherited;
end;


procedure TIMYahooProtocol.Initialize(pContactInfo:TIMContactInfo);
begin
  inherited;
  Session_ID:=#$89+#$79+#$07+#$B4;
  if Assigned(OnInitialize) then
    OnInitialize(self,pContactInfo);
  _Logger.Add('Connect to Yahoo',lsInformation);
  TIMYahooContactInfo(pContactInfo).ServiceProcessed:=YAHOO_SERVICE_VERIFY;
  TIMYahooContactInfo(pContactInfo).Transport:=trInner;
end;

function  TIMYahooProtocol.Login(pContactInfo:TIMContactInfo):string;
begin

end;

function  TIMYahooProtocol.Logout(pContactInfo:TIMContactInfo):string;
begin
end;

Function TIMYahooProtocol.ByteAdder(pB1,pB2: Byte): Integer;
 Var
  R: integer;
Begin
 R:=(pB1*256)+pB2;
 ByteAdder:=R;
End;


procedure TIMYahooProtocol.Authentication(pContactInfo:TIMContactInfo);
var
  vChallenge,vUsername:String;
  vChallangeReply1,vChallangeReply2:String;
  vChReply1,vChReply2:Pchar;
  Mode:Integer;
  Packet:String;
  vLoadDll:TLoadDll;
begin
{$ifdef CallDLLFromFile}
  vLoadDll:=TLoadDll.Create(Pchar(CurrentPath+'YahooAuth.dll'));
{$else}
  vLoadDll:=TLoadDll.Create('YahooAuth',RT_RCDATA);
{$endif}
  try
    GetEncryptedStrings:=vLoadDll.GetProcAddress('YMSG12_ScriptedMind_Encrypt');
    if @GetEncryptedStrings=nil  then
      exit;
    vUsername:=ExtractPacket(pContactInfo.RAWData,'1');
    vChallenge:=ExtractPacket(pContactInfo.RAWData,'94');
    GetMem(vChReply1,80);
    GetMem(vChReply2,80);
    FillChar(vChReply1^,80,0);
    FillChar(vChReply2^,80,0);
    mode:=1;
    GetEncryptedStrings(Pchar(vUsername),Pchar( fPassword) , Pchar(vChallenge) , vChReply1, vChReply2,mode);
    vChallangeReply1:=vChReply1;
    vChallangeReply2:=vChReply2;
    FreeMem(vChReply1);
    FreeMem(vChReply2);
    vChallangeReply1:=Trim(vChallangeReply1);
    vChallangeReply2:=Trim(vChallangeReply2);
    packet:=BulidPacket('6',vChallangeReply1);
    packet:=packet+BulidPacket('96',vChallangeReply2);
    packet:=packet+BulidPacket('0',vUsername);
    packet:=packet+BulidPacket('2','1');
    packet:=packet+BulidPacket('1',vUsername);
    packet:=packet+BulidPacket('135','5, 6, 0, 1344');
    packet:=packet+BulidPacket('148','-210');
    pContactInfo.ProcessedData:=BulidPacketHeader(packet,pContactInfo);
  finally
    vLoadDll.Free;
  end;
end;

function  TIMYahooProtocol.BulidPacket(pKey,pContent:String):string;
begin
   result:=pKey+YAHOO_CO80S+pContent+YAHOO_CO80S;
end;

Function TIMYahooProtocol.ExtractPacket(pPacket,pPacketType: String): String;
Var
   vWithFormat: String;
   vPosi,vStart,vEnd:Integer;
Begin
  result:='';
  vWithFormat:=pPacketType+YAHOO_CO80S;
  vPosi:=Q_PosStr(vWithFormat,pPacket);
  if vPosi<>0 then begin
    vStart:=vPosi+Length(vWithFormat);
    vEnd:=Q_PosStr(YAHOO_CO80S,pPacket,vStart);
    result:=Q_CopyRange(pPacket,vStart,vEnd-1);
  end;
End;


Function TIMYahooProtocol.BulidPacketHeader(pPacket:String;pContactInfo:TIMContactInfo):String;
var
  vData:String;
begin
  with TIMYahooContactInfo(pContactInfo).PacketHeaderSend do begin
    Length:=system.Length(pPacket);
    YMSG:=YAHOO_SIGNATURE;
    Version:=YAHOO_VERSION;
    Version:=swap(Version);
    Length:=swap(Length);
    Serivce:=swap(Serivce);
    move(self.Session_ID[1],SessionID[1],4);
  end;
  SetLength(vData,sizeof(TYahooPacketHeader));
  move(TIMYahooContactInfo(pContactInfo).PacketHeaderSend.data[1],vData[1],sizeof(TYahooPacketHeader));
  result:=vData+pPacket;
End;

Function  TIMYahooProtocol.BulidPacketHeader(pPacket:String;pYService:Word):String;
var
  vData:String;
  vHeader:TYahooPacketHeader;
begin
  with vHeader do begin
    Length:=system.Length(pPacket);
    YMSG:=YAHOO_SIGNATURE;
    Version:=YAHOO_VERSION;
    Version:=swap(Version);
    Length:=swap(Length);
    Serivce:=swap(pYService);
    move(self.Session_ID[1],SessionID[1],4);
  end;
  SetLength(vData,sizeof(TYahooPacketHeader));
  move(vHeader,vData[1],sizeof(TYahooPacketHeader));
  result:=vData+pPacket;
end;


Function  TIMYahooProtocol.ExtractPacketHeader(pPacket: String):TYahooPacketHeader;
begin
  Move(pPacket[1],result.data[1],sizeof(result));
  result.Version:=swap(result.Version);
  result.Length:=swap(result.Length);
  result.Serivce:=swap(result.Serivce);
end;



procedure   TIMYahooProtocol.SendMessage(pContactInfo:TIMContactInfo);
var
  vPacket:String;
{
   <------- 4B -------><------- 4B -------><---2B--->
    +-------------------+-------------------+---------+
    |   Y   M   S   G   |      version      | pkt_len |
    +---------+---------+---------+---------+---------+
    | service |      status       |    session_id     |
    +---------+-------------------+-------------------+
    |                                                 |
    :                    D A T A                      :
    |                   0 - 65535*                    |
    +-------------------------------------------------+
}


begin
  inherited;
  vPacket:='';
  TIMYahooContactInfo(pContactInfo).PacketHeaderSend.Serivce:=TIMYahooContactInfo(pContactInfo).ServiceProcessed;
  case TIMYahooContactInfo(pContactInfo).ServiceProcessed of
    YAHOO_SERVICE_VERIFY: begin
        Stage:=saVerify;
        pContactInfo.ProcessedData:=BulidPacketHeader(vPacket,pContactInfo);
    end;
    YAHOO_SERVICE_AUTH: begin
      vPacket:=BulidPacket('1',pContactInfo.In_RobotID);
      pContactInfo.ProcessedData:=BulidPacketHeader(vPacket,pContactInfo);
    end;
    YAHOO_SERVICE_AUTHRESP: begin
      Authentication(pContactInfo);
    end;

    YAHOO_SERVICE_MESSAGE:
     begin
       if not pContactInfo.Out_DoNotSend then
        begin
          pContactInfo.ProcessedData:='';
          vPacket:=PrivateMessage(pContactInfo);
          if vPacket<>'' then
            pContactInfo.ProcessedData:=BulidPacketHeader(vPacket,pContactInfo);
          if pContactInfo.Out_StatusMessage<>'' then
           begin
             vPacket:=ChangeStatus(pContactInfo);
             if vPacket<>'' then
              begin
               TIMYahooContactInfo(pContactInfo).PacketHeaderSend.Serivce:=YAHOO_SERVICE_ISAWAY;
               pContactInfo.ProcessedData:=pContactInfo.ProcessedData+BulidPacketHeader(vPacket,pContactInfo);
               pContactInfo.Out_StatusMessage:='';
              end;
           end;
          if (rsNewContact in pContactInfo.In_RoYaState) then
           begin
            _Logger.Add(' Send New Contact',lsInformation);
            vPacket:=AcceptNewFriend(pContactInfo);
            if vPacket <> '' then
             begin
              TIMYahooContactInfo(pContactInfo).PacketHeaderSend.Serivce:=YAHOO_SERVICE_NEWFRIENDALERT;
              pContactInfo.ProcessedData:=pContactInfo.ProcessedData+BulidPacketHeader(vPacket,pContactInfo);
             end;
           end;
       end;
     end;
  end;
end;


procedure  TIMYahooProtocol.ReceiveMessage(pContactInfo:TIMContactInfo);
var
  vRealData,vDataOrginal,vDataSecession:String;
  vContactInfo:TIMYahooContactInfo;
begin
  inherited;
  vDataOrginal:=pContactInfo.RAWData;
  pContactInfo.Transport:=trInner;
  vContactInfo:=TIMYahooContactInfo(pContactInfo);
  While (length(vDataOrginal)>YAHOO_MINIMUMPACKETSIZE)  do Begin
   vContactInfo.PacketHeaderRecesive:=ExtractPacketHeader(vDataOrginal);

   vDataSecession:=copy(vDataOrginal,sizeof(TYahooPacketHeader)+1,vContactInfo.PacketHeaderRecesive.Length);
   if vContactInfo.PacketHeaderRecesive.YMSG<>YAHOO_SIGNATURE then
     exit;
   vRealData:=Copy(vDataOrginal,1,vContactInfo.PacketHeaderRecesive.Length+ sizeof(vContactInfo.PacketHeaderRecesive) );
   case vContactInfo.PacketHeaderRecesive.Serivce of
     YAHOO_SERVICE_VERIFY : begin
       _Logger.Add('Verified Robot ['+pContactInfo.In_RobotID+']',lsInformation);
       if  Assigned(OnVerified) then
         OnVerified(self,pContactInfo);
       vContactInfo.ServiceProcessed:=YAHOO_SERVICE_AUTH;
       end;
     YAHOO_SERVICE_AUTH: begin
       _Logger.Add('Authenticating ...',lsInformation);
       if  Assigned(OnAuthentication) then
         OnAuthentication(self,pContactInfo);
       Stage:=saAuthentication;
       vContactInfo.ServiceProcessed:=YAHOO_SERVICE_AUTHRESP;
       end;

     YAHOO_SERVICE_LIST: begin
       Stage:=saReady;
       if  Assigned(OnLogin) then
         OnLogin(self,pContactInfo);
       _Logger.Add('Welcome Yahoo Messenger! ...',lsInformation);
       vContactInfo.Transport:=trInner;
       vContactInfo.In_UserID:= vContactInfo.In_Owner;

       if vContactInfo.In_Owner=vContactInfo.In_UserID then
         vContactInfo.In_RoYaState:=vContactInfo.In_RoYaState+[rsOwner];
       vContactInfo.Out_InstantMessage.Text:=coWhenStartForOwner;
       vContactInfo.ServiceProcessed:=YAHOO_SERVICE_MESSAGE;
     end;

     YAHOO_SERVICE_NEWFRIENDALERT,YAHOO_SERVICE_NEWCONTACT :
      begin
         vContactInfo.Transport:=trOuter;
         NewFriendAlert(vDataSecession,vContactInfo);
         _Logger.Add('New Contact is Exist',lsInformation);
       end;

     YAHOO_SERVICE_MESSAGE:
      begin
      vContactInfo.Transport:=trOuter;
       vContactInfo.In_UserID:=ExtractPacket(vDataSecession,'4');
       if (vContactInfo.In_Owner=vContactInfo.In_UserID) then
         vContactInfo.In_RoYaState:=vContactInfo.In_RoYaState+[rsOwner];
       vContactInfo.SetRAWInstanstMessage(ExtractPacket(vDataOrginal,'14'));
       vContactInfo.ServiceProcessed:=YAHOO_SERVICE_MESSAGE;
     end;

   end;
   Q_Delete(vDataOrginal,1,vContactInfo.PacketHeaderRecesive.Length+ sizeof(vContactInfo.PacketHeaderRecesive ));
 end;
end;

procedure TIMYahooProtocol.NewFriendAlert(pData:String;pContactInfo:TIMContactInfo);
begin
  pContactInfo.In_UserID:=ExtractPacket(pData,'4');
  TIMYahooContactInfo(pContactInfo).ServiceProcessed:=YAHOO_SERVICE_MESSAGE;
  pContactInfo.In_RoYaState:=pContactInfo.In_RoYaState+[rsNewContact];
end;

function TIMYahooProtocol.AcceptNewFriend(pContactInfo:TIMContactInfo):String;
begin
  result:='';
  result:=BulidPacket('1',pContactInfo.In_RobotID);
  result:=result+BulidPacket('5',pContactInfo.In_UserID);
  result:=result+BulidPacket('13','1');
  result:=result+BulidPacket('334','0');
  pContactInfo.In_RoYaState:= pContactInfo.In_RoYaState-[rsNewContact];
end;

function TIMYahooProtocol.PrivateMessage(pContactInfo:TIMContactInfo):String;
var
  vData,vMsg:String;
Begin
  result:='';
  if pContactInfo.Out_InstantMessage.Count < 1 then
    exit;
  vData:=pContactInfo.Out_InstantMessage[pContactInfo.idx];
  if vData <>'' then begin
    vMsg:='[Robot: ' + pContactInfo.In_RobotID;
    vMsg:=vMsg+'] [User: ' + pContactInfo.In_UserID;
    vMsg:=vMsg+'] [Receive: '+ pContactInfo.In_InstantMessage;
    vMsg:=vMsg+'] [Send:' + pContactInfo.Out_InstantMessage.Text;
    _Logger.Add(vMsg,lsInformation);
    result:=BulidPacket('1',pContactInfo.In_RobotID);
    result:=result+BulidPacket('5',pContactInfo.In_UserID);
    result:=result+BulidPacket('97','1');
    result:=result+BulidPacket('14',vData);
  end;
end;

function TIMYahooProtocol.Ping(pUsername:String):String;
begin
//  inherited;
  result:=BulidPacket('109',pUsername);
  result:=BulidPacketHeader(result,YAHOO_SERVICE_PING);
  _Logger.Add('Ping Yahoo Messenger! ...',lsInformation);
end;

Function  TIMYahooProtocol.ChangeStatus(pContactInfo:TIMContactInfo):String;
const
sts:Array[1..12] of record st:string;flg:integer; end=
(
  (st:'#ava';flg:0),    // Available
  (st:'#brb';flg:1),    // Be Right Back
  (st:'#bsy';flg:2),    // Busy
  (st:'#nah';flg:3),    // Not at Home
  (st:'#nmd';flg:4),    // Not My Desk
  (st:'#nio';flg:5),    // Not in the Office
  (st:'#otp';flg:6),    // On the Phone
  (st:'#ova';flg:7),    // On Vacation
  (st:'#otl';flg:8),    // Out to Lunch
  (st:'#sto';flg:9),    // Stepped Out
  (st:'#inv';flg:12),   // Invisable
  (st:'#idl';flg:999)); // Idle
Var
 vMessage: String;
 vCount,vFlag:Integer;
 ch:Char;
Begin
  vMessage:=pContactInfo.Out_StatusMessage;
  vFlag:=-1;
  if Length (vMessage)=4 then
    for vCount:=1 to 12 do begin
      if pos(sts[vCount].st,vMessage)=1  then begin
        vFlag:=sts[vCount].flg;
        break;
      end;
    End;
  ch:=#$30;
  vCount:=Pos('[busy]',vMessage);
  if vCount<>0 then begin
    delete(vMessage,vCount,6);
    ch:=#$31;
    if vMessage='' then vMessage:='Busy';
  end;
  vCount:=Pos('[idle]',vMessage);
  if vCount<>0 then begin
    delete(vMessage,vCount,6);
    ch:=#$32;
    if vMessage='' then vMessage:='Idle';
  end;
  result:='';
  if vFlag=-1  then begin
    result:= BulidPacket('10','99');
    result:= result+ BulidPacket('19',vMessage);
    result:= result+ BulidPacket('47',ch);
  end else begin
    result:= BulidPacket('10',IntToStr(vFlag));
    result:= result+ BulidPacket('47','1');
  end;
end;
end.
