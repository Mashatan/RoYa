{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Author:       Fran�ois PIETTE
Copyright:    You can use this software freely, at your own risks
Creation:     April 4, 1997
Version:      2.03
Object:       Demo program to show how to use TWSocket object to broadcast
              UDP messages on the network. Use UDPLstn to listen to those
              UDP messages, or other UDP messages.
EMail:        francois.piette@overbyte.be  http://www.overbyte.be
Support:      Use the mailing list twsocket@elists.org
              Follow "support" link at http://www.overbyte.be for subscription.
Legal issues: Copyright (C) 1997-2006 by Fran�ois PIETTE
              Rue de Grady 24, 4053 Embourg, Belgium. Fax: +32-4-365.74.56
              <francois.piette@overbyte.be>

              This software is provided 'as-is', without any express or
              implied warranty.  In no event will the author be held liable
              for any  damages arising from the use of this software.

              Permission is granted to anyone to use this software for any
              purpose, including commercial applications, and to alter it
              and redistribute it freely, subject to the following
              restrictions:

              1. The origin of this software must not be misrepresented,
                 you must not claim that you wrote the original software.
                 If you use this software in a product, an acknowledgment
                 in the product documentation would be appreciated but is
                 not required.

              2. Altered source versions must be plainly marked as such, and
                 must not be misrepresented as being the original software.

              3. This notice may not be removed or altered from any source
                 distribution.

              4. You must register this software by sending a picture postcard
                 to the author. Use a nice stamp and mention your name, street
                 address, EMail address and any comment you like to say.

Updates:
Sep 06, 1997 Version 2.01
Dec 12, 1998 V2.02 Added LocalPort editbox
Jan 10, 2004 V2.03 Don't close socket immediately after send. Instead,
             close it from DataSent event.
             Removed FormPos dependency.

 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
unit UdpSend1;

{$J+}

interface

uses
  WinTypes, Messages, Classes, SysUtils, Controls, Forms, StdCtrls, IniFiles,
  WSocket;

const
  UdpSendVersion     = 203;
  CopyRight : String = ' UdpSend (c) 1997-2006 F. Piette V2.03 ';

type
  TMainForm = class(TForm)
    WSocket: TWSocket;
    SendButton: TButton;
    MessageEdit: TEdit;
    PortEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    LocalPortEdit: TEdit;
    AnyPortCheckBox: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure SendButtonClick(Sender: TObject);
    procedure AnyPortCheckBoxClick(Sender: TObject);
    procedure LocalPortEditChange(Sender: TObject);
    procedure WSocketDataSent(Sender: TObject; ErrCode: Word);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FIniFileName   : String;
    FInitialized   : Boolean;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}


const
    SectionWindow = 'MainForm';
    KeyWidth      = 'Width';
    KeyHeight     = 'Height';
    KeyTop        = 'Top';
    KeyLeft       = 'Left';
    SectionData   = 'Data';
    KeyPort       = 'Port';
    KeyLocalPort  = 'LocalPort';
    KeyMessage    = 'Message';

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMainForm.FormCreate(Sender: TObject);
begin
    FIniFileName := LowerCase(ExtractFileName(Application.ExeName));
    FIniFileName := Copy(FIniFileName, 1, Length(FIniFileName) - 3) + 'ini';
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMainForm.FormShow(Sender: TObject);
var
    IniFile   : TIniFile;
begin
    if not FInitialized then begin
        FInitialized := TRUE;
        IniFile := TIniFile.Create(FIniFileName);
        Width   := IniFile.ReadInteger(SectionWindow, KeyWidth,  Width);
        Height  := IniFile.ReadInteger(SectionWindow, KeyHeight, Height);
        Top     := IniFile.ReadInteger(SectionWindow, KeyTop,    (Screen.Height - Height) div 2);
        Left    := IniFile.ReadInteger(SectionWindow, KeyLeft,   (Screen.Width - Width) div 2);
        PortEdit.Text      := IniFile.ReadString(SectionData, KeyPort,      '600');
        LocalPortEdit.Text := IniFile.ReadString(SectionData, KeyLocalPort, '0');
        MessageEdit.Text   := IniFile.ReadString(SectionData, KeyMessage,   '');
        IniFile.Free;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
    IniFile   : TIniFile;
begin
    IniFile := TIniFile.Create(FIniFileName);
    IniFile.WriteInteger(SectionWindow, KeyWidth,  Width);
    IniFile.WriteInteger(SectionWindow, KeyHeight, Height);
    IniFile.WriteInteger(SectionWindow, KeyTop,    Top);
    IniFile.WriteInteger(SectionWindow, KeyLeft,   Left);
    IniFile.WriteString(SectionData, KeyPort,      PortEdit.Text);
    IniFile.WriteString(SectionData, KeyLocalPort, LocalPortEdit.Text);
    IniFile.WriteString(SectionData, KeyMessage,   MessageEdit.Text);
    IniFile.Free;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMainForm.SendButtonClick(Sender: TObject);
begin
    WSocket.Proto      := 'udp';
    WSocket.Addr       := '255.255.255.255';     { That's a broadcast  ! }
    WSocket.Port       := PortEdit.Text;
    WSocket.LocalPort  := LocalPortEdit.Text;
    { UDP is connectionless. Connect will just open the socket }
    WSocket.Connect;
    WSocket.SendStr(MessageEdit.Text);
    MessageEdit.SelectAll;
    ActiveControl := MessageEdit;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMainForm.AnyPortCheckBoxClick(Sender: TObject);
begin
     if AnyPortCheckBox.Checked then
         LocalPortEdit.Text := '0';
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMainForm.LocalPortEditChange(Sender: TObject);
begin
     AnyPortCheckBox.Checked := (LocalPortEdit.Text = '0');
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMainForm.WSocketDataSent(Sender: TObject; ErrCode: Word);
begin
    WSocket.Close;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

end.

