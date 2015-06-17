object ProviderForm: TProviderForm
  Left = 312
  Top = 214
  BorderStyle = bsDialog
  Caption = 'Providers'
  ClientHeight = 409
  ClientWidth = 515
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
    515
    409)
  PixelsPerInch = 96
  TextHeight = 13
  object CancelBtn: TButton
    Left = 267
    Top = 379
    Width = 57
    Height = 21
    Action = Act_DataSetCancel
    Anchors = [akRight, akBottom]
    TabOrder = 6
  end
  object CloseBtn: TButton
    Left = 429
    Top = 379
    Width = 79
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = 'Close'
    Default = True
    ModalResult = 1
    TabOrder = 7
  end
  object ProvicerGroupBox: TGroupBox
    Left = 162
    Top = 10
    Width = 345
    Height = 359
    TabOrder = 1
    object ProvicerTypeLabel: TLabel
      Left = 186
      Top = 23
      Width = 28
      Height = 13
      Caption = 'Type'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object NameLabel: TLabel
      Left = 13
      Top = 24
      Width = 32
      Height = 13
      Caption = 'Name'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object ConnectionGroup: TGroupBox
      Left = 14
      Top = 48
      Width = 322
      Height = 79
      TabOrder = 2
      object HostLabel: TLabel
        Left = 17
        Top = 23
        Width = 26
        Height = 13
        Caption = 'Host'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object PortLabel: TLabel
        Left = 17
        Top = 52
        Width = 24
        Height = 13
        Caption = 'Port'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object HostCombo: TDBComboBox
        Left = 86
        Top = 16
        Width = 145
        Height = 21
        DataField = 'Host'
        DataSource = DM.ProviderDS
        ItemHeight = 13
        Items.Strings = (
          'scsa.msg.yahoo.com'
          'scsb.msg.yahoo.com'
          'scsc.msg.yahoo.com')
        TabOrder = 0
      end
      object PortEdit: TDBEdit
        Left = 86
        Top = 46
        Width = 121
        Height = 21
        DataField = 'Port'
        DataSource = DM.ProviderDS
        TabOrder = 1
      end
    end
    object ProxyGroup: TGroupBox
      Left = 14
      Top = 134
      Width = 322
      Height = 54
      TabOrder = 4
      object HttpProxyHostLabel: TLabel
        Left = 11
        Top = 18
        Width = 40
        Height = 26
        AutoSize = False
        Caption = 'Sarver Name'
        WordWrap = True
      end
      object HttpProxyPortLabel: TLabel
        Left = 216
        Top = 18
        Width = 36
        Height = 27
        AutoSize = False
        Caption = 'Server Port'
        WordWrap = True
      end
      object HttpProxyHostEdit: TDBEdit
        Left = 52
        Top = 21
        Width = 155
        Height = 21
        DataField = 'HttpProxyHost'
        DataSource = DM.ProviderDS
        TabOrder = 0
      end
      object HttpProxyPortEdit: TDBEdit
        Left = 252
        Top = 21
        Width = 55
        Height = 21
        DataField = 'HttpProxyPort'
        DataSource = DM.ProviderDS
        TabOrder = 1
      end
    end
    object SocksGroup: TGroupBox
      Left = 14
      Top = 198
      Width = 322
      Height = 145
      TabOrder = 5
      object SocksHostLabel: TLabel
        Left = 11
        Top = 18
        Width = 40
        Height = 26
        AutoSize = False
        Caption = 'Sarver Name'
        WordWrap = True
      end
      object SocksPortLabel: TLabel
        Left = 214
        Top = 16
        Width = 36
        Height = 27
        AutoSize = False
        Caption = 'Server Port'
        WordWrap = True
      end
      object Ver4Radio: TRadioButton
        Left = 12
        Top = 60
        Width = 47
        Height = 17
        Caption = 'Ver 4'
        TabOrder = 2
        OnClick = ChkHTTPCenter
      end
      object Ver5Radio: TRadioButton
        Left = 12
        Top = 84
        Width = 47
        Height = 17
        Caption = 'Ver 5'
        Checked = True
        TabOrder = 3
        TabStop = True
        OnClick = ChkHTTPCenter
      end
      object AuthGroup: TGroupBox
        Left = 69
        Top = 52
        Width = 240
        Height = 81
        TabOrder = 5
        object AuthUsernameLabel: TLabel
          Left = 17
          Top = 23
          Width = 48
          Height = 13
          Caption = 'Username'
        end
        object AuthPasswordLabel: TLabel
          Left = 17
          Top = 52
          Width = 46
          Height = 13
          Caption = 'Password'
        end
        object AuthUsernameEdit: TDBEdit
          Left = 73
          Top = 19
          Width = 155
          Height = 21
          DataField = 'SocksProxyUsername'
          DataSource = DM.ProviderDS
          TabOrder = 0
        end
        object AuthPasswordEdit: TDBEdit
          Left = 73
          Top = 49
          Width = 155
          Height = 21
          DataField = 'SocksProxyPassword'
          DataSource = DM.ProviderDS
          TabOrder = 1
        end
      end
      object AuthChk: TDBCheckBox
        Left = 78
        Top = 48
        Width = 93
        Height = 17
        Caption = 'Authentication'
        DataField = 'SocksProxyAuth'
        DataSource = DM.ProviderDS
        TabOrder = 4
        ValueChecked = 'True'
        ValueUnchecked = 'False'
        OnClick = ChkHTTPCenter
      end
      object SocksHostEdit: TDBEdit
        Left = 54
        Top = 23
        Width = 155
        Height = 21
        DataField = 'SocksProxyHost'
        DataSource = DM.ProviderDS
        TabOrder = 0
      end
      object SocksPortEdit: TDBEdit
        Left = 254
        Top = 21
        Width = 55
        Height = 21
        DataField = 'SocksProxyPort'
        DataSource = DM.ProviderDS
        TabOrder = 1
      end
    end
    object ProviderTypeCombo: TComboBox
      Left = 219
      Top = 20
      Width = 116
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 1
      Text = 'Yahoo'
      Items.Strings = (
        'Yahoo')
    end
    object HttpProxyChk: TDBCheckBox
      Left = 20
      Top = 134
      Width = 111
      Height = 13
      Caption = 'Enable HTTP Proxy'
      DataField = 'HttpProxy'
      DataSource = DM.ProviderDS
      TabOrder = 3
      ValueChecked = 'True'
      ValueUnchecked = 'False'
      OnClick = ChkHTTPCenter
    end
    object SocksChk: TDBCheckBox
      Left = 22
      Top = 196
      Width = 125
      Height = 17
      Caption = 'Enable SOCKS Proxy'
      DataField = 'SocksProxy'
      DataSource = DM.ProviderDS
      TabOrder = 6
      ValueChecked = 'True'
      ValueUnchecked = 'False'
      OnClick = ChkHTTPCenter
    end
    object NameEdit: TDBEdit
      Left = 52
      Top = 20
      Width = 121
      Height = 21
      DataField = 'Name'
      DataSource = DM.ProviderDS
      TabOrder = 0
    end
  end
  object InsertBtn: TButton
    Left = 7
    Top = 379
    Width = 57
    Height = 21
    Action = Act_DataSetInsert
    Anchors = [akRight, akBottom]
    TabOrder = 2
  end
  object EditBtn: TButton
    Left = 72
    Top = 379
    Width = 57
    Height = 21
    Action = Act_DataSetEdit
    Anchors = [akRight, akBottom]
    TabOrder = 3
  end
  object DeleteBtn: TButton
    Left = 137
    Top = 379
    Width = 57
    Height = 21
    Action = Act_DataSetDelete
    Anchors = [akRight, akBottom]
    TabOrder = 4
  end
  object PostBtn: TButton
    Left = 202
    Top = 379
    Width = 57
    Height = 21
    Action = Act_DataSetPost
    Anchors = [akRight, akBottom]
    TabOrder = 5
  end
  object ProviderGrid: TDBGrid
    Left = 6
    Top = 8
    Width = 147
    Height = 363
    DataSource = DM.ProviderDS
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
        FieldName = 'Name'
        Width = 130
        Visible = True
      end>
  end
  object ActionList: TActionList
    Left = 112
    Top = 32
    object Act_DataSetPost: TDataSetPost
      Category = 'Dataset'
      Caption = 'Post'
      DataSource = DM.ProviderDS
    end
    object Act_DataSetInsert: TDataSetInsert
      Category = 'Dataset'
      Caption = 'Insert'
      DataSource = DM.ProviderDS
    end
    object Act_DataSetCancel: TDataSetCancel
      Category = 'Dataset'
      Caption = 'Cancel'
      DataSource = DM.ProviderDS
    end
    object Act_DataSetEdit: TDataSetEdit
      Category = 'Dataset'
      Caption = 'Edit'
      DataSource = DM.ProviderDS
    end
    object Act_DataSetDelete: TDataSetDelete
      Category = 'Dataset'
      Caption = 'Delete'
      DataSource = DM.ProviderDS
    end
  end
end
