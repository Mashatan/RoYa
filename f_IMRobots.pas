{
   File: f_IMRobots

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
unit f_IMRobots;
interface
{$I RoYa.inc}
uses windows,Classes,ExtCtrls,f_IMCommon,f_IMDatabase,f_IMAccount,
     f_SharedMemory,f_IMConsts
     ,f_IMWebService
     {$ifdef ryAlice},f_IMAlice{$endif},
     f_IMRobotItem,f_IMProcess,f_IMWatcher,f_IMBuffer,f_IMCryptography;
type
  TIMRobots=Class(TCollection)
  private
    fWebService:TIMWebService;
    fWebSrvBuffer:TIMBuffer;
    fProcess:TIMProcess;
    {$ifdef ryAlice}
    fAlice:TIMAlice;
    fAliceBuffer:TIMBuffer;
    {$endif}
    fWatcher:TIMWatcher;
    fInputBuffer:TIMBuffer;
    fIsActive:boolean;
    fUpdateTimer:TTimer;
    fShareMemory:TSharedMemStringList;
    fCrypto:TCryptoGraphy;
    fMode:TModeKind;
    function GetItem(Index: Integer): TIMRobotItem;
    procedure SetItem(Index: Integer; const Value: TIMRobotItem);
    procedure doUpdateTimer(Sender:TObject);
  protected
  public
    constructor Create(pMode:TModeKind);
    destructor  Destroy;override;
    Function   Start:boolean;
    Function   Stop:boolean;
    function    Add: TIMRobotItem;
    function    FindItemID(ID: Integer): TIMRobotItem;
    function    Insert(Index: Integer): TIMRobotItem;
    property    Items[Index: Integer]: TIMRobotItem read GetItem write SetItem; default;
    procedure   LoadDB;
    function    IsUserExist:boolean;
    procedure   SaveDB(Account:TIMAccount);
  end;

implementation
uses SysUtils,DateUtils,f_IMGeneralInfo,f_RoYaDefines, DB;

constructor TIMRobots.Create(pMode:TModeKind);
begin
  inherited Create(TIMRobotItem);
  fMode := pMode;
  fIsActive:=false;
  fShareMemory:=TSharedMemStringList.Create(coKeyShare,1000);
  fUpdateTimer:=TTimer.Create(nil);
  fUpdateTimer.Enabled:=false;
  fUpdateTimer.Interval:=200;
  fUpdateTimer.OnTimer:=doUpdateTimer;
  fCrypto:=TCryptoGraphy.Create;
end;

destructor TIMRobots.Destroy;
begin
  fUpdateTimer.Free;
  fShareMemory.Free;
  fCrypto.Free;
  inherited ;
End;


Function TIMRobots.Start:Boolean;
var
  vCount:Integer;
begin
  result:=false;
  if fIsActive or not IsUserExist or ( fMode <> _GeneralInfo.Mode ) then
    exit;
  fWebSrvBuffer:=TIMBuffer.Create;
  fWebService:=TIMWebService.Create(fWebSrvBuffer);
  fWebService.FreeOnTerminate:=true;
  {$ifdef ryAlice}
  fAliceBuffer:=TIMBuffer.Create; // Don't Free Buffer
  fAlice:=TIMAlice.Create(fAliceBuffer);
  fAlice.FreeOnTerminate:=true;
  {$endif}
  fInputBuffer:=TIMBuffer.Create;
  fWatcher:=TIMWatcher.Create;
  fProcess:=TIMProcess.Create(fInputBuffer{$ifdef ryAlice},fAliceBuffer{$endif},fWebSrvBuffer);
  LoadDB;
  for vCount:=0 to self.Count-1 do
      self.Items[vCount].Start;
  fIsActive:=true;
  fUpdateTimer.Enabled:=true;
  fShareMemory.Flush;
  _Logger.Add('Robots Started',lsInformation);
  result:=self.Count>0;
end;

Function TIMRobots.Stop:Boolean;
var
  con:Integer;
begin
  result:=false;
  if ( fMode <> _GeneralInfo.Mode ) then
    exit;
  fUpdateTimer.Enabled:=false;
  for con:=0 to self.Count-1 do begin
    SaveDB(self.Items[con].Account);
    self.Items[con].Stop;
  end;
  fWatcher.Free;
  if fProcess <> nil then
    fProcess.Terminate;
  sleep(500);
  if Assigned(fInputBuffer) then
    fInputBuffer.Free;
  while Self.Count>0 do
    Self.Delete(0);
  {$ifdef ryAlice}
  if Assigned(fAlice) then
    fAlice.Terminate;
  sleep(500);
  {$endif}
  fWebSrvBuffer.Free;
  if Assigned(fWebService) then
    fWebService.Terminate;
  sleep(500);
  fIsActive:=false;
  fShareMemory.Flush;
  _Logger.Add('Robots Stoped',lsInformation);
  result:=true;
end;




procedure TIMRobots.LoadDB();
var
  vItem:TIMRobotItem;
  vQuery:TIMQuery;
  vAccount:TIMAccount;
begin
  vQuery:=_Database.CreateQuery;
  vQuery.Close;
  vQuery.SQL.Text:=coCollectionSQLSelect;
  vQuery.Open;
  try
    while not vQuery.Eof do begin
      vAccount:=TIMAccount.Create;
      vAccount.AccountID:=           vQuery.FieldByName(coAccountID).AsInteger;
      vAccount.RobotID:=             vQuery.FieldByName(coRobotID).AsString;
      vAccount.Password:=            fCrypto.Decrypt(vQuery.FieldByName(copassword).AsString);
      vAccount.StatusMessage:=       vQuery.FieldByName(coStatus).AsString;
      vAccount.Host:=                vQuery.FieldByName(coHost).AsString;
      vAccount.Port:=                vQuery.FieldByName(coPort).AsString;
      vAccount.Owner:=               vQuery.FieldByName(coOwner).AsString;
      vAccount.Invisiable:=          vQuery.FieldByName(coInvisiable).AsBoolean;
      vAccount.HTTPProxy:=           vQuery.FieldByName(coHTTPProxy).AsBoolean;
      vAccount.HTTPProxyHost:=       vQuery.FieldByName(coHTTPProxyHost).AsString;
      vAccount.HTTPProxyPort:=       vQuery.FieldByName(coHTTPProxyPort).AsString;
      vAccount.Provider:=  TProvider(vQuery.FieldByName(coProviderType).AsInteger);
      vAccount.TotalBlockMessageNo:= vQuery.FieldByName(coTotalBlockMessageNo).AsInteger;
      vAccount.TotalMessageNo:=      vQuery.FieldByName(coTotalMessageNo).AsInteger;
      vAccount.TotalDuration:=       vQuery.FieldByName(coTotalDuration).AsInteger;
      vAccount.FirstEnter:=Now;
      vItem:=self.Add;
      vItem.Init(vAccount,fWatcher,fInputBuffer);
      vQuery.Next;
    end;
  finally
   vQuery.Close;
   vQuery.Free;
  end;
end;


procedure TIMRobots.SaveDB(Account:TIMAccount);
var
  vQuery:TIMQuery;
begin
  vQuery:=_Database.CreateQuery;
  try
    Account.TotalDuration:=Account.TotalDuration+SecondsBetween(Account.FirstEnter,Now);
    vQuery.SQL.Text:=_Database.ParametersFill(coStoreRetrieveInfoSQLUpdate,
              [coAccountID,coTotalBlockMessageNo,coTotalMessageNo,coTotalDuration],
              [Account.AccountID,Account.TotalBlockMessageNo,Account.TotalMessageNo,Account.TotalDuration]);
    vQuery.ExecSQL;
  finally
    vQuery.Free;
  end;
end;


function TIMRobots.Add;
begin
   result := TIMRobotItem(inherited Add);
end;

function TIMRobots.FindItemID(ID: Integer): TIMRobotItem;
begin
     result := TIMRobotItem(inherited FindItemID(ID));
end;

function TIMRobots.GetItem(Index: Integer): TIMRobotItem;
begin
     result := TIMRobotItem(inherited Items[Index]);
end;

function TIMRobots.Insert;
begin
     result := TIMRobotItem(inherited Insert(Index));
end;

procedure TIMRobots.SetItem(Index: Integer; const Value: TIMRobotItem);
begin
     inherited Items[Index] := Value;
end;

procedure TIMRobots.doUpdateTimer(Sender: TObject);
var
  vCount:Integer;
  vSum:String;
  vAccount:TIMAccount;

begin
  fShareMemory.StringList.Clear;
  for vCount:=0 to self.Count-1 do begin
     vSum:='';
     vAccount:=self.Items[vCount].Account;
     vSum:=vAccount.RobotID+',';
     vSum:=vSum+vAccount.Owner+',';
     vSum:=vSum+IntToStr(word(vAccount.Provider))+',';
     vSum:=vSum+IntToStr(word(vAccount.Status))+',';
     vSum:=vSum+IntToStr(vAccount.TotalMessageNo)+',';
     vSum:=vSum+IntToStr(vAccount.TotalBlockMessageNo)+',';
     vSum:=vSum+IntToStr(vAccount.TotalDuration+SecondsBetween(Now,vAccount.StartTime));
     fShareMemory.StringList.Add(vSum);
  end;
  if self.Count > 0 then
    fShareMemory.SetStringList(SHARESTARTPOINT);
end;

function TIMRobots.IsUserExist: boolean;
var
  vQuery:TIMQuery;
begin
  vQuery:=_Database.CreateQuery;
  vQuery.Close;
  vQuery.SQL.Text:=coCollectionSQLSelect;
  vQuery.Open;
  result:=not vQuery.IsEmpty;
  vQuery.Free;
end;

end.
