object MainForm: TMainForm
  Left = 377
  Top = 254
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'RoYa'
  ClientHeight = 264
  ClientWidth = 539
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 16
  object MainGroupBox: TGroupBox
    Left = 8
    Top = 14
    Width = 523
    Height = 241
    TabOrder = 0
    object ActionLabel: TLabel
      Left = 13
      Top = 16
      Width = 45
      Height = 16
      Caption = 'Status :'
    end
    object ActionVarLabel: TLabel
      Left = 64
      Top = 16
      Width = 103
      Height = 16
      AutoSize = False
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object OnlineStatusLabel: TLabel
      Left = 12
      Top = 48
      Width = 45
      Height = 16
      Caption = 'Online :'
    end
    object ModeLabel: TLabel
      Left = 299
      Top = 16
      Width = 40
      Height = 16
      Caption = 'Mode :'
    end
    object ModeVarLabel: TLabel
      Left = 345
      Top = 16
      Width = 103
      Height = 16
      AutoSize = False
      Font.Charset = ANSI_CHARSET
      Font.Color = clRed
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object OnlineStringGrid: TStringGrid
      Left = 12
      Top = 70
      Width = 499
      Height = 159
      ColCount = 7
      DefaultDrawing = False
      FixedCols = 0
      RowCount = 2
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
      TabOrder = 0
      OnDrawCell = OnlineStringGridDrawCell
      ColWidths = (
        94
        113
        76
        88
        93
        107
        93)
      RowHeights = (
        24
        24)
    end
  end
  object XPManifest1: TXPManifest
    Left = 140
    Top = 176
  end
  object ActionList: TActionList
    Left = 202
    Top = 158
    object Act_Start: TAction
      Caption = 'Start'
      ShortCut = 16467
      OnExecute = Act_StartExecute
    end
    object Act_Stop: TAction
      Caption = 'Stop'
      ShortCut = 16468
      OnExecute = Act_StopExecute
    end
    object Act_Account: TAction
      Caption = 'Account'
      ShortCut = 16449
      OnExecute = Act_AccountExecute
    end
    object Act_Provider: TAction
      Caption = 'Provider'
      ShortCut = 16464
      OnExecute = Act_ProviderExecute
    end
    object Act_Setting: TAction
      Caption = 'Setting'
      ShortCut = 16451
      OnExecute = Act_SettingExecute
    end
    object Act_Exit: TAction
      Caption = 'Exit'
      ShortCut = 16472
      OnExecute = Act_ExitExecute
    end
    object Act_About: TAction
      Caption = 'About'
      OnExecute = Act_AboutExecute
    end
    object Act_Install: TAction
      Caption = 'Install'
      OnExecute = Act_InstallExecute
    end
    object Act_Uninstall: TAction
      Caption = 'Uninstall'
      OnExecute = Act_UninstallExecute
    end
  end
  object MainMenu1: TMainMenu
    Left = 252
    Top = 186
    object Action1: TMenuItem
      Caption = 'Action'
      object Connect1: TMenuItem
        Action = Act_Start
      end
      object Disconnect1: TMenuItem
        Action = Act_Stop
      end
      object Install1: TMenuItem
        Action = Act_Install
      end
      object Uninstall1: TMenuItem
        Action = Act_Uninstall
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Connect2: TMenuItem
        Action = Act_Exit
      end
    end
    object Option1: TMenuItem
      Caption = 'Option'
      object Provider1: TMenuItem
        Action = Act_Provider
      end
      object Account1: TMenuItem
        Action = Act_Account
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object Setting1: TMenuItem
        Action = Act_Setting
      end
    end
    object Help1: TMenuItem
      Caption = 'Help'
      object About1: TMenuItem
        Action = Act_About
      end
    end
  end
end
