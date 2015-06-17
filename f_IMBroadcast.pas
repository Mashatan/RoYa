{
   File: f_IMBroadcast

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
unit f_IMBroadcast;
interface

uses Classes,SysUtils,f_IMConsts,f_IMBuffer,f_IMContactInfo,f_IMYahooContactInfo,f_IMDatabase,f_IMCommon,f_RoYaDefines,f_IMTransmitPacket;

type
  IMBroadcast=class(TThread)
    Private
      fOutBuf:TIMBuffer;
      fProvider:TProvider;
      fRobotID,fOwner:String;
      fMsg:String;
    Public
      constructor Create(OutBuf:TIMBuffer;Provider:TProvider;RobotID,Owner,Msg:String);
      destructor Destroy;override;
    protected
     procedure Execute;override;
  end;
implementation

constructor IMBroadcast.Create(OutBuf:TIMBuffer;Provider:TProvider;RobotID,Owner,Msg:String);
begin
  inherited Create(false);
  FreeOnTerminate:=true;
  fOutBuf:=OutBuf;
  fProvider:=Provider;
  fRobotID:=RobotID;
  fOwner:=Owner;
  FreeOnTerminate:=true;
  fMsg:=Msg;
end;

destructor IMBroadcast.Destroy;
begin
  inherited;
end;

procedure IMBroadcast.Execute;
var
   Users:TIMQuery;
   username,FinalMessage:String;
   ContactInfo:TIMContactInfo;
   TransmitPacket:TIMTransmitPacket;
begin
  inherited;
  Users:=_Database.CreateQuery;
  try
    users.SQL.Text:=coBroadCastSQLSelect;
    users.ExecSQL;
    FinalMessage:='FA: '+fMsg;
    while not users.Eof and not Terminated do begin
      sleep(1);
      username:=Users.FieldByName('Username').AsString;
      case fProvider of
        prYahoo: begin
          ContactInfo:=TIMYahooContactInfo.Create;
          (ContactInfo as TIMYahooContactInfo).ServiceProcessed:=YAHOO_SERVICE_MESSAGE;
        end;
        else
          ContactInfo:=TIMContactInfo.Create;
      end;
      ContactInfo.RawData:='';
      ContactInfo.IsBroadcast:=true;
      ContactInfo.In_RoYaState:= [];
      ContactInfo.In_Provider:=fProvider;
      ContactInfo.In_Owner:=fOwner;
      ContactInfo.In_RobotID:=fRobotID;
      ContactInfo.In_UserID:=username;
      ContactInfo.Out_InstantMessage.Text:=FinalMessage;
      TransmitPacket:=TIMTransmitPacket.CreateTransmitPacket(fOutBuf,ContactInfo);
      fOutBuf.Push(TransmitPacket);
      Users.Next;
    end;
  finally
     Users.Close;
     Users.Free;
  end;
end;

end.
