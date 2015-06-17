{
   File: Plugin.dpr

   Project:  Plugin
   Status:   Version 4.0
   Date:     2008-09-22
   Author:   Ali Mashatan

   License:
     GNU Public License ( GPL3 ) [http://www.gnu.org/licenses/gpl-3.0.txt]
     Copyrigth (c) Mashatan Software 2002-2008

   Contact Details:
     If you use Plugin I would like to hear from you: please email me
     your comments - good and bad.
     E-mail:  ali.mashatan@gmail.com 
     website: https://github.com/Mashatan

   Change History:
   Date         Author       Description
}
library Plugin;


uses
  FastMM4, // for download  http://sourceforge.net/projects/fastmm/
  SysUtils,
  Classes,
  db,
  ADODB,
  Activex,
  f_RoYaDefines in '..\f_RoYaDefines.pas';
Type
  TQuestionAndAnswer=class
    public
      constructor Create(pPath:String);
      destructor  Destroy;override;
      procedure   Answer;
      Procedure   Advertise;
    private
      fADOConnection:TADOConnection;
  end;

{$R *.res}
var
  Path:String;
  fContactInfo:TRoYaVariables;
  fQuestionAndAnswer:TQuestionAndAnswer;

{ AnswerAndQuestion }

constructor TQuestionAndAnswer.Create(pPath:String);
begin
  fADOConnection:=TADOConnection.Create(nil);
  fADOConnection.ConnectionString:='Provider=Microsoft.Jet.OLEDB.4.0;Data Source='+pPath+'Plugin\sample.mdb'+';Mode=ReadWrite|Share Deny None;Persist Security Info=False';
  fADOConnection.Connected:=True;
end;

destructor TQuestionAndAnswer.Destroy;
begin
  fADOConnection.Close;
  fADOConnection.Free;
  inherited;
end;

Procedure TQuestionAndAnswer.Advertise;
var
  i:Integer;
  vADOQuery:TADOQuery;
  vName:String;
begin
  vADOQuery:=TADOQuery.Create(nil);
  vADOQuery.Connection:=fADOConnection;
  Randomize;
  i:=Random (30)+1;
  if i mod 5= 0 then begin
    vADOQuery.Close;
    vADOQuery.SQL.Text:='SELECT * FROM ads ORDER BY Rnd([pkADS]);';
    vADOQuery.Open;
    if not vADOQuery.IsEmpty then begin
      vName:=vADOQuery.FieldByName('name').AsString;
      fContactInfo.Out_InstantMessage.Add('Ads -> '+vName);
    End;
    vADOQuery.Close;
  end;
  vADOQuery.Free;
End;

procedure TQuestionAndAnswer.Answer;
var
  req:String;
  vADOQuery:TADOQuery;
begin
  vADOQuery:=TADOQuery.Create(nil);
  vADOQuery.Connection:=fADOConnection;
  if fContactInfo.In_ListParam.Count > 0 then begin
    req:=fContactInfo.In_ListParam[0];
    vADOQuery.Close;
    vADOQuery.SQL.Text:='Select * From Message Where Requst = '+QuotedStr(Req);
    vADOQuery.Open;
    if not vADOQuery.IsEmpty then
      fContactInfo.Out_InstantMessage.Add(vADOQuery.FieldByName('Response').AsString);
    vADOQuery.close;
  end;
  vADOQuery.Free;
end;


procedure NewContact;
begin
  if rsNewContact in fContactInfo.In_RoYaState then
  begin
    fContactInfo.Out_InstantMessage.Add(CodeESC+'[1m'+CodeESC+'[2m'+CodeESC+'[32m<FADE #ff0000,#00ff00,#0000ff><font Face="Times New Roman" size="25">Welcome to RoYa </font></FADE>');
    fContactInfo.Out_InstantMessage.Add(CodeESC+'[37m(c) Copyright 2002-2008 Mashatan Software');
    fContactInfo.Out_InstantMessage.Add(CodeESC+'[32m This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.');
    fContactInfo.Out_InstantMessage.Add(CodeESC+'[31mhttps://github.com/Mashatan');

  end;
end;

procedure Master;
begin
  //if rsOwner in fContactInfo.In_RoYaState then
  //   pContactInfo.Out_InstantMessage.Add('so , what ?');
end;

procedure About;
begin
  if (fContactInfo.In_ListParam.Count > 0) and
     (fContactInfo.In_ListParam[0]='/about') then begin
    fContactInfo.Out_InstantMessage.Add(CodeESC+'[1m'+CodeESC+'[2m'+CodeESC+'[32m<FADE #ff0000,#00ff00,#0000ff><font Face="Times New Roman" size="25">RoYa</font></FADE>');
    fContactInfo.Out_InstantMessage.Add(CodeESC+'[37m(c) Copyright 2002-2008 Mashatan Software');
    fContactInfo.Out_InstantMessage.Add(CodeESC+'[32m This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.');
    fContactInfo.Out_InstantMessage.Add(CodeESC+'[31mhttps://github.com/Mashatan');
  end;
end;


Procedure Process(pContactInfo:TRoYaVariables) ;Stdcall Export;
begin
  fContactInfo:=pContactInfo;
  if rsTimer in pContactInfo.In_RoYaState then
      exit;
  NewContact;
  Master;
  About;
  fQuestionAndAnswer.Answer;
//  fQuestionAndAnswer.Advertise;
//  pContactInfo.Out_Status:='anything';
  pContactInfo.Out_IsAlice:=true;
end;

procedure Initial(pPath:String);Stdcall Export;
begin
  CoInitialize(nil);
  Path:=pPath;
  fQuestionAndAnswer:=TQuestionAndAnswer.Create(pPath);
end;

procedure Final;Stdcall Export;
begin
  fQuestionAndAnswer.Free;
  CoUnInitialize;
end;

Exports
  Process,
  Initial,
  Final;

end.
