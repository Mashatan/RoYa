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

unit f_MainSrv;

interface

uses
  Windows,WinSvc, Messages, SysUtils, Classes, Graphics, Controls, SvcMgr,
  Dialogs,f_IMRobots,Registry;

type
  TRoYaService = class(TService)
    procedure ServiceExecute(Sender: TService);
    procedure ServiceCreate(Sender: TObject);
    procedure ServiceDestroy(Sender: TObject);
    procedure ServiceAfterInstall(Sender: TService);
  private
    fRobots:TIMRobots;
  public
    function GetServiceController: TServiceController; override;
    class Procedure CreateService;
  end;

var
  RoYaService: TRoYaService;


implementation
{$R *.DFM}
uses   f_IMConsts;

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  RoYaService.Controller(CtrlCode);
end;

class procedure TRoYaService.CreateService;
begin
  Application.Initialize;
  Application.CreateForm(TRoYaService, RoYaService);
  Application.Run;
end;

function TRoYaService.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TRoYaService.ServiceExecute(Sender: TService);
begin
  fRobots.Start;
  while not Terminated do
    ServiceThread.ProcessRequests(True);
  fRobots.Stop;
end;

procedure TRoYaService.ServiceCreate(Sender: TObject);
begin
  fRobots:=TIMRobots.Create(mkService);
end;

procedure TRoYaService.ServiceDestroy(Sender: TObject);
begin
  fRobots.Free;
end;

procedure TRoYaService.ServiceAfterInstall(Sender: TService);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create(KEY_READ or KEY_WRITE);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey(coKeyRegService+coRoYaService, false) then
    begin
      Reg.WriteString('Description', 'Providers connect RoYa to Yahoo Messenger , ...');
      Reg.WriteExpandString(coImagePath,CureentApp+' -'+coSwitchService);
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

end.
