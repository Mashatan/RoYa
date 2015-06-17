{
   File: f_Core

   Project:  RoYa
   Status:   Version 4.0 
   Date:     2008-10-19
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
unit f_IMCore;

interface
uses
  Classes,Types,Forms,ExtCtrls,Windows,SysUtils,WSocket,f_IMAccount,f_IMContactInfo,f_IMProtocol,f_IMTransmitPacket,f_IMCommon,f_IMWatcher,f_IMBuffer;
type
  TIMCore = class (TThread)
  private
    fCliSocket:  TWSocket;
    fAccount:   TIMAccount;
    fWatcher:   TIMWatcher;
    fInputBuffer , fOutputBuffer :TIMBuffer;
    fPingTimer: TTimer;
    fUserTimer: TTimer;
    fRunning:   Boolean;
    procedure   DetectProtocol;
    procedure   doSocketDataAvailable(Sender: TObject; Error: Word);
    procedure   doClosed(Sender: TObject; Error: Word);
    procedure   doConnected(Sender: TObject; Error: Word);
    procedure   PingTimer(Sender:TObject);
    procedure   UserTimer(Sender:TObject);
    function    CreateContactInfo(rData:String):TIMContactInfo;
    procedure   doInitialize(Sender: TObject;pContactInfo:TIMContactInfo);
    procedure   doVerified(Sender: TObject;pContactInfo:TIMContactInfo);
    procedure   doAuthentication(Sender: TObject;pContactInfo:TIMContactInfo);
    procedure   doLogin(Sender: TObject;pContactInfo:TIMContactInfo);
  protected
    procedure   Execute; override;
  public
    Protocol:   TIMProtocol;
    property    Account:TIMAccount read fAccount write fAccount;
    constructor Create(vAccount:TIMAccount;vWatcher:TIMWatcher;vInputBuffer:TIMBuffer);
    destructor  Destroy; override;
    procedure   Process;
  end;

implementation
uses f_IMConsts,f_RoYaDefines,f_IMYahooContactInfo,f_IMYahooProtocol,f_IMGeneralInfo;
const
  PingTimerValue:Cardinal=60*1000*16;

constructor TIMCore.Create(vAccount:TIMAccount;vWatcher:TIMWatcher;vInputBuffer:TIMBuffer);
begin
  inherited Create(false);
  fAccount:=vAccount;
  fCliSocket:= TWSocket.Create(nil);
  fPingTimer:=TTimer.Create(nil);
  fPingTimer.OnTimer:=PingTimer;
  fUserTimer:=TTimer.Create(nil);
  fUserTimer.Enabled:=false;
  fUserTimer.OnTimer:=UserTimer;
  fOutputBuffer:=TIMBuffer.Create;
  fCliSocket.OnDataAvailable:=doSocketDataAvailable;
  fCliSocket.OnSessionConnected:=doConnected;
  fCliSocket.OnSessionClosed:=doClosed;
  fWatcher:=vWatcher;
  fInputBuffer:=vInputBuffer;
end;

destructor TIMCore.Destroy;
begin
  fAccount.Free;
  self.Terminate;
  while fRunning  do begin
    sleep(1);
  end;
  fPingTimer.Enabled :=false;
  fUserTimer.Enabled :=false;
  fPingTimer.Free;
  fUserTimer.Free;
  Protocol.Free;
  fOutputBuffer.Free;
  fCliSocket.Free;
  inherited Destroy;
end;

procedure TIMCore.PingTimer(Sender:TObject);
var
  Packet:String;
begin
  if fCliSocket.State<>wsConnected then
    exit;
  Packet:='';
  case self.fAccount.Provider of
    prYahoo: begin
       Packet:=Protocol.Ping(self.fAccount.RobotID);
    end;
  end;
  if Packet<>'' then begin
    fCliSocket.SendStr(Packet);
    fCliSocket.Flush;
  end;
end;

procedure TIMCore.UserTimer(Sender:TObject);
var
  vTransmitPacket:TIMTransmitPacket;
  vContactInfo:TIMContactInfo;
begin
  if fAccount.Suspend then
    exit;
  vContactInfo:=CreateContactInfo('');
  vContactInfo.Transport:=trOuter;
  vContactInfo.In_RobotID :=self.fAccount.RobotID;
  vContactInfo.In_RoYaState:= vContactInfo.In_RoYaState + [rsTimer];
  vTransmitPacket:= TIMTransmitPacket.CreateTransmitPacket(fOutputBuffer,vContactInfo);
  fInputBuffer.Push(vTransmitPacket);
end;


procedure TIMCore.Execute;
begin
  DetectProtocol;
  fUserTimer.Interval:=_GeneralInfo.UserTimerInterval;
  fUserTimer.Enabled:=True;
  fPingTimer.Interval:=PingTimerValue;
  fPingTimer.Enabled:=True;
  FRunning := True;
  try
    try
      while not self.Terminated do begin
        SysUtils.sleep(1);
        self.Process;
      end;
    except
    end;
  finally
    fCliSocket.CloseDelayed;
    FRunning := False;
 end;
end;


function TIMCore.CreateContactInfo(rData:String):TIMContactInfo;
begin
  case self.fAccount.Provider of
   prYahoo:
     result:=TIMYahooContactInfo.Create();
   else
     result:=TIMContactInfo.Create();
   end;
   result.RawData:=rData;
   result.Out_IsAlice:=false;
   result.Out_DoNotSend:=false;
   result.In_RoYaState:= [];
   result.In_Provider:=self.fAccount.Provider;
   result.In_Owner:=self.fAccount.Owner;
   result.In_RobotID:=self.fAccount.RobotID;
   result.In_UserID:='';
end;


procedure TIMCore.DetectProtocol;
begin
 case self.fAccount.Provider of
    prYahoo: begin
        Protocol:=TIMYahooProtocol.Create(self.fAccount.Password);
        Protocol.OnInitialize:=doInitialize;
        Protocol.OnVerified:=doVerified;
        Protocol.OnAuthentication:=doAuthentication;
        Protocol.OnLogin:=doLogin;
      end;
    else begin
        Protocol:=TIMYahooProtocol.Create(self.fAccount.Password);
      end;  
 end;
end;

procedure TIMCore.doSocketDataAvailable(Sender: TObject; Error: Word);
var
  vContactInfo:TIMContactInfo;
  vTransmitPacket:TIMTransmitPacket;
  vData:String;
begin
   vData:='';
   if fCliSocket.RcvdCount <>0 then
     vData:=fCliSocket.ReceiveStr;
   if (vData<>'') and not fAccount.Suspend then begin
     vContactInfo:=CreateContactInfo(vData);
     self.Protocol.ReceiveMessage(vContactInfo);
     if fWatcher.isValidUser(vContactInfo,fAccount) then begin
       vTransmitPacket:=TIMTransmitPacket.CreateTransmitPacket(fOutputBuffer,vContactInfo);
       fInputBuffer.Push(vTransmitPacket)
     end else
       vContactInfo.Free;
   end;
end;


procedure TIMCore.Process;
var
  vContactInfo:TIMContactInfo;
  vTransmitPacket:TIMTransmitPacket;  
begin
  case fCliSocket.State of
     wsClosed:
     begin
       fCliSocket.Close;
       fAccount.Status:=asConnecting;
       fCliSocket.Addr:= self.fAccount.Host;
       fCliSocket.Port:= self.fAccount.Port;
       fCliSocket.SocksAuthentication:=socksNoAuthentication;
       fCliSocket.SocksLevel:='5';
       if self.fAccount.SOCKSExist then begin
        fCliSocket.SocksServer:=self.fAccount.SocksHost;
        fCliSocket.SocksPort:=self.fAccount.SocksPort;
        if fAccount.SOCKSVer=Ver5 then begin
          if self.fAccount.SOCKSAuthentication then begin
            fCliSocket.SocksAuthentication:=socksAuthenticateUsercode;
            fCliSocket.SocksUsercode:=self.fAccount.SOCKSUsername;
            fCliSocket.SocksPassword:=self.fAccount.SOCKSPassword;
          end;
        end else
          fCliSocket.SocksLevel:='4';
       end;
       try
         fCliSocket.Connect;
       except
         on E:Exception do
           begin
             _Logger.Add(E.Message,lsError);
             fCliSocket.Close;
             exit;
           end;
       end;
       vContactInfo:=CreateContactInfo('');
       Protocol.Initialize(vContactInfo);
       vTransmitPacket:=TIMTransmitPacket.CreateTransmitPacket(fOutputBuffer,vContactInfo);
       fInputBuffer.Push(vTransmitPacket);
     end;
     wsConnected:
     begin
       if fOutputBuffer.Count<>0 then begin
          vTransmitPacket:=fOutputBuffer.POP;
          vContactInfo:=vTransmitPacket.ContactInfo;
          vContactInfo.Idx:=0;
          repeat
            Self.Protocol.SendMessage(vContactInfo);
            fCliSocket.SendStr(vContactInfo.ProcessedData);
            fCliSocket.Flush;
            vContactInfo.Idx:=vContactInfo.Idx+1;
          until vContactInfo.Out_InstantMessage.Count <= vContactInfo.Idx;
          vContactInfo.Free;
          vTransmitPacket.Free;
       end else
         fWatcher.Idle;
     end;
  end;
end;

procedure TIMCore.doClosed(Sender: TObject; Error: Word);
begin
  fAccount.Status:=asDisconnected;
end;

procedure TIMCore.doConnected(Sender: TObject; Error: Word);
begin
  fAccount.Status:=asConnected;
end;


procedure TIMCore.doAuthentication(Sender: TObject;pContactInfo:TIMContactInfo);
begin
  fAccount.Status:=asAuthuntication;
end;

procedure TIMCore.doInitialize(Sender: TObject;pContactInfo:TIMContactInfo);
begin
//  fAccount.Status:=asAuthuntication;

end;

procedure TIMCore.doLogin(Sender: TObject;pContactInfo:TIMContactInfo);
begin
  fAccount.Status:=asLogin;
  pContactInfo.Out_StatusMessage:=fAccount.StatusMessage;
end;

procedure TIMCore.doVerified(Sender: TObject;pContactInfo:TIMContactInfo);
begin
  fAccount.Status:=asVerifed;
end;

end.
