{
   File: f_AccountForm

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
unit f_AccountForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  db, f_IMCryptography,
  DBActns, ActnList, Grids, DBGrids, StdCtrls, DBCtrls, Mask  ;

type
  TAccountForm = class(TForm)
    CloseBtn: TButton;
    AuthenticationGroup: TGroupBox;
    PasswordLabel: TLabel;
    UsernameLabel: TLabel;
    OwnerLabel1: TLabel;
    StatusLabel: TLabel;
    AccountGrid: TDBGrid;
    UsernameEdit: TDBEdit;
    OwnerEdit: TDBEdit;
    StatusEdit: TDBEdit;
    ActionList: TActionList;
    Act_DataSetPost: TDataSetPost;
    Act_DataSetInsert: TDataSetInsert;
    Act_DataSetCancel: TDataSetCancel;
    Act_DataSetEdit: TDataSetEdit;
    Act_DataSetDelete: TDataSetDelete;
    CancelBtn: TButton;
    InsertBtn: TButton;
    EditBtn: TButton;
    DeleteBtn: TButton;
    PostBtn: TButton;
    InvisibleChk: TDBCheckBox;
    ProviderLabel: TLabel;
    ProviderComboBox: TDBLookupComboBox;
    ActiveChk: TDBCheckBox;
    PasswordEdit: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure InvisibleChkClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure FormDestroy(Sender: TObject);
  private
    fCrypto:TCryptoGraphy;
    procedure ProviderQueryBeforePost(DataSet: TDataSet);
    procedure ProviderQueryAfterUpdate(DataSet: TDataSet);
  public
  end;

var
  AccountForm: TAccountForm;

implementation

uses f_DataModule;
{$R *.dfm}

procedure TAccountForm.FormCreate(Sender: TObject);
begin
  fCrypto:=TCryptoGraphy.Create;
  dm.AccountsTable.AfterScroll:=ProviderQueryAfterUpdate;
  dm.AccountsTable.AfterRefresh:=ProviderQueryAfterUpdate;
  dm.ProviderTable.Open;
  dm.AccountsTable.Open;
  dm.AccountsTable.BeforePost:=ProviderQueryBeforePost;
//  dm.AccountsTable.AfterOpen:=ProviderQueryAfterUpdate;
end;

procedure TAccountForm.FormDestroy(Sender: TObject);
begin
  dm.AccountsTable.BeforePost:=nil;
  dm.AccountsTable.AfterScroll:=nil;
  dm.AccountsTable.AfterRefresh:=nil;
  dm.ProviderTable.Close;
  dm.AccountsTable.Close;
  fCrypto.Free;
end;

procedure TAccountForm.ProviderQueryAfterUpdate(DataSet: TDataSet);
begin
    PasswordEdit.Text:=fCrypto.Decrypt(DM.AccountsTable.FieldByName('Password').AsString);
end;

procedure TAccountForm.ProviderQueryBeforePost(DataSet: TDataSet);
begin
  With DM.AccountsTable do begin
    if ActiveChk.Checked then
      FieldByName('Active').AsBoolean:= True
    else  
      FieldByName('Active').AsBoolean:= False;
    if StatusEdit.Text='' then
      FieldByName('Status').AsString:='This is a RoYa !';
    if InvisibleChk.State=cbGrayed then
      FieldByName('Invisiable').AsBoolean:= False;
    FieldByName('TotalBlockMessageNo').AsInteger:= 0;
    FieldByName('TotalMessageNo').AsInteger:= 0;
    FieldByName('TotalDuration').AsInteger:= 0;
    FieldByName('Password').AsString:=fCrypto.Encrypt(PasswordEdit.Text);
  end;
end;


procedure TAccountForm.InvisibleChkClick(Sender: TObject);
begin
   StatusEdit.Enabled:=not InvisibleChk.Checked;
end;

procedure TAccountForm.OKBtnClick(Sender: TObject);
begin
//
end;

procedure TAccountForm.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
begin
  if Msg.CharCode=VK_ESCAPE then begin
    ModalResult:=mrCancel;
  End;
end;



end.
