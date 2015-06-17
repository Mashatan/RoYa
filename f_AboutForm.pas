{
   File: f_AboutForm

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
unit f_AboutForm;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls,
     StdCtrls,Messages,ExtCtrls,jpeg,ShellAPI;

type
  TAboutForm = class(TForm)
    VersionLabel: TLabel;
    ElLabel2: TLabel;
    ElLabel3: TLabel;
    Image2: TImage;
    Label4: TLabel;
    Label5: TLabel;
    MashatanSoftwareLabel: TLabel;
    EmailEdit: TEdit;
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure MashatanSoftwareLabelClick(Sender: TObject);
  private
    Procedure SendWeb(pDestination : string);
    function GetFileVersion:String;
  public
  end;

var
  AboutForm: TAboutForm;

implementation
{$R *.dfm}

Procedure TAboutForm.SendWeb(pDestination : string);
var
 vTmp : array[0..255] of Char;
begin
  Lowercase(pDestination);
  if Pos('http://',pDestination)<>1 then
     pDestination:='http://'+pDestination;
  StrPCopy(vTmp,pDestination);
  ShellExecute(0, 'open', 'iexplore.exe', vtmp, nil, SW_SHOWDEFAULT);
end;

function TAboutForm.GetFileVersion:String;
var
  vFileName: String;
  vBufferSize: DWORD;
  vDummy: DWORD;
  vBuffer: Pointer;
  vFileInfo: Pointer;
  vVer: array[1..4] of Word;
begin
  Result := '';
  SetLength(vFileName, MAX_PATH + 1);
  SetLength(vFileName,
    GetModuleFileName(hInstance, PChar(vFileName), MAX_PATH + 1));
  vBufferSize := GetFileVersionInfoSize(PChar(vFileName), vDummy);
  if (vBufferSize > 0) then
  begin
    GetMem(vBuffer, vBufferSize);
    try
    GetFileVersionInfo(PChar(vFileName), 0, vBufferSize, vBuffer);
    VerQueryValue(vBuffer, '\', vFileInfo, vDummy);
    vVer[1] := HiWord(PVSFixedFileInfo(vFileInfo)^.dwFileVersionMS);
    vVer[2] := LoWord(PVSFixedFileInfo(vFileInfo)^.dwFileVersionMS);
    vVer[3] := HiWord(PVSFixedFileInfo(vFileInfo)^.dwFileVersionLS);
    vVer[4] := LoWord(PVSFixedFileInfo(vFileInfo)^.dwFileVersionLS);
    finally
      FreeMem(vBuffer);
    end;
    Result := intToStr(vVer[1]) +'.'+ intToStr(vVer[2]) +'.'+ intToStr(vVer[3]) +'.'+ intToStr(vVer[4]);
  end;
end;

procedure TAboutForm.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
begin
  if Msg.CharCode=VK_ESCAPE then
  begin
    ModalResult:=mrOk;
  End;
end;

procedure TAboutForm.FormCreate(Sender: TObject);
begin
 VersionLabel.Caption:='Version: '+GetFileVersion;
end;

procedure TAboutForm.MashatanSoftwareLabelClick(Sender: TObject);
begin
  SendWeb('https://github.com/Mashatan');
end;

end.

