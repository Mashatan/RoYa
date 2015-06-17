{
   File: f_MainForm

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
unit f_MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,f_IMRobots,
  Registry,f_SharedMemory,QStrings,ExtCtrls,f_IMConsts,
  Grids, Menus, ActnList, XPMan, StdCtrls;

type

  TMainForm = class(TForm)
    XPManifest1: TXPManifest;
    ActionList: TActionList;
    Act_Start: TAction;
    Act_Stop: TAction;
    Act_Account: TAction;
    Act_Provider: TAction;
    Act_Setting: TAction;
    MainMenu1: TMainMenu;
    Action1: TMenuItem;
    Connect1: TMenuItem;
    Disconnect1: TMenuItem;
    N1: TMenuItem;
    Act_Exit: TAction;
    Connect2: TMenuItem;
    Option1: TMenuItem;
    Provider1: TMenuItem;
    Account1: TMenuItem;
    N2: TMenuItem;
    Setting1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    Act_About: TAction;
    MainGroupBox: TGroupBox;
    ActionLabel: TLabel;
    ActionVarLabel: TLabel;
    OnlineStatusLabel: TLabel;
    Act_Install: TAction;
    Act_Uninstall: TAction;
    Install1: TMenuItem;
    Uninstall1: TMenuItem;
    ModeLabel: TLabel;
    ModeVarLabel: TLabel;
    OnlineStringGrid: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Act_StartExecute(Sender: TObject);
    procedure Act_StopExecute(Sender: TObject);
    procedure Act_AccountExecute(Sender: TObject);
    procedure Act_ProviderExecute(Sender: TObject);
    procedure Act_ExitExecute(Sender: TObject);
    procedure Act_SettingExecute(Sender: TObject);
    procedure Act_AboutExecute(Sender: TObject);
    procedure OnlineStringGridDrawCell(Sender: TObject; ACol,
      ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure Act_InstallExecute(Sender: TObject);
    procedure Act_UninstallExecute(Sender: TObject);
  private
    fUpdateTimer:TTimer;
    fShareMemory:TSharedMemStringList;
    fRobots:TIMRobots;
    fLastChanged:String;
    procedure doUpdateTimer(Sender:TObject);
    procedure InstallService;
    procedure UninstallService;
    procedure Switch();
  public
    Class Procedure CreateApplication;
  end;

var
  MainForm: TMainForm;

implementation
uses f_DataModule,f_IMCommon, f_AccountForm,f_ProviderForm, f_SettingForm, f_AboutForm,
  f_RoYaDefines, DateUtils,ShellAPI,f_IMGeneralInfo;
{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  fShareMemory:=TSharedMemStringList.Create(coKeyShare,1000);
  fRobots:=nil;
  fUpdateTimer:=TTimer.Create(nil);
  fUpdateTimer.Enabled:=true;
  fUpdateTimer.Interval:=200;
  fUpdateTimer.OnTimer:=doUpdateTimer;
  fLastChanged:='';
  ActionVarLabel.Caption:='';
  Switch();
  OnlineStringGrid.Cells[0,0]:='Robot';
  OnlineStringGrid.Cells[1,0]:='Owner';
  OnlineStringGrid.Cells[2,0]:='Provider';
  OnlineStringGrid.Cells[3,0]:='Status';
  OnlineStringGrid.Cells[4,0]:='Total Message';
  OnlineStringGrid.Cells[5,0]:='Total Block Message';
  OnlineStringGrid.Cells[6,0]:='Total Duration';
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  fUpdateTimer.Free;
  fShareMemory.Free;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Act_Stop.Execute;
end;

procedure TMainForm.Switch();
begin
  case _GeneralInfo.Mode of
    mkService: begin
      Act_Stop.Enabled:=true;
      Act_Start.Enabled:=true;
      Act_Install.Visible:=true;
      Act_Uninstall.Visible:=true;
      ModeVarLabel.Caption:='Service';
    end;
    mkApplication :begin
      Act_Stop.Enabled:=false;
      Act_Start.Enabled:=true;
      Act_Install.Visible:=false;
      Act_Uninstall.Visible:=false;
      ModeVarLabel.Caption:='Application';
    end;
  end;
end;

procedure TMainForm.Act_StartExecute(Sender: TObject);
begin
  case _GeneralInfo.Mode of
    mkApplication:begin
      fRobots:=TIMRobots.Create(mkApplication);
      if fRobots.Start then begin
        ActionVarLabel.Caption:='Start';
        Act_Stop.Enabled:=true;
        Act_Start.Enabled:=false;
        Act_Setting.Enabled:=false;
      end else
        FreeAndNil(fRobots);
    end;
    mkService:
      ShellExecute(0, 'open', 'net', 'start '+coRoYaService, nil, SW_HIDE);
  end;
end;

procedure TMainForm.Act_StopExecute(Sender: TObject);
begin
  case _GeneralInfo.Mode of
    mkApplication:
      begin
        if Assigned(fRobots) then
          begin
            fRobots.Stop;
            ActionVarLabel.Caption:='Stop';
            fShareMemory.StringList.Text:='';
            Act_Stop.Enabled:=false;
            Act_Start.Enabled:=true;
            Act_Setting.Enabled:=true;
            FreeAndNil(fRobots);
          end;
     end;
    mkService:
      ShellExecute(0, 'open', 'net', 'stop '+coRoYaService, nil, SW_HIDE);
  end;
end;

procedure TMainForm.Act_AccountExecute(Sender: TObject);
begin
  AccountForm:=TAccountForm.Create(nil);
  AccountForm.ShowModal;
  AccountForm.Free;
end;

procedure TMainForm.Act_ProviderExecute(Sender: TObject);
begin
  ProviderForm:=TProviderForm.Create(nil);
  ProviderForm.ShowModal;
  ProviderForm.Free;
end;

procedure TMainForm.Act_ExitExecute(Sender: TObject);
begin
  close;
end;

procedure TMainForm.Act_SettingExecute(Sender: TObject);
begin
  SettingForm:=TSettingForm.Create(nil);
  SettingForm.ModeComboBox.ItemIndex:=byte(_GeneralInfo.Mode)-1;
  if SettingForm.ShowModal=mrOK then begin
    Act_Stop.Execute;
    _GeneralInfo.Mode:=TModeKind( SettingForm.ModeComboBox.ItemIndex+1);
    Switch();
  end;
  SettingForm.Free;
end;

procedure TMainForm.Act_AboutExecute(Sender: TObject);
begin
  AboutForm:=TAboutForm.Create(nil);
  AboutForm.ShowModal;
  AboutForm.Free;
end;

procedure TMainForm.doUpdateTimer(Sender: TObject);
var
  vCoRow,vCoCol:Integer;
  vStrCell,vStrSum:String;
  vTotalCount:Integer;
begin
  fShareMemory.GetStringList(SHARESTARTPOINT);
  vTotalCount:=fShareMemory.StringList.Count;
  if (vTotalCount>0) then begin
    if (fLastChanged<>fShareMemory.StringList.Text) then begin
      fLastChanged:=fShareMemory.StringList.Text;
      OnlineStringGrid.RowCount:=vTotalCount+1;
      for vCoRow:=0 to  vTotalCount-1 do begin
        vStrSum:=fShareMemory.StringList[vCoRow];
        for vCoCol:=1 to Q_CountOfWords(vStrSum,',') do begin
          vStrCell:=Q_StrTok(vStrSum,',');
          OnlineStringGrid.Cells[vCoCol-1,vCoRow+1] := vStrCell;
          Q_DeleteFirstStr(vStrSum,',');
        end;
      end;
    end;
  end else begin
    for vCoRow:=1 to OnlineStringGrid.RowCount -1 do
      OnlineStringGrid.Rows[vCoRow].Text:='';
    OnlineStringGrid.RowCount:=2;
  end;
end;

function SecToTime(Sec: Longint): string;
var
   H, M, S,D: string;
   ZH, ZM, ZS,ZD: Longint;
begin
   D:='';
   ZD:=0;
   if Sec > 88400 then
     ZD := Sec div 88400;
   ZH := Sec div 3600;
   ZM := Sec div 60 - ZH * 60;
   ZS := Sec - (ZH * 3600 + ZM * 60) ;
   H := IntToStr(ZH) ;
   M := IntToStr(ZM) ;
   S := IntToStr(ZS) ;
   if ZD > 0 then
     D := IntToStr(ZD)+ ' day - ' ;
   Result := D + H + ':' + M + ':' + S;
end;

procedure TMainForm.OnlineStringGridDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  vStr: string;
  vStatus:TAccountStatus;
  vProvider:TProvider;
  vGrid:TStringGrid;
begin
  vGrid:=TStringGrid(Sender);
  vStr := vGrid.Cells[ACol, ARow];
  vGrid.Canvas.Brush.Color:=clWhite;
  if State = [gdFixed] then
    vGrid.Canvas.Brush.Color:=clBtnFace
  else begin
    if (Acol=2) and (vStr<>'') then begin
       vProvider:=TProvider(StrToInt(vStr));
       case vProvider of
         prYahoo:
             vStr:='Yahoo';
       end;
    end;
    if (Acol=6) and (vStr<>'') then begin
      VStr:=SecToTime(StrToint(VStr));
    end;

    if (Acol=3) and (vStr<>'') then begin
       vStatus:=TAccountStatus(StrToInt(vStr));
       case vStatus of
         asConnecting:
             vStr:='Connecting';
         asConnected:
             vStr:='Connected';
         asVerifed:
             vStr:='Verifed';
         asAuthuntication:
             vStr:='Authuntication';
         asLogin:
             vStr:='Login';
         asSuspend:
             vStr:='Suspend';
         asNone:
             vStr:='';
       end;
    end;
  end;
  vGrid.Canvas.FillRect(Rect);
//  vGrid.Canvas.Font.Color := FG[ACol, ARow];
  vGrid.Canvas.TextOut(Rect.Left + 2, Rect.Top + 2, vStr);
end;

procedure TMainForm.InstallService;
begin
  ShellExecute(0, 'open', Pchar(CureentApp), '/install /SILENT', nil, SW_SHOWDEFAULT);
end;


procedure TMainForm.UninstallService;
begin
  ShellExecute(0, 'open', Pchar(CureentApp), '/uninstall  /SILENT', nil, SW_SHOWDEFAULT);
end;

class procedure TMainForm.CreateApplication;
begin
  Application.Initialize;
  Application.Title := 'RoYa';
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end;

procedure TMainForm.Act_InstallExecute(Sender: TObject);
begin
  InstallService;
end;

procedure TMainForm.Act_UninstallExecute(Sender: TObject);
begin
  UnInstallService;
end;

end.



