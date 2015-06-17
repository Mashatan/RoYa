{
   File: f_SettingForm

   Project:  RoYa
   Status:   Version 4.0
   Date:     2008-09-22
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
unit f_SettingForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TSettingForm = class(TForm)
    MiscGroup: TGroupBox;
    CancelBtn: TButton;
    OKBtn: TButton;
    ModeComboBox: TComboBox;
    ModeLabel: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SettingForm: TSettingForm;

implementation

{$R *.dfm}

end.
