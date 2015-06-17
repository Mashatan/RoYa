object DM: TDM
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Left = 445
  Top = 265
  Height = 280
  Width = 273
  object ProviderDS: TDataSource
    AutoEdit = False
    DataSet = ProviderTable
    Left = 104
    Top = 118
  end
  object ProviderTable: TASQLite3Table
    AutoCommit = False
    SQLiteDateFormat = False
    Connection = DBConnection
    MaxResults = 0
    StartResult = 0
    TypeLess = False
    SQLCursor = True
    ReadOnly = False
    UniDirectional = False
    TableName = 'Providers'
    PrimaryAutoInc = False
    Left = 26
    Top = 122
  end
  object DBConnection: TASQLite3DB
    TimeOut = 0
    CharacterEncoding = 'UTF8'
    Database = '.db'
    DefaultExt = '.db'
    Version = '3.5.5'
    DriverDLL = 'Nothing.dll'
    Connected = False
    MustExist = False
    ExecuteInlineSQL = False
    Left = 28
    Top = 10
  end
  object AccountsDS: TDataSource
    AutoEdit = False
    DataSet = AccountsTable
    Left = 112
    Top = 68
  end
  object AccountsTable: TASQLite3Table
    AutoCommit = False
    SQLiteDateFormat = False
    Connection = DBConnection
    MaxResults = 0
    StartResult = 0
    TypeLess = False
    SQLCursor = True
    ReadOnly = False
    UniDirectional = False
    TableName = 'Accounts'
    PrimaryAutoInc = False
    Left = 36
    Top = 68
  end
end
