{
   File: f_IMPythonScript

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
unit f_IMPythonScript;

{$I Definition.Inc}

interface
uses Classes,f_RoYaDefines,f_IMTransmitPacket,f_IMScript,PythonEngine, PythonGUIInputOutput;
Type
  TIMPythonScript=class(TIMScript)
    private
      fContactInfo:TRoYaVariables;
      fScriptContent:TStringList;
      fPythonEngine:TPythonEngine;
      fPythonModule:TPythonModule;

      fUserID:TPythonDelphiVar;
      fHWNDApp:TPythonDelphiVar;
      fRobotID:TPythonDelphiVar;
      fRAWInstantMessage:TPythonDelphiVar;
      fOwner:TPythonDelphiVar;
      fProvider:TPythonDelphiVar;
      fRoYaState:TPythonDelphiVar;

      fTimer:TPythonDelphiVar;
      fIntroduce:TPythonDelphiVar;
      fStatus:TPythonDelphiVar;
      fDoNotSend:TPythonDelphiVar;
      fIsAlice:TPythonDelphiVar;


      procedure doGetUserID(Sender: TObject;var Data: Variant);
      procedure doGetHWNDApp(Sender: TObject;var Data: Variant);
      procedure doGetRobotID(Sender: TObject;var Data: Variant);
      procedure doGetRAWInstantMessage(Sender: TObject;var Data: Variant);
      procedure doGetOwner(Sender: TObject;var Data: Variant);
      procedure doGetProvider(Sender: TObject;var Data: Variant);
      procedure doGetRoYaState(Sender: TObject;var Data: Variant);
      procedure doGetIntroduce(Sender: TObject;var Data: Variant);

      procedure doGetTimer(Sender: TObject;var Data: Variant);
      procedure doSetTimer(Sender: TObject; Data: Variant);


      procedure doGetStatus(Sender: TObject;var Data: Variant);
      procedure doSetStatus(Sender: TObject; Data: Variant);
      procedure doGetDoNotSend(Sender: TObject;var Data: Variant);
      procedure doSetDoNotSend(Sender: TObject; Data: Variant);
      procedure doGetIsAlice(Sender: TObject;var Data: Variant);
      procedure doSetIsAlice(Sender: TObject; Data: Variant);

      procedure doPythonModuleInit(Sender:TObject);

      function RoYa_Add_InstantMessage(pself, args : PPyObject ) : PPyObject; cdecl;
      function RoYa_Get_ListParam(pself, args : PPyObject ) : PPyObject; cdecl;
      function RoYa_Get_ListParamCount(pself, args : PPyObject ) : PPyObject; cdecl;

    protected
      procedure Process(pTransmitPacket:TIMTransmitPacket);override;
    public
      constructor Create();
      destructor  Destroy();override;
  end;

implementation

uses f_IMCommon, f_IMConsts;

{ TIMPythonScript }

constructor TIMPythonScript.Create;
begin
  inherited;
  fContactInfo:=nil;

  try
    fScriptContent:=TStringList.Create;
    fScriptContent.LoadFromFile(CurrentPath+'\Scripts\Script.py');
  except
      _Logger.Add('Error in loading Script !',lsError);
  end;
  fPythonEngine:=TPythonEngine.Create(nil);

  fPythonModule:=TPythonModule.Create(nil);
  fPythonModule.Engine:=fPythonEngine;
  fPythonModule.OnInitialization:=doPythonModuleInit;
  fPythonModule.ModuleName:='RoYa';

  fUserID:=TPythonDelphiVar.Create(nil);
  fHWNDApp:=TPythonDelphiVar.Create(nil);
  fRobotID:=TPythonDelphiVar.Create(nil);
  fRAWInstantMessage:=TPythonDelphiVar.Create(nil);
  fOwner:=TPythonDelphiVar.Create(nil);
  fProvider:=TPythonDelphiVar.Create(nil);
  fRoYaState:=TPythonDelphiVar.Create(nil);
  fTimer:=TPythonDelphiVar.Create(nil);
  fIntroduce:=TPythonDelphiVar.Create(nil);
  fStatus:=TPythonDelphiVar.Create(nil);
  fDoNotSend:=TPythonDelphiVar.Create(nil);
  fIsAlice:=TPythonDelphiVar.Create(nil);

  fUserID.Engine              :=fPythonEngine;
  fHWNDApp.Engine             :=fPythonEngine;
  fRobotID.Engine             :=fPythonEngine;
  fRAWInstantMessage.Engine   :=fPythonEngine;
  fOwner.Engine               :=fPythonEngine;
  fProvider.Engine            :=fPythonEngine;
  fRoYaState.Engine           :=fPythonEngine;
  fTimer.Engine               :=fPythonEngine;
  fIntroduce.Engine          :=fPythonEngine;
  fStatus.Engine              :=fPythonEngine;
  fDoNotSend.Engine           :=fPythonEngine;
  fIsAlice.Engine             :=fPythonEngine;

  fUserID.VarName             :='UserID';
  fHWNDApp.VarName            :='HWNDApp';
  fRobotID.VarName            :='RobotID';
  fRAWInstantMessage.VarName  :='RAWInstantMessage';
  fOwner.VarName              :='Owner';
  fProvider.VarName           :='Provider';
  fRoYaState.VarName          :='RoYaState';
  fTimer.VarName              :='Time';
  fIntroduce.VarName          :='Introduce';
  fStatus.VarName             :='Status';
  fDoNotSend.VarName          :='DoNotSend';
  fIsAlice.VarName            :='IsAlice';

  fUserID.OnGetData           :=doGetUserID;
  fHWNDApp.OnGetData          :=doGetHWNDApp;
  fRobotID.OnGetData          :=doGetRobotID;
  fRAWInstantMessage.OnGetData:=doGetRAWInstantMessage;
  fOwner.OnGetData            :=doGetOwner;
  fProvider.OnGetData         :=doGetProvider;
  fRoYaState.OnGetData        :=doGetRoYaState;
  fIntroduce.OnGetData        :=doGetIntroduce;

  fTimer.OnGetData            :=doGetTimer;
  fTimer.OnSetData            :=doSetTimer;
  fStatus.OnGetData           :=doGetStatus;
  fStatus.OnSetData           :=doSetStatus;
  fDoNotSend.OnGetData        :=doGetDoNotSend;
  fDoNotSend.OnSetData        :=doSetDoNotSend;
  fIsAlice.OnGetData          :=doGetIsAlice;
  fIsAlice.OnSetData          :=doSetIsAlice;
  fPythonEngine.LoadDll;
  fPythonModule.Initialize;
end;

destructor TIMPythonScript.Destroy;
begin
  fPythonEngine.Free;
  fPythonModule.Free;
  fScriptContent.free;

  fUserID.free;
  fHWNDApp.free;
  fRobotID.free;
  fRAWInstantMessage.free;
  fOwner.free;
  fProvider.free;
  fRoYaState.free;
  fTimer.free;
  fIntroduce.free;
  fStatus.free;
  fDoNotSend.free;
  fIsAlice.free;
  inherited;
end;

procedure TIMPythonScript.doGetDoNotSend(Sender: TObject;
  var Data: Variant);
begin
  Data:=fContactInfo.Out_DoNotSend
end;

procedure TIMPythonScript.doGetHWNDApp(Sender: TObject; var Data: Variant);
begin
  Data:=fContactInfo.In_HWNDApp;
end;

procedure TIMPythonScript.doGetIntroduce(Sender: TObject;
  var Data: Variant);
begin
  Data:=fContactInfo.In_Introduce;
end;

procedure TIMPythonScript.doGetIsAlice(Sender: TObject; var Data: Variant);
begin
  Data:=fContactInfo.Out_IsAlice;
end;

procedure TIMPythonScript.doGetOwner(Sender: TObject; var Data: Variant);
begin
  Data:=fContactInfo.In_Owner;
end;

procedure TIMPythonScript.doGetProvider(Sender: TObject;
  var Data: Variant);
begin
  Data:=fContactInfo.In_Provider;
end;

procedure TIMPythonScript.doGetRAWInstantMessage(Sender: TObject;
  var Data: Variant);
begin
  Data:=fContactInfo.In_RAWInstantMessage;
end;

procedure TIMPythonScript.doGetRobotID(Sender: TObject; var Data: Variant);
begin
  Data:=fContactInfo.In_RobotID;
end;

procedure TIMPythonScript.doGetRoYaState(Sender: TObject;
  var Data: Variant);
begin
//  Data:=fContactInfo.;
end;

procedure TIMPythonScript.doGetStatus(Sender: TObject; var Data: Variant);
begin
  Data:=fContactInfo.Out_StatusMessage;
end;


procedure TIMPythonScript.doGetTimer(Sender: TObject; var Data: Variant);
begin
  Data:=fContactInfo.Out_Timer;
end;

procedure TIMPythonScript.doGetUserID(Sender: TObject; var Data: Variant);
begin
  Data:=fContactInfo.In_UserID;
end;

procedure TIMPythonScript.doPythonModuleInit(Sender: TObject);
begin
  with Sender as TPythonModule do
    begin
      AddDelphiMethod( 'InstantMessage',
                       RoYa_Add_InstantMessage,
                       'Function InstantMessage(String)' );
      AddDelphiMethod( 'ListParam',
                       RoYa_Get_ListParam,
                       'Function ListParam(Idx)');
      AddDelphiMethod( 'ListParamCount',
                       RoYa_Get_ListParamCount,
                       'Function ListParamCount');
    end;
end;

procedure TIMPythonScript.doSetDoNotSend(Sender: TObject; Data: Variant);
begin
  fContactInfo.Out_DoNotSend:=Data;
end;

procedure TIMPythonScript.doSetIsAlice(Sender: TObject; Data: Variant);
begin
  fContactInfo.Out_IsAlice:=Data;
end;

procedure TIMPythonScript.doSetStatus(Sender: TObject; Data: Variant);
begin
  fContactInfo.Out_StatusMessage:=Data;
end;


procedure TIMPythonScript.doSetTimer(Sender: TObject; Data: Variant);
begin
  fContactInfo.Out_Timer:=Data;
end;

procedure TIMPythonScript.Process(pTransmitPacket:TIMTransmitPacket);
begin
  inherited;
  try
    fContactInfo:=pTransmitPacket.ContactInfo;
    fPythonEngine.ExecStrings(fScriptContent);
  except
    if rsOwner in fContactInfo.In_RoYaState then
       fContactInfo.Out_InstantMessage.Add('*** An error has occurred in the python script');
    _Logger.Add('Error in Script !',lsError);
  end;
end;

function TIMPythonScript.RoYa_Add_InstantMessage(pself,
  args: PPyObject): PPyObject;
var
  Msg : Pchar;
begin
  with GetPythonEngine do
  begin
    if PyArg_ParseTuple( args, 's:InstantMessage', [@Msg] ) <> 0 then
    begin
      Result := PyInt_FromLong(fContactInfo.Out_InstantMessage.Add(Msg));
    end
    else
      Result := nil;
  end;
end;

function TIMPythonScript.RoYa_Get_ListParam(pself,
  args: PPyObject): PPyObject;
var
  idx:Integer;
begin
  with GetPythonEngine do
    begin
      if (PyArg_ParseTuple( args, 'i:ListParam', [@idx]) <> 0) and (fContactInfo.In_ListParam.Count>0) then
        Result := PyString_FromString(PChar(fContactInfo.In_ListParam.Strings[idx]))
      else
        Result:=nil
    end;
end;

function TIMPythonScript.RoYa_Get_ListParamCount(pself,
  args: PPyObject): PPyObject;
begin
  with GetPythonEngine do
    begin
      Result := PyInt_FromLong(fContactInfo.In_ListParam.Count);
    end;
end;

end.
