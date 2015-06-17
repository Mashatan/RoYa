object SettingForm: TSettingForm
  Left = 334
  Top = 270
  BorderStyle = bsDialog
  Caption = 'SettingForm'
  ClientHeight = 108
  ClientWidth = 305
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  DesignSize = (
    305
    108)
  PixelsPerInch = 96
  TextHeight = 13
  object MiscGroup: TGroupBox
    Left = 11
    Top = 10
    Width = 284
    Height = 57
    TabOrder = 0
    object ModeLabel: TLabel
      Left = 8
      Top = 16
      Width = 36
      Height = 13
      Caption = 'Mode : '
    end
    object ModeComboBox: TComboBox
      Left = 86
      Top = 16
      Width = 145
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 0
      Text = 'Application'
      Items.Strings = (
        'Application'
        'Service')
    end
  end
  object CancelBtn: TButton
    Left = 208
    Top = 78
    Width = 87
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object OKBtn: TButton
    Left = 110
    Top = 78
    Width = 87
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
end
