{
   File: f_IMContactInfo

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
unit f_IMContactInfo;
interface
uses Forms,Classes,f_RoYaDefines,f_IMConsts; 
type
  TIMContactInfo = class (TRoYaVariables)
    constructor Create();
    destructor Destroy; override;
    public
     RAWData:String;
     AliceInfo:TStringList;
     ProcessedData:String;
     Transport:TTransportKind;
     Idx:Integer;
     LastRestrictionVal:Integer;
     IsBroadcast:boolean;
  end;
  
implementation

constructor TIMContactInfo.Create;
begin
  inherited;
  In_ListParam:=TStringList.Create;
  Out_InstantMessage:=TStringList.Create;
  //AliceData:=TStringList.Create;
  AliceInfo:=nil;
  In_HWNDApp:=Application.Handle;
end;

destructor TIMContactInfo.Destroy;
begin
  In_ListParam.Free;
  Out_InstantMessage.Free;
  //AliceData.Free;
  inherited ;
end;

end.