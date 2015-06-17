{
   File: f_IMDatabase

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
unit f_IMDatabase;

interface
uses db,f_IMConsts,Classes,
  QStrings , ASGSQLite3;
type
  TIMQuery=Class(TASQLite3Query)
  end;

  TIMDatabase=class(TObject)
    private
      fConnection:TASQLite3DB;
      fTableMain: TASQLite3Query;
      fTableAccounts: TASQLite3Table;
      fTableConfigurations: TASQLite3Table;
      fTableUsers: TASQLite3Table;
      function VarRecToStr( AVarRec : TVarRec ) : string;
      Constructor Create;
      Destructor Destroy;override;
    public
      Function  CreateQuery:TIMQuery;
      Procedure FreeQuery(Value:TIMQuery);
      function ParametersFill( pQuery:String; pNames: array of string;
            pValues: array of const):String;
  end;
var
  _Database:TIMDatabase;

implementation

uses SysUtils;


{ IMDatabase }

constructor TIMDatabase.Create;
begin
  fConnection:=TASQLite3DB.Create(nil);
  fConnection.Database:=coRoYaDBFile;
  fConnection.DefaultDir:=CurrentPath+coPathDatabase;
  fConnection.DriverDLL:='';
  fConnection.Open;
  fTableMain:=TASQLite3Query.Create(nil);
  fTableMain.Connection:=fConnection;
end;

destructor TIMDatabase.Destroy;
begin
  fConnection.Close;
  fTableMain.Close;
  fTableMain.Free;
  fConnection.Free;
  inherited;
end;


function TIMDatabase.CreateQuery: TIMQuery;
begin
  Result:=TIMQuery.Create(nil);
  Result.Close;
  Result.Connection:=fConnection;
end;

procedure TIMDatabase.FreeQuery(Value: TIMQuery);
begin
  Value.Close;
  Value.Free;
end;

function TIMDatabase.VarRecToStr( AVarRec : TVarRec ) : string;
  const
    Bool : array[Boolean] of string = ('False', 'True'); 
  begin 
    case AVarRec.VType of 
      vtInteger:    Result := IntToStr(AVarRec.VInteger); 
      vtBoolean:    Result := Bool[AVarRec.VBoolean]; 
      vtChar:       Result := AVarRec.VChar; 
      vtExtended:   Result := FloatToStr(AVarRec.VExtended^); 
      vtString:     Result := QuotedStr(AVarRec.VString^); 
      vtPChar:      Result := AVarRec.VPChar; 
      vtObject:     Result := AVarRec.VObject.ClassName;
      vtClass:      Result := AVarRec.VClass.ClassName; 
      vtAnsiString: Result := QuotedStr(string(AVarRec.VAnsiString)); 
      vtCurrency:   Result := CurrToStr(AVarRec.VCurrency^); 
      vtVariant:    Result := QuotedStr(string(AVarRec.VVariant^)); 
    else 
      result := ''; 
    end; 
  end; 

function TIMDatabase.ParametersFill( pQuery:String; pNames: array of string;
  pValues: array of const):String;
var
  vCount: Integer;
  vStr,vSum:String;
//  vConstArray: TConstArray;
begin
  vSum:=pQuery;
  for vCount := 0 to Length(pNames)-1 do begin
    vStr:= VarRecToStr(pValues[vCount]);
    vSum:=Q_ReplaceStr(vSum,':'+Lowercase(pNames[vCount]),vStr);
  end;
  result:=vSum;
end;

initialization
  _Database:=TIMDatabase.Create;
finalization
  _Database.free;
end.
