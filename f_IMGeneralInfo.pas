{
   File: f_IMGeneralInfo

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
unit f_IMGeneralInfo;

interface
uses SysUtils,DateUtils,DB,f_IMConsts,f_IMDatabase;
type
  TIMGeneralInfo=class(TObject)
  private
    fFirstEnter:TDateTime;
    Function  GetData(pQuery:TIMQuery;pName:String;pDefault:Variant;pType:TFieldType):Variant;
    Procedure SetData(pQuery:TIMQuery;pName:String;pValue:Variant);
    function GetCurrentDuration:Cardinal;
  public
    TimeoutIdle:Byte; // Minute
    TimeoutConnection:Byte; // Secoend
    TimeoutFlush:Byte;//Minute
    DelayMsg:Byte;
    DelayCpu:Byte;
    LimitCPU:Byte;
    LimitMsg:Byte;
    RestrictionMsg:TRestrictionKind;
    AIntervalRecMsg,
    MIntervalRecMsg :real;
    UserTimerInterval:Word;
    TotalBlockMessageNo:Cardinal;
    TotalMessageNo:Cardinal;
    TotalDuration:Cardinal;
    Mode:TModeKind;
    property CurrentDuration:Cardinal read GetCurrentDuration;
    Constructor Create;
    Destructor Destroy;override;
    procedure SaveDB;
    procedure LoadDB;
  end;
var
  _GeneralInfo:TIMGeneralInfo;
  
implementation
uses f_IMCommon;
{ TIMGeneralInfo }

constructor TIMGeneralInfo.Create;
begin
  DelayMsg:=2;
  DelayCpu:=2;
  LimitCPU:=100;
  LimitMsg:=10;
  TimeoutIdle:=1;
  TimeoutFlush:=2;
  UserTimerInterval:=1000;
  RestrictionMsg:=irAutomatic;
  Mode:=mkApplication;
  LoadDB;
end;

destructor TIMGeneralInfo.Destroy;
begin
  SaveDB;
  inherited;
end;

procedure TIMGeneralInfo.SetData(pQuery: TIMQuery; pName: String; pValue: Variant);
begin
  pQuery.SQL.Text:=_Database.ParametersFill(coGeneralInfoSQLSelect,[coName],[pName]);
  pQuery.Open;
  if pQuery.IsEmpty then
    pQuery.SQL.Text:=_Database.ParametersFill(coGeneralInfoSQLInsert,[coName,coValue],[pName,PValue])
  else
    pQuery.SQL.Text:=_Database.ParametersFill(coGeneralInfoSQLUpdate,[coValue,coName],[pValue,pName]);
  pQuery.Close;
  pQuery.ExecSQL;
end;

function TIMGeneralInfo.GetData(pQuery: TIMQuery; pName: String;pDefault:Variant;pType:TFieldType): Variant;
begin
   pQuery.Close;
   pQuery.SQL.Text:=_Database.ParametersFill(coGeneralInfoSQLSelect,[coName],[pName]);
   pQuery.Open;
   result:=pDefault;
   if not pQuery.IsEmpty then begin
     case pType of
       ftWord,ftInteger: result:=pQuery.FieldByName(coValue).AsInteger;
       ftString: result:=pQuery.FieldByName(coValue).AsString;
       ftDateTime:result:=pQuery.FieldByName(coValue).AsDateTime;
     else
       result:=pQuery.FieldByName(coValue).AsVariant;
     end;
   end;
   pQuery.Close;
end;

procedure TIMGeneralInfo.LoadDB;
var
  vQuery:TIMQuery;
begin
  vQuery:=_Database.CreateQuery;
  fFirstEnter:=Now;
  UserTimerInterval:= GetData(vQuery,coUserTimerInterval,UserTimerInterval,ftInteger);
  TotalBlockMessageNo:= GetData(vQuery,coTotalBlockMessageNo,TotalBlockMessageNo,ftInteger);
  TotalMessageNo:= GetData(vQuery,coTotalMessageNo,TotalMessageNo,ftInteger);
  TotalDuration:= GetData(vQuery,coTotalDuration,TotalDuration,ftInteger);
  TimeoutIdle:= GetData(vQuery,coTimeoutIdle,TimeoutIdle,ftInteger);
  TimeoutConnection:= GetData(vQuery,coTimeoutConnection,TimeoutConnection,ftInteger);
  TimeoutFlush:= GetData(vQuery,coTimeoutFlush,TimeoutFlush,ftInteger);
  DelayMsg:= GetData(vQuery,coDelayMsg,DelayMsg,ftInteger);
  DelayCpu:= GetData(vQuery,coDelayCpu,DelayCpu,ftInteger);
  LimitCPU:= GetData(vQuery,coLimitCPU,LimitCPU,ftInteger);
  LimitMsg:= GetData(vQuery,coLimitMsg,LimitMsg,ftInteger);
  RestrictionMsg:= GetData(vQuery,coRestrictionMsg,RestrictionMsg,ftInteger);
  AIntervalRecMsg:= GetData(vQuery,coAIntervalRecMsg,AIntervalRecMsg,ftFloat);
  MIntervalRecMsg:= GetData(vQuery,coMIntervalRecMsg,MIntervalRecMsg,ftFloat);
  Mode:= GetData(vQuery,coRunMode,Mode,ftInteger);
  vQuery.Free;
end;

procedure TIMGeneralInfo.SaveDB;
var
  vQuery:TIMQuery;
begin
  vQuery:=_Database.CreateQuery;
  vQuery.SQL.Text:='BEGIN;';
  vQuery.ExecSQL;
  TotalDuration:=CurrentDuration;
  SetData(vQuery,coUserTimerInterval,UserTimerInterval);
  SetData(vQuery,coTotalBlockMessageNo,TotalBlockMessageNo);
  SetData(vQuery,coTotalMessageNo,TotalMessageNo);
  SetData(vQuery,coTotalDuration,TotalDuration);
  SetData(vQuery,coTimeoutIdle,TimeoutIdle);
  SetData(vQuery,coTimeoutConnection,TimeoutConnection);
  SetData(vQuery,coTimeoutFlush,TimeoutFlush);
  SetData(vQuery,coDelayMsg,DelayMsg);
  SetData(vQuery,coDelayCpu,DelayCpu);
  SetData(vQuery,coLimitCPU,LimitCPU);
  SetData(vQuery,coLimitMsg,LimitMsg);
  setData(vQuery,coRestrictionMsg,RestrictionMsg);
  SetData(vQuery,coAIntervalRecMsg,AIntervalRecMsg);
  SetData(vQuery,coMIntervalRecMsg,MIntervalRecMsg);
  SetData(vQuery,coRunMode,Mode);
  vQuery.Close;
  vQuery.SQL.Text:='END;';
  vQuery.ExecSQL;
  vQuery.Free;
end;

function TIMGeneralInfo.GetCurrentDuration: Cardinal;
begin
  result:=TotalDuration+SecondsBetween(fFirstEnter,Now);
end;

initialization
  _GeneralInfo:=TIMGeneralInfo.Create;
finalization
  _GeneralInfo.Free;
end.
