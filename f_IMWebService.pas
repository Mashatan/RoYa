{
   File: f_IMRobots

   Project:  RoYa
   Status:   Version 4.0 
   Date:     2008-10-03
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
unit f_IMWebService;

interface
uses
  ActiveX,Classes, SOAPHTTPClient, variants,SysUtils,f_IMBuffer,LibXmlParser,
  f_IMTransmitPacket,f_SrvGlobalWeather;

type
  TIMWebService = class(TThread)
  Private
    fWebSrvBuffer:TIMBuffer;
    fParser:TXmlParser;
    procedure doWeather(pTransmitPacket:TIMTransmitPacket);
  Protected
    Procedure Execute; override;
  Public
    Constructor Create(pWebSrvBuffer:TIMBuffer);
    Destructor  Destroy;override;
  end;

implementation


constructor TIMWebService.Create(pWebSrvBuffer:TIMBuffer);
begin
  inherited Create(false);
  fWebSrvBuffer:=pWebSrvBuffer;
  fParser:=nil;
end;

destructor TIMWebService.Destroy;
begin
  inherited;
end;

procedure TIMWebService.doWeather(pTransmitPacket: TIMTransmitPacket);
var
  vSrv:GlobalWeatherSoap;
  vTitle:String;
  vShow:Boolean;
  vCount:Integer;
  vCountry,vCity,vResult,vPlain,vTag:String;
begin
  CoInitialize(nil);
  with pTransmitPacket do
  begin
    if ContactInfo.In_ListParam.Count > 3 then begin
      try
        fParser:=TXmlParser.Create;
        vCountry:=ContactInfo.In_ListParam.Strings[2];
        vCity:=ContactInfo.In_ListParam.Strings[3];
        vSrv:=GetGlobalWeatherSoap(true);
        vPlain:=vSrv.GetWeather(vCity,vCountry);
        fParser.LoadFromBuffer(PChar(vPlain));
        vResult:='';
        fParser.StartScan;
        vShow:=false;
        while fParser.Scan do begin
          case fParser.CurPartType of
           ptStartTag,
           ptEmptyTag:
             begin
               vTag:=LowerCase(fParser.CurName);
                if (vTag = 'currentweather') or (vTag= 'status') then
                  Continue;
               vResult:=vResult+#13'<b>'+vTag+':</b> ';
               vShow:=true;
             end;
           ptContent:
             if vShow then
              begin
                vResult:=vResult+fParser.CurContent;
                vShow:=false;
             end;
          end;
        end;
        if vResult='' then
          vResult:=vPlain;
        ContactInfo.Out_InstantMessage.Add(vResult);
      except
      end;
      if Assigned(fParser) then
        FreeAndNil(fParser);
    end else
      ContactInfo.Out_InstantMessage.Add( 'Syntax : /Service Weather country city');
  end;
  CoUnInitialize;
end;

procedure TIMWebService.Execute;
var
  vTransmitPacket:TIMTransmitPacket;
  vCmd:String;
  vOutBuffer:TIMBuffer;
begin
  inherited;

  While not Terminated do begin
    Sleep(1);
    if fWebSrvBuffer.Count<=0 then
      Continue;
    vTransmitPacket:=fWebSrvBuffer.POP;
    if vTransmitPacket.ContactInfo.In_ListParam.Count>1 then begin
      vCmd:=LowerCase(vTransmitPacket.ContactInfo.In_ListParam.Strings[1]);
      if vCmd='weather' then
        doWeather(vTransmitPacket);
    end else
      vTransmitPacket.ContactInfo.Out_InstantMessage.Add('/Service Weather');
     vOutBuffer:=(vTransmitPacket.Buffer as TIMBuffer);
     vOutBuffer.Push(vTransmitPacket);
  end;//While
end;

end.

