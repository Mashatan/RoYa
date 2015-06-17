{
   File: RoYa.dpr

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
program RoYa;
{$Include RoYa.inc}
uses
  FastMM4,
  Windows,
  SysUtils,
  f_MainForm in 'f_MainForm.pas' {MainForm},
  f_DataModule in 'f_DataModule.pas' {DM: TDataModule},
  f_AccountForm in 'f_AccountForm.pas' {AccountForm},
  f_ProviderForm in 'f_ProviderForm.pas' {ProviderForm},
  f_AboutForm in 'f_AboutForm.pas' {AboutForm},
  f_AIVariables in 'Alice\f_AIVariables.pas',
  f_AIAIMLLoader in 'Alice\f_AIAIMLLoader.pas',
  f_AIBotLoader in 'Alice\f_AIBotLoader.pas',
  f_AIElementFactory in 'Alice\f_AIElementFactory.pas',
  f_AIElements in 'Alice\f_AIElements.pas',
  f_AIPatternMatcher in 'Alice\f_AIPatternMatcher.pas',
  f_AITemplateProcessor in 'Alice\f_AITemplateProcessor.pas',
  f_AIUtils in 'Alice\f_AIUtils.pas',
  f_SharedMemory in 'f_SharedMemory.pas',
  f_IMAccount in 'f_IMAccount.pas',
  f_IMAlice in 'f_IMAlice.pas',
  f_IMBroadcast in 'f_IMBroadcast.pas',
  f_IMBuffer in 'f_IMBuffer.pas',
  f_IMCommon in 'f_IMCommon.pas',
  f_IMConsts in 'f_IMConsts.pas',
  f_IMContactInfo in 'f_IMContactInfo.pas',
  f_IMDatabase in 'f_IMDatabase.pas',
  f_IMGeneralInfo in 'f_IMGeneralInfo.pas',
  f_IMNode in 'f_IMNode.pas',
  f_IMProcess in 'f_IMProcess.pas',
  f_IMProtection in 'f_IMProtection.pas',
  f_IMProtocol in 'f_IMProtocol.pas',
  f_IMPythonScript in 'f_IMPythonScript.pas',
  f_IMRobotItem in 'f_IMRobotItem.pas',
  f_IMRobots in 'f_IMRobots.pas',
  f_IMScript in 'f_IMScript.pas',
  f_IMTransmitPacket in 'f_IMTransmitPacket.pas',
  f_IMWatcher in 'f_IMWatcher.pas',
  f_IMYahooContactInfo in 'f_IMYahooContactInfo.pas',
  f_IMYahooProtocol in 'f_IMYahooProtocol.pas',
  f_LoadDLL in 'f_LoadDLL.pas',
  f_RoYaDefines in 'f_RoYaDefines.pas',
  f_SettingForm in 'f_SettingForm.pas' {SettingForm},
  f_IMCryptography in 'f_IMCryptoGraphy.pas',
  f_MainSrv in 'f_MainSrv.pas' {RoYaService: TService},
  f_IMWebService in 'f_IMWebService.pas',
  f_IMCore in 'f_IMCore.pas',
  f_SrvGlobalWeather in 'f_SrvGlobalWeather.pas';

{$R *.res}
var
  hMutex: THandle;

function FindSwitch(const Switch: string): Boolean;
begin
  Result := FindCmdLineSwitch(Switch, ['-', '/' ,' '], True);
end;
begin
  if FindSwitch(coSwitchService) or FindSwitch('install') or FindSwitch('uninstall') then begin
    TRoYaService.CreateService;
  end else begin
    hMutex := CreateMutex(nil, False, coSingleExec);
    try
      if WaitForSingleObject(hMutex, 0) <> WAIT_TIMEOUT then Begin
        try
          TMainForm.CreateApplication;
        finally
          ReleaseMutex(hMutex);
        end;
      End;
    finally
      CloseHandle(hMutex);
    end;
  end;
end.
