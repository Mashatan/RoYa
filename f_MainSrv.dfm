object RoYaService: TRoYaService
  OldCreateOrder = False
  OnCreate = ServiceCreate
  OnDestroy = ServiceDestroy
  DisplayName = 'RoYa'
  AfterInstall = ServiceAfterInstall
  OnExecute = ServiceExecute
  Left = 326
  Top = 243
  Height = 150
  Width = 215
end
