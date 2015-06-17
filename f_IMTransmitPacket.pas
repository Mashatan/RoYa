{
   File: f_IMTransmitPacket

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
unit f_IMTransmitPacket;
interface
uses Contnrs,f_IMContactInfo;

type
TIMTransmitPacket = class (TObject)
  Private
    fOutBuffer:TObjectQueue;
    fContactInfo:TIMContactInfo;
  Public
    Constructor Create;
    Destructor Destroy;override;
    Property Buffer:TObjectQueue read fOutBuffer;
    Property ContactInfo:TIMContactInfo read fContactInfo;
    class function CreateTransmitPacket(OutBuffer:TObjectQueue;ContactInfo:TIMContactInfo):TIMTransmitPacket;
end;



implementation

{ TIMTransmitPacket }

constructor TIMTransmitPacket.Create;
begin
  inherited Create;

end;

destructor TIMTransmitPacket.Destroy;
begin

 inherited;
end;
 
class function TIMTransmitPacket.CreateTransmitPacket(OutBuffer: TObjectQueue;
  ContactInfo: TIMContactInfo): TIMTransmitPacket;
begin
  result:= TIMTransmitPacket.Create;
  result.fOutBuffer:=OutBuffer;
  result.fContactInfo:=ContactInfo;
end;


end.
