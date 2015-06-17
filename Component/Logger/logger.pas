unit Logger;

interface

uses
 classes;

const
 EWriteLogVars = 'ERROR : Calling WriteLogVars with empty Level and Msg vars';

type

 //Log level [0-255] I think it's enough
 TLogLevel = byte;

 TLogger = class
  public
   //Logging to file
    //File Creation mask ( see FormatDateTime masks )
    Mask       : string;
    //Dir with log files
    LogDir     : string;
    //Max file logging level (logged events with level [0-WFileLevel] )
    WFileLevel : TLogLevel;


    //NOTE: AutiSwitch & AutoRote consume some disk i/o use with caution

    //Automatic log shitch in every WriteLog call
    //(def=true)
    AutoSwitch : boolean;
    //Auto Check for deleting old logs in every WriteLog
    //(def=true)
    AutoRotate : boolean;
    //Auto flush buffers after each WriteLog (!!!) consumes _many_ disk i/o
    // (def=false)
    // Do not use if you do not _realy_ need it
    AutoSync   : boolean;
    //Delete empty log file (def=true)
    DelEmpty   : boolean;

    //Time to keep log file in hours. (1 mean 1 hour) / max ~7 years ;-)
    KeepTime   : word;

   //Log to TStrings List
    //Pointer to TStrings object
    RefList    : TStrings;
    //Max level to log. Just like WFileLevel
    WListLevel : TLogLevel;
    //Maximum list length 
    //[0-(2^16-1)] realy I use <1000
    MaxLength  : word;

   //Log TLogger events&  (def=true)
    SelfLog    : boolean;

   //Make simple - logging via Syncronize with method
   // WriteLogVars
    Level      : byte;
    Msg        : string;

   constructor Create ( AMask       : string;
                        ALogDir     : string;
                        AWFileLevel : TLogLevel;
                        AKeepTime   : word;
                        ARefList    : TStrings;
                        AWListLevel : TLogLevel;
                        AMaxLength  : word
                        );
    //Write some message to log
    procedure WriteLog ( S : string ; ALevel : byte );
    //Write message to log from Level &  Msg
    procedure WriteLogVars;
    //Flush file buffers to disk
    procedure SyncLogFile;
    //Check if we must switch log files&
    procedure CheckLogSwitch;
    //find and delete all old log files
    procedure RotateLog;
    //format message before writing to log. 
    function FormatMsg ( S : string ; ALevel : TLogLevel ):string;virtual;

   destructor  Destroy;override;
  private
   LogFile     : TFileStream;
   LogFileName : string;
 end;//class

implementation

uses
 Dialogs,
 windows,
// FileUtil,
// DateUtil,
 SysUtils;

constructor TLogger.Create ( AMask       : string;
                             ALogDir     : string;
                             AWFileLevel : TLogLevel;
                             AKeepTime   : word;
                             ARefList    : TStrings;
                             AWListLevel : TLogLevel;
                             AMaxLength  : word
                            );
begin
 Mask       := AMask;
 LogDir     :=  ALogDir ;
 WFileLevel := AWFileLevel;
 AutoSwitch := True;
 AutoRotate := True;
 AutoSync   := False;
 DelEmpty   := True;
 KeepTime   := AKeepTime;
 RefList    := ARefList;
 WListLevel := AWListLevel;
 MaxLength  := AMaxLength;
 SelfLog    := true;
 Level      := 0;
 Msg        := EWriteLogVars;

 LogFile     := NIL;
 LogFileName := '';

 CheckLogSwitch; //if file pointer is NIL simply create and open log file
 RotateLog;

 if SelfLog then WriteLog ( 'Log system started.' , 0 );

end;

//Write message to file
procedure TLogger.WriteLog ( S : string ; ALevel : byte );


//Write to List
procedure WL ( s : string );
begin
 try
  RefList.Add ( s );
 except
  on E : Exception do
   begin
    beep;
//    ShowMessage ( 'TLogger : Erroe while writing to TStrings List' + E.Message );
   end;
 end;
end;

begin

 S := FormatMsg ( S , ALevel );

 //1. Write to TString List

 if RefList <> NIL then begin

  //Check if we must clear list?
  if RefList.Count > MaxLength then
   try
    RefList.Clear;
   except
    on E : Exception do
    begin
     beep; //attract user attention
//     ShowMessage ( 'TLogger : Error while cleaning TStrings List' + E.Message );
    end;
   end;

   if ALevel <= WListLevel then
    WL ( S );

 end;//if RefList <> NIL

 //2. Write to file
 if LogFile <> NIL then
  if ALevel <= WFileLevel then
   try
    S := S + #13 + #10;
    if AutoSwitch then CheckLogSwitch;
    if AutoRotate then RotateLog;
    LogFile.WriteBuffer ( PChar ( S )^ , Length ( S ) );
    if AutoSync then SyncLogFile;
   except
    on E : Exception do
     if RefLIst <> NIL then 
      WL ( 'Error Writeing to log file ' + LogFileName );
   end;
end;

//Do the same from Level & Msg variables
procedure TLogger.WriteLogVars;
begin
 WriteLog ( Msg , Level );
 Level := 0;
 Msg   := EWriteLogVars;
end;

//Flush file buffers
procedure TLogger.SyncLogFile;
begin
 FlushFileBuffers ( LogFile.Handle );
end;

//Check if we must switch files
procedure TLogger.CheckLogSwitch;

function GetLogFileName ( ATime : TDateTime ) : string;
var
  Cont:Integer;
  sum,tmp:String;
  Flag:Boolean;
begin
 Sum:=LogDir + FormatDateTime ( Mask , ATime );
{ tmp:=sum;
 Cont:=0;
 While FileExists(Sum) do begin
   Cont:=Cont+1;
   sum:=ExtractFileName(tmp)+'['+IntTostr(Cont)+']'+ExtractFileExt(tmp);
 End;}
 Result :=sum;
end;

var
 mdel : boolean;
begin

 if ( LogFile = NIL ) or
    ( LogFileName <> GetLogFileName ( Now ) ) then
 begin
  //YES we must switch log files
  //Close old file if it exists
  if LogFile <> NIL then
  try
   if LogFile.Size = 0 then mdel := true
                       else mdel := false;
   SyncLogFile;
   LogFile.Free;
   LogFile := NIL;
   if mdel then DeleteFile ( LogFileName )
  except
   on E : Exception do
    begin
     LogFile := NIL;
//     ShowMessage ( 'Can''t close old log file. Logging to file stopped.' );
    end;
  end;

  //Open new file
  try
   LogFileName := GetLogFileName ( Now );
   if not FileExists(LogFileName) then begin
     LogFile     := TFileStream.Create ( LogFileName ,fmCreate or fmShareDenyNone );
     LogFile.Free;
   end;
   LogFile     := TFileStream.Create ( LogFileName ,fmOpenWrite or fmShareDenyNone );
   LogFile.Position:=LogFile.Size;  
  except
   on E : Exception do
    begin
     LogFile := NIL;
//     ShowMessage ( 'Can''t create new log file: ' + LogFileName );
     LogFilename := '';
    end;
  end;
 end;

end;


//find and delete all old log files
procedure TLogger.RotateLog;
var
 FR : TSearchRec;
begin
 if KeepTime=0 then exit;
 if FindFirst ( LogDir + '*' , faAnyFile , FR ) = 0 then
  Repeat
   if ( FR.Name <> '.' ) and
      ( FR.Name <> '..' ) then
   begin
    if ( Now - FileDateToDateTime ( FR.Time ) ) > KeepTime then
     DeleteFile ( LogDir + FR.Name );
   end;
  Until FindNext ( FR ) <> 0 ;
 FindClose ( FR );
end;

function TLogger.FormatMsg ( S : string ; ALevel : TLogLevel ):string;
begin
 Result := '[' + IntToStr ( ALevel ) + ']' +
           FormatDateTime ( 'yyyy-mm-dd hh:nn.ss' , Now ) + ' ' + S;
end;

destructor TLogger.Destroy;
begin
 if LogFile <> NIL then
 begin
  if SelfLog then WriteLog ( 'Log system closed.' , 0 );
  SyncLogFile;
  LogFile.Free;
  LogFile := NIL;
 end;
 inherited;
end;

end.
