{
   File: f_IMWatcher

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
unit f_IMWatcher;
interface
uses Windows,Classes,f_IMCommon,ExtCtrls,IniFiles,f_RoYaDefines,f_IMAccount,f_IMNode,f_IMConsts,f_IMDatabase,SysUtils,f_IMContactInfo;

type
  TModeInsert=(miAll,miTimeout);
  TIMWatcher=class (TObject)
   private
     fIMList:THashedStringList;
     fPeriodFlush,fPeriodIdle:TDatetime;
     fMessageofSecoends:Word;
     fLockIdle,fLockValidUser:boolean;
     fQueryUser:TIMQuery;
     fMutex: THandle;
     function  SearchFromList(Username:string;Provider:TProvider):TIMNode;
     function  SearchFromTable(Username:string;Provider:TProvider):boolean;
     function  CalculateDelay(CPUsage,MSG:byte):Byte;
     procedure fill_(sl:TStrings);
   public
     Constructor Create;
     destructor Destroy;override;
     procedure FlushData(Mode:TModeInsert);
     function isValidUser(ContactInfo:TIMContactInfo;Account:TIMAccount):boolean;
     procedure Idle;
  end;

implementation
uses
  {f_IMCPUsage,DB,} f_IMGeneralInfo, DateUtils;

constructor TIMWatcher.Create;
begin
  inherited Create;
  fMutex := CreateMutex(nil, False, coWatcherGUID);
  fIMList:=THashedStringList.Create;
  fIMList.Sorted:=true;
  fQueryUser:=_Database.CreateQuery;
  _GeneralInfo.AIntervalRecMsg:=0;
  fMessageofSecoends:=0;
  fPeriodIdle:=Now;
  fPeriodFlush:=now;
  fLockIdle:=false;
  fLockValidUser:=false;
end;

destructor TIMWatcher.Destroy;
begin
  fIMList.Free;
  CloseHandle(fMutex);
  _Database.FreeQuery(fQueryUser);
  inherited Destroy;
end;

procedure TIMWatcher.Idle;
var
  tmp,idle,sec:Word;
begin
  if fLockIdle then
    exit;
  fLockIdle:=true;
  try
    idle:=MinutesBetween(Now,fPeriodIdle);
    if idle >= _GeneralInfo.TimeoutIdle then begin
      _Logger.Add('Idle ...',lsInformation);
      fPeriodIdle:=Now;
      sec:=SecondsBetween(Now,fPeriodIdle);
      if sec=0 then
        tmp:=0
      else
        tmp:= fMessageofSecoends div sec;
      _GeneralInfo.AIntervalRecMsg:=CalculateDelay(0,tmp);
      fMessageofSecoends:=0;
      if MinutesBetween(now,fPeriodFlush)>=_GeneralInfo.TimeoutFlush then begin
        _Logger.Add('Flush Data ...',lsInformation);
        FlushData(miTimeout);
        fPeriodFlush:=now;
      end;
    end;
  finally
    fLockIdle:=false;
  end;  
end;

function TIMWatcher.isValidUser(ContactInfo:TIMContactInfo;Account:TIMAccount):boolean;
var
  Node:TIMNode;
  IsRowExist:boolean;
  mNow:TDatetime;
begin
  result:=true;
  if ContactInfo.In_UserID='' then
    exit;
  result:=false;
  mNow:=now;
  Node:=SearchFromList(ContactInfo.In_UserID,Account.Provider);
  ContactInfo.In_Introduce:=teNormal;
  if Node=nil then begin
     IsRowExist:=SearchFromTable(ContactInfo.In_UserID,Account.Provider);
     Node:=TIMNode.create;
     Node.FirstSession:=mNow;
     Node.LastSession:=mNow;
     Node.TotalDuration:=0;
     Node.TotalMessageNo:=0;
     Node.LastMessageNo:=0;
     Node.Username:=ContactInfo.In_UserID;
     Node.IsNewSession := IsRowExist;
     Node.IsNewUser:= not IsRowExist;
     if IsRowExist then begin
       Node.FirstEnter:=fQueryUser.FieldByName(         coFirstEnter).AsFloat;
       Node.LastDuration:=fQueryUser.FieldByName(       coLastDuration).AsInteger;
       Node.TotalBlockMessageNo:=fQueryUser.FieldByName(coTotalBlockMessageNo).AsInteger;
       Node.TotalMessageNo:=fQueryUser.FieldByName(     coTotalMessageNo).AsInteger;
       Node.TotalDuration:=fQueryUser.FieldByName(      coTotalDuration).AsInteger;
       Node.Provider:= TProvider(fQueryUser.FieldByName(coProvider).AsInteger);
       Node.AliceInfo.Text:=fQueryUser.FieldByName(     coAliceInfo).AsString;
       Node.RoYaInfo.Text:=fQueryUser.FieldByName(      coRoYaInfo).AsString;
       fill_(Node.AliceInfo);
       fill_(Node.RoYaInfo);
       fQueryUser.Close;
       ContactInfo.In_Introduce:=teNewSession;
     end else begin
       Node.FirstEnter:=mNow;
       ContactInfo.In_Introduce:=teNewer;
     end;
     fIMList.AddObject(Node.Username,Node);
     result:=true;
  end else begin
    if  (_GeneralInfo.RestrictionMsg=irNone) or
        ((_GeneralInfo.RestrictionMsg=irAutomatic) and (SecondOf(mNow - Node.LastSession) >= _GeneralInfo.AIntervalRecMsg )) or
        ((_GeneralInfo.RestrictionMsg=irManual) and (SecondOf(mNow - Node.LastSession) >= _GeneralInfo.MIntervalRecMsg )) or
        (rsOwner in ContactInfo.In_RoYaState)  then begin
      result:=true;
    end else begin
      _Logger.Add('User : '+ ContactInfo.In_UserID + ' block message !',lsInformation);
      Node.TotalBlockMessageNo:=Node.TotalBlockMessageNo+1;
      _GeneralInfo.TotalBlockMessageNo:=_GeneralInfo.TotalBlockMessageNo+1;
      Account.TotalBlockMessageNo:=Account.TotalBlockMessageNo+1;
    end;
    Node.LastSession:=mNow;
  end;
  fMessageofSecoends:=fMessageofSecoends+1;
  Node.LastMessageNo:=Node.LastMessageNo+1;
  Node.TotalMessageNo:=Node.TotalMessageNo+1;
  _GeneralInfo.TotalMessageNo:=_GeneralInfo.TotalMessageNo+1;
  Account.TotalMessageNo:=Account.TotalMessageNo+1;
  ContactInfo.AliceInfo:=Node.AliceInfo;
  Node:=nil;
end;

function TIMWatcher.CalculateDelay(CPUsage, MSG: byte): Byte;
const
  Total_CPU=100;
var
  sum:real;
begin
  //sum:= (_GeneralInfo.DelayCpu * CPUsage) / (Total_CPU);
  sum:= {sum+} ((_GeneralInfo.DelayMsg * MSG) / (_GeneralInfo.LimitMsg));
  result:= round(sum);
end;

procedure TIMWatcher.fill_(sl:TStrings);
var
  con:Integer;
begin
   for con:= 0 to sl.Count-1 do
     if (sl.Strings[con]<>'')  and (sl.Strings[con][1]='_') then
       sl.Strings[con]:='';
end;


procedure TIMWatcher.FlushData(Mode:TModeInsert);
var
  QueryInsUpd,QueryExist:TIMQuery;
  Value:TIMNode;
  IsExist:Boolean;
  Idx:Integer;

  Function  CreateParam(pQuery:String) :String;
  begin
    result:=_Database.ParametersFill( pQuery,[
    coUsername,coLevel,coProvider,coFirstEnter,coFirstSession,coLastSession,
    coTotalDuration,coLastDuration,coTotalBlockMessageNo,coTotalMessageNo,
    coLastMessageNo,coAliceInfo,coRoYaInfo,coRank],
    [Value.Username,Value.Level,
    byte(Value.Provider),Value.FirstEnter,Value.FirstSession,
    Value.LastSession,Value.TotalDuration,Value.LastDuration,Value.TotalBlockMessageNo,
    Value.TotalMessageNo,Value.LastMessageNo,Value.AliceInfo.Text,Value.RoYaInfo.Text,
    Value.Rank]);

  end;

begin
  WaitForSingleObject(fMutex ,INFINITE);
  QueryExist:=_Database.CreateQuery;
  QueryInsUpd:=_Database.CreateQuery;
  Idx:=0;
  while  Idx < fIMList.Count do begin
    Value:=TIMNode(fIMList.Objects[Idx]);
    if  (Mode=miALL ) or ((Mode=miTimeout ) and (MinutesBetween(now,Value.LastSession) >= _GeneralInfo.TimeoutFlush)) then
    begin
      Value.LastDuration:=SecondsBetween(Value.FirstSession,Value.LastSession);
      Value.TotalDuration:=Value.TotalDuration+SecondsBetween(Value.FirstSession,Value.LastSession);
      QueryExist.Close;
      QueryExist.SQL.Text:=_Database.ParametersFill(coWatcherSQLSelect,['username','provider'],[Value.Username,byte(Value.Provider)]);
      QueryExist.Open;
      IsExist:=not QueryExist.IsEmpty;
      QueryExist.Close;

      if IsExist  then begin
        QueryInsUpd.SQL.Text:=CreateParam(coWatcherSQLUpdate);
      end else begin
        QueryInsUpd.SQL.Text:=CreateParam(coWatcherSQLInsert);
      end;
      QueryInsUpd.ExecSQL;
      QueryInsUpd.Close;
      fIMList.Delete(Idx);
      FreeAndNil(Value);
    end else
      Idx:=Idx+1;
  end; // While
  _Database.FreeQuery(QueryInsUpd);
  _Database.FreeQuery(QueryExist);
  ReleaseMutex(fMutex);
end;

function TIMWatcher.SearchFromList(Username: string;Provider:TProvider): TIMNode;
var
  idx:Integer;
begin
  result:=nil;
  idx:=fIMList.IndexOf(username);
  if idx>-1 then
    result:=TIMNode(fIMList.Objects[idx]);
end;

function TIMWatcher.SearchFromTable(username: string;Provider:TProvider): boolean;
begin
  fQueryUser.Close;
  fQueryUser.SQL.Text:=_Database.ParametersFill(coWatcherSQLSelect,[coUsername,coProvider],[username,byte(Provider)]);
  fQueryUser.Open;
  result:=not fQueryUser.IsEmpty;
end;


end.
