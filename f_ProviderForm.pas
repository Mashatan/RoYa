{
   File: f_ProviderForm

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
unit f_ProviderForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  db,
  DBActns, ActnList, Grids, DBGrids, StdCtrls, DBCtrls, Mask;

type
  TProviderForm = class(TForm)
    CancelBtn: TButton;
    CloseBtn: TButton;
    ActionList: TActionList;
    Act_DataSetPost: TDataSetPost;
    Act_DataSetInsert: TDataSetInsert;
    ProvicerGroupBox: TGroupBox;
    ConnectionGroup: TGroupBox;
    HostLabel: TLabel;
    PortLabel: TLabel;
    ProxyGroup: TGroupBox;
    HttpProxyHostLabel: TLabel;
    HttpProxyPortLabel: TLabel;
    SocksGroup: TGroupBox;
    SocksHostLabel: TLabel;
    SocksPortLabel: TLabel;
    Ver4Radio: TRadioButton;
    Ver5Radio: TRadioButton;
    AuthGroup: TGroupBox;
    AuthUsernameLabel: TLabel;
    AuthPasswordLabel: TLabel;
    ProviderTypeCombo: TComboBox;
    ProvicerTypeLabel: TLabel;
    HostCombo: TDBComboBox;
    PortEdit: TDBEdit;
    HttpProxyChk: TDBCheckBox;
    SocksChk: TDBCheckBox;
    AuthChk: TDBCheckBox;
    HttpProxyHostEdit: TDBEdit;
    HttpProxyPortEdit: TDBEdit;
    SocksHostEdit: TDBEdit;
    SocksPortEdit: TDBEdit;
    AuthUsernameEdit: TDBEdit;
    AuthPasswordEdit: TDBEdit;
    Act_DataSetCancel: TDataSetCancel;
    Act_DataSetEdit: TDataSetEdit;
    Act_DataSetDelete: TDataSetDelete;
    InsertBtn: TButton;
    EditBtn: TButton;
    DeleteBtn: TButton;
    PostBtn: TButton;
    ProviderGrid: TDBGrid;
    NameLabel: TLabel;
    NameEdit: TDBEdit;
    procedure FormCreate(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure ChkHTTPCenter(Sender: TObject);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure FormDestroy(Sender: TObject);
  private
    procedure ChangeStatus;
    procedure ProviderQueryBeforePost(DataSet: TDataSet);
    procedure ProviderQueryAfterScroll(DataSet: TDataSet);
  public
  end;

var
  ProviderForm: TProviderForm;

implementation

uses f_DataModule;
{$R *.dfm}

procedure TProviderForm.FormCreate(Sender: TObject);
begin
  with dm.ProviderTable do
    begin
      Open;
      BeforePost:=ProviderQueryBeforePost;
      AfterRefresh:=ProviderQueryAfterScroll;
      AfterScroll:=ProviderQueryAfterScroll;
    end;
  ChangeStatus;
end;


procedure TProviderForm.FormDestroy(Sender: TObject);
begin
  with dm.ProviderTable do
    begin
      BeforePost:=nil;
      AfterRefresh:=nil;
      AfterScroll:=nil;
      Close;
    end;  
end;

procedure TProviderForm.ProviderQueryBeforePost(DataSet: TDataSet);
begin
  With DM.ProviderTable do begin
    FieldByName('ProviderType').AsInteger:= ProviderTypeCombo.ItemIndex+1;
    FieldByName('SocksProxyVer').AsInteger:= 0;
    if Ver5Radio.Checked then
      FieldByName('SocksProxyVer').AsInteger:= 1
    else
      FieldByName('SocksProxyVer').AsInteger:= 0;
    if HttpProxyChk.State=cbGrayed then
      FieldByName('HttpProxy').AsBoolean:=false;
    if SocksChk.State=cbGrayed then
      FieldByName('SocksProxy').AsBoolean:=false;
    if AuthChk.State=cbGrayed then
      FieldByName('SocksProxyAuth').AsBoolean:=false;
  end;
end;

procedure TProviderForm.ProviderQueryAfterScroll(DataSet: TDataSet);
begin
  With DM.ProviderTable do begin
    ProviderTypeCombo.ItemIndex:=FieldByName('ProviderType').AsInteger-1;
    Ver5Radio.Checked:=FieldByName('SocksProxyVer').AsInteger=1;
  end;
end;



procedure TProviderForm.ChangeStatus;
Begin
  HttpProxyHostLabel.Enabled:=HttpProxyChk.Checked;
  HttpProxyPortLabel.Enabled:=HttpProxyChk.Checked;
  HttpProxyHostEdit.Enabled:=HttpProxyChk.Checked;
  HttpProxyPortEdit.Enabled:=HttpProxyChk.Checked;
  
  SocksHostLabel.Enabled:=SocksChk.Checked;
  SocksPortLabel.Enabled:=SocksChk.Checked;
  SocksHostEdit.Enabled:=SocksChk.Checked;       
  SocksPortEdit.Enabled:=SocksChk.Checked;
  
  Ver4Radio.Enabled:=SocksChk.Checked;
  Ver5Radio.Enabled:=SocksChk.Checked;

  AuthChk.Enabled:=SocksChk.Checked and Ver5Radio.Checked;
  AuthUsernameLabel.Enabled:=SocksChk.Checked and AuthChk.Checked and Ver5Radio.Checked ;
  AuthPasswordLabel.Enabled:=SocksChk.Checked and AuthChk.Checked and Ver5Radio.Checked;
  AuthUsernameEdit.Enabled:=SocksChk.Checked and AuthChk.Checked and Ver5Radio.Checked;
  AuthPasswordEdit.Enabled:=SocksChk.Checked and AuthChk.Checked and Ver5Radio.Checked;
  AuthGroup.Enabled:=SocksChk.Checked and AuthChk.Checked and Ver5Radio.Checked;
End;


procedure TProviderForm.OKBtnClick(Sender: TObject);
begin
//
end;

procedure TProviderForm.ChkHTTPCenter(Sender: TObject);
begin
  ChangeStatus;
end;

procedure TProviderForm.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
begin
  if Msg.CharCode=VK_ESCAPE then begin
    ModalResult:=mrCancel;
  End;
end;


end.
