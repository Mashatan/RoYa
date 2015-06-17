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
unit f_DataModule;

interface

uses
  SysUtils, Classes, ASGSQLite3, DB;

type
  TDM = class(TDataModule)
    ProviderDS: TDataSource;
    ProviderTable: TASQLite3Table;
    DBConnection: TASQLite3DB;
    AccountsDS: TDataSource;
    AccountsTable: TASQLite3Table;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DM: TDM;

implementation

uses f_IMConsts;

{$R *.dfm}

procedure TDM.DataModuleCreate(Sender: TObject);
begin
  DBConnection.Close;
  DBConnection.Database:=coRoYaDBFile;
  DBConnection.DefaultDir:=CurrentPath+coPathDatabase;
  DBConnection.Open;
end;

procedure TDM.DataModuleDestroy(Sender: TObject);
begin
  DBConnection.Close;
end;

end.
