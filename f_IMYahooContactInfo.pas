{
   File: f_IMYahooContactInfo

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
unit f_IMYahooContactInfo;
interface
uses  SysUtils,Classes,f_IMContactInfo,f_IMConsts;
type
  TIMYahooContactInfo = class (TIMContactInfo)
    constructor Create();
    destructor Destroy;override;
    public
     PacketHeaderRecesive:TYahooPacketHeader;
     PacketHeaderSend:TYahooPacketHeader;
     ServiceProcessed:Word;
     procedure SetRAWInstanstMessage(value:String);
     Procedure Split(val:String;VSplit:TStringList);
     Function  FilterIM(value:String):String;
  end;
implementation

constructor TIMYahooContactInfo.Create;
begin
  inherited Create;
  ServiceProcessed:=0;
end;

destructor TIMYahooContactInfo.Destroy;
begin
   inherited;
end;

procedure TIMYahooContactInfo.SetRAWInstanstMessage(Value:String);
begin
    In_RAWInstantMessage:=Value;
    In_InstantMessage:=FilterIM(In_RAWInstantMessage);
    Split(In_InstantMessage,In_ListParam);
end;


Function  TIMYahooContactInfo.FilterIM(value:String):String;
var
  st:String;
  i,j:Integer;
  Flag:Boolean;
Begin
 st:=value;
 Flag:=False;
 i:=0;
 Result:=st;
 j:=0;
 if st='' then exit;
 if pos('<ding>',st)<1 then
 begin
   while true do
   begin
     i := i + 1;
     if (st[i]='<') then
     begin
       Flag:=True;j:=i;
     End;
     if (st[i]='>') and Flag then
     Begin
       Flag:=False;
       Delete(st,j,i-j+1);i:=0;
     end;
     if i>=Length(st) then
       break;
   End;
 end;
 while true do begin
   i := Pos(#$1b'[',st);
   if (i<>0) then begin
     j:=Pos('m',st);
     if j<=0 then j:=Length(st);
     if j<i then
       Delete(st,j,1)
     else
       Delete(st,i,j-i+1);
   end else
     break;
 End;
 Result:=st;
end;

Procedure TIMYahooContactInfo.Split(val:String;VSplit:TStringList);
var
  j,i:Integer;
  ver:byte;
  tmp,txt:String;
  sum:TStringList;
begin
  VSplit.Clear;
  val:=Trim(val);
  if val='' then exit;
  j:=0;
  For i:=1 to Length(val) do
    if val[i]='"' then j:=j+1;
  if j mod 2 <>0 then exit;
  ver:=0;
  j:=0;
  Repeat
   j:=j+1;
   if (ver=1) and (val[j]='"') then Ver:=0
    else
     if (ver=0) and (val[j]='"') then Ver:=1;
   if ver=0 then begin
     if (val[j]=#32) and (val[j+1]=#32) then begin
       delete(val,j,1);
       j:=j-1;
     end;
   end;
   if j>=Length(val) then break;
  Until False;

  sum:=TStringList.create;
  Try
    ver:=0;
    txt:='';
    for i:=1 to Length(val) do begin
      if (val[i]=#32) then begin
        txt:=Trim(txt);
        Sum.Add(txt);
        txt:='';
      end else
        txt:=txt+val[i];
    end;
    if txt<>'' then
       Sum.Add(txt);
    for i:=0 to sum.Count-1 do begin
      txt:=sum.Strings[i];
      if ver=1 then begin
        tmp:=tmp+' '+txt;
      end;
      if (txt<>'')and ((ver=0)or(txt<>'"')) and (txt[1]='"') then begin
        ver:=1;
        tmp:=sum.Strings[i];
        delete(tmp,1,1);
        sum.Strings[i]:=tmp;
      end;
      if ver=0 then
        VSplit.Add(txt);
      if (ver=1) and (tmp<>'') and (tmp[Length(tmp)]='"') then begin
        ver:=0;
        delete(tmp,Length(tmp),1);
        VSplit.Add(tmp);
      end;
    end;
  Finally
    sum.free;
  end;
End;

end.