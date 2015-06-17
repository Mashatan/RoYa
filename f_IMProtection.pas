{
   File: f_LoadDLL

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
unit f_IMProtection;

interface
Type
 TIMProtection=class(TObject)
   public
     constructor Create;
     Destructor  Destroy;override;
 end;
implementation


{ TIMProtection }

constructor TIMProtection.Create;
begin
  inherited;

end;

destructor TIMProtection.Destroy;
begin

  inherited;
end;

end.
