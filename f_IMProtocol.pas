{
   File: f_IMProtocol

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
unit f_IMProtocol;
interface

uses Classes,f_IMConsts,f_IMContactInfo;

type
  TProtocolEvent = procedure(Sender: TObject;pContactInfo:TIMContactInfo) of object;
  TIMProtocol = class (TObject)
    private
      fOnInitialize:TProtocolEvent;
      fOnVerified:TProtocolEvent;
      fOnAuthentication:TProtocolEvent;
      fOnLogin:TProtocolEvent;
    public
      Stage:TStageKind;
      constructor Create;
      destructor Destroy;override;
      
      procedure Initialize(pContactInfo:TIMContactInfo);virtual;abstract;
      procedure SendMessage(pContactInfo:TIMContactInfo);virtual;abstract;
      procedure ReceiveMessage(ContactInfo:TIMContactInfo);virtual;abstract;
      Function  Ping(pUsername:String):String;virtual;abstract;

      property  OnInitialize:TProtocolEvent read fOnInitialize write fOnInitialize;
      property  OnVerified:TProtocolEvent read fOnVerified write fOnVerified;
      property  OnAuthentication:TProtocolEvent read fOnAuthentication write fOnAuthentication;
      property  OnLogin:TProtocolEvent read fOnLogin write fOnLogin;
  end;
implementation

constructor TIMProtocol.Create();
begin
  inherited Create;
end;

destructor TIMProtocol.Destroy;
begin

  inherited;
end;

end.