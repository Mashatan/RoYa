{
   File: f_IMCommon

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
unit f_IMCommon;
{$I RoYa.inc}
interface
uses Forms,SysUtils,Classes,f_IMConsts,f_RoYaDefines,logger,
     f_IMBuffer,
     f_IMGeneralInfo;
type
  TIMLogger=class(TLogger)
    public
     Constructor Create;
     destructor Destory;
     procedure Add(const Msg: string;const Status:TLogStatus);
  end;
var
  _Logger:TIMLogger;

implementation


Constructor TIMLogger.Create;
begin
  inherited Create ( 'yyyy-mm-dd"#RoYa.log"' , CurrentPath+coPathLogs,10 , 0 , nil, 5 , 0 );
end;

destructor TIMLogger.Destory;
begin
  inherited ;
end;

procedure TIMLogger.Add(const Msg: string;const Status:TLogStatus);
begin
  {$ifdef LogFile}
    WriteLog(Msg,0);
  {$endif}
end;

initialization
  _Logger:=TIMLogger.Create;
finalization
  _Logger.Free;
end.
