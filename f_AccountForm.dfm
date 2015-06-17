object AccountForm: TAccountForm
  Left = 335
  Top = 240
  BorderStyle = bsDialog
  Caption = 'Accounts'
  ClientHeight = 279
  ClientWidth = 479
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShortCut = FormShortCut
  DesignSize = (
    479
    279)
  PixelsPerInch = 96
  TextHeight = 13
  object AuthenticationGroup: TGroupBox
    Left = 172
    Top = 11
    Width = 292
    Height = 228
    TabOrder = 1
    object PasswordLabel: TLabel
      Left = 13
      Top = 101
      Width = 54
      Height = 13
      Caption = 'Password'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object UsernameLabel: TLabel
      Left = 13
      Top = 70
      Width = 58
      Height = 13
      Caption = 'Username'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object OwnerLabel1: TLabel
      Left = 13
      Top = 136
      Width = 36
      Height = 13
      Caption = 'Owner'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object StatusLabel: TLabel
      Left = 13
      Top = 172
      Width = 31
      Height = 13
      Caption = 'Status'
    end
    object ProviderLabel: TLabel
      Left = 13
      Top = 37
      Width = 48
      Height = 13
      Caption = 'Provider'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object UsernameEdit: TDBEdit
      Left = 80
      Top = 66
      Width = 189
      Height = 21
      DataField = 'RobotID'
      DataSource = DM.AccountsDS
      TabOrder = 2
    end
    object OwnerEdit: TDBEdit
      Left = 80
      Top = 132
      Width = 189
      Height = 21
      DataField = 'Owner'
      DataSource = DM.AccountsDS
      TabOrder = 4
    end
    object StatusEdit: TDBEdit
      Left = 80
      Top = 168
      Width = 189
      Height = 21
      DataField = 'Status'
      DataSource = DM.AccountsDS
      TabOrder = 5
    end
    object InvisibleChk: TDBCheckBox
      Left = 12
      Top = 202
      Width = 150
      Height = 17
      Caption = 'Login under Invisible Mode'
      DataField = 'Invisiable'
      DataSource = DM.AccountsDS
      TabOrder = 6
      ValueChecked = 'True'
      ValueUnchecked = 'False'
    end
    object ProviderComboBox: TDBLookupComboBox
      Left = 80
      Top = 33
      Width = 189
      Height = 21
      DataField = 'ProviderID'
      DataSource = DM.AccountsDS
      KeyField = 'ProviderID'
      ListField = 'Name'
      ListSource = DM.ProviderDS
      TabOrder = 1
    end
    object ActiveChk: TDBCheckBox
      Left = 12
      Top = 12
      Width = 75
      Height = 17
      Caption = 'Active'
      DataField = 'Active'
      DataSource = DM.AccountsDS
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      ValueChecked = 'True'
      ValueUnchecked = 'False'
    end
    object PasswordEdit: TEdit
      Left = 80
      Top = 97
      Width = 189
      Height = 21
      PasswordChar = '*'
      TabOrder = 3
      Text = 'PasswordEdit'
    end
  end
  object CloseBtn: TButton
    Left = 391
    Top = 249
    Width = 79
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = 'Close'
    ModalResult = 2
    TabOrder = 7
  end
  object AccountGrid: TDBGrid
    Left = 6
    Top = 10
    Width = 147
    Height = 229
    DataSource = DM.AccountsDS
    Options = [dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
    TabOrder = 0
    TitleFont.Charset = ANSI_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'RobotID'
        Width = 130
        Visible = True
      end>
  end
  object CancelBtn: TButton
    Left = 267
    Top = 249
    Width = 57
    Height = 21
    Action = Act_DataSetCancel
    Anchors = [akRight, akBottom]
    TabOrder = 6
  end
  object InsertBtn: TButton
    Left = 7
    Top = 249
    Width = 57
    Height = 21
    Action = Act_DataSetInsert
    Anchors = [akRight, akBottom]
    TabOrder = 2
  end
  object EditBtn: TButton
    Left = 72
    Top = 249
    Width = 57
    Height = 21
    Action = Act_DataSetEdit
    Anchors = [akRight, akBottom]
    TabOrder = 3
  end
  object DeleteBtn: TButton
    Left = 137
    Top = 249
    Width = 57
    Height = 21
    Action = Act_DataSetDelete
    Anchors = [akRight, akBottom]
    TabOrder = 4
  end
  object PostBtn: TButton
    Left = 202
    Top = 249
    Width = 57
    Height = 21
    Action = Act_DataSetPost
    Anchors = [akRight, akBottom]
    TabOrder = 5
  end
  object ActionList: TActionList
    Left = 110
    Top = 52
    object Act_DataSetPost: TDataSetPost
      Category = 'Dataset'
      Caption = 'Post'
      DataSource = DM.AccountsDS
    end
    object Act_DataSetInsert: TDataSetInsert
      Category = 'Dataset'
      Caption = 'Insert'
      DataSource = DM.AccountsDS
    end
    object Act_DataSetCancel: TDataSetCancel
      Category = 'Dataset'
      Caption = 'Cancel'
      DataSource = DM.AccountsDS
    end
    object Act_DataSetEdit: TDataSetEdit
      Category = 'Dataset'
      Caption = 'Edit'
      DataSource = DM.AccountsDS
    end
    object Act_DataSetDelete: TDataSetDelete
      Category = 'Dataset'
      Caption = 'Delete'
      DataSource = DM.AccountsDS
    end
  end
end
