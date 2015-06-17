{
   File: f_IMAccount

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
unit f_IMAccount;

interface

uses SysUtils,f_RoYaDefines,f_IMConsts;

type
  {TIMAccount}
TIMAccount=Class(TObject)
private
    fAccountID:Integer;
    fStatus:TAccountStatus;
    fSuspend:Boolean;
    fHost:String;
    fPort:String;
    fRobotID:String;
    fPassword:String;
    fOwner:String;
    fStatusMessage:String;
    fUserTimer:Integer;
    fProvider:TProvider;
    fInvisiable:boolean;
    fHTTPProxy:Boolean;
    fHTTPProxyHost:String;
    fHTTPProxyPort:String;
    fSocksExist:Boolean;
    fSocksHost:String;
    fSocksPort:String;
    fSocksAuthentication:Boolean;
    fSocksVer:TVerSOCKSKind;
    fSocksUsername:String;
    fSocksPassword:String;
    fTotalBlockMessageNo:Cardinal;
    fTotalMessageNo:Cardinal;
    fTotalDuration:Cardinal;
    fFirstEnter:TDateTime;
    fStartTime:TDateTime;

    procedure setSuspend(value:Boolean);
public
    property AccountID:Integer read fAccountID write fAccountID;
    property Status:TAccountStatus read fStatus write fStatus;
    property Suspend:Boolean read fSuspend write setSuspend;
    property Host:String read fHost write fHost;
    property Port:String read fPort write fPort;
    property RobotID:String read fRobotID write fRobotID;
    property Password:String read fPassword write fPassword;
    property Owner:String read fOwner write fOwner;
    property StatusMessage:String read fStatusMessage write fStatusMessage;
    property UserTimer:Integer read fUserTimer write fUserTimer;
    property Provider:TProvider read fProvider write fProvider;
    property Invisiable:boolean read fInvisiable write fInvisiable;
    property HTTPProxy:Boolean read fHTTPProxy write fHTTPProxy;
    property HTTPProxyHost:String read fHTTPProxyHost write fHTTPProxyHost;
    property HTTPProxyPort:String read fHTTPProxyPort write fHTTPProxyPort;
    property SocksExist:Boolean read fSocksExist write fSocksExist;
    property SocksHost:String read fSocksHost write fSocksHost;
    property SocksPort:String read fSocksPort write fSocksPort;
    property SocksAuthentication:Boolean read fSocksAuthentication write fSocksAuthentication;
    property SocksVer:TVerSOCKSKind read fSocksVer write fSocksVer;
    property SocksUsername:String read fSocksUsername write fSocksUsername;
    property SocksPassword:String read fSocksPassword write fSocksPassword;
    property TotalBlockMessageNo:Cardinal read fTotalBlockMessageNo write fTotalBlockMessageNo;
    property TotalMessageNo:Cardinal read fTotalMessageNo write fTotalMessageNo;
    property TotalDuration:Cardinal read fTotalDuration write fTotalDuration;
    property FirstEnter:TDateTime read fFirstEnter write fFirstEnter;
    property StartTime:TDateTime read fStartTime;
    constructor Create;
    destructor  Destroy;override;
  end;

implementation

{TIMAccount}
constructor TIMAccount.Create;
begin
  UserTimer:=1000*5;
  TotalMessageNo:=0;
  TotalDuration:=0;
  Suspend:=false;
  fStatus:=asNone;
  fStartTime:=now;
end;

destructor TIMAccount.Destroy;
begin

  inherited;
end;

procedure TIMAccount.setSuspend(value: Boolean);
begin
   if value and (fStatus=asLogin)  then begin
     fSuspend:=true;
     fStatus:=asSuspend;
   end
   else
   if not value and (fStatus=asSuspend)  then begin
     fSuspend:=false;
     fStatus:=asLogin;
   end;
end;

end.
