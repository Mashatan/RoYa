{
   File: f_IMScript

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
unit f_IMScript;

interface
uses f_IMTransmitPacket;
Type
  TIMScript=class(TObject)
    private
    public
      constructor Create();
      destructor  Destroy();override;
      procedure Process(pTransmitPacket:TIMTransmitPacket);virtual;abstract;
  end;
implementation

{ TIMScript }

constructor TIMScript.Create;
begin
  inherited;

end;

destructor TIMScript.Destroy;
begin

  inherited;
end;

end.
