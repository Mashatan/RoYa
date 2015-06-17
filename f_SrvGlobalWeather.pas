// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://www.webservicex.net/globalweather.asmx?WSDL
// Encoding : utf-8
// Version  : 1.0
// (2008/10/22 01:09:34 Þ.Ù - 1.33.2.5)
// ************************************************************************ //

unit f_SrvGlobalWeather;

interface

uses InvokeRegistry, SOAPHTTPClient, Types, XSBuiltIns;

type

  // ************************************************************************ //
  // The following types, referred to in the WSDL document are not being represented
  // in this file. They are either aliases[@] of other types represented or were referred
  // to but never[!] declared in the document. The types from the latter category
  // typically map to predefined/known XML or Borland types; however, they could also 
  // indicate incorrect WSDL documents that failed to declare or import a schema type.
  // ************************************************************************ //
  // !:string          - "http://www.w3.org/2001/XMLSchema"



  // ************************************************************************ //
  // Namespace : http://www.webserviceX.NET
  // soapAction: http://www.webserviceX.NET/%operationName%
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // binding   : GlobalWeatherSoap
  // service   : GlobalWeather
  // port      : GlobalWeatherSoap
  // URL       : http://www.webservicex.net/globalweather.asmx
  // ************************************************************************ //
  GlobalWeatherSoap = interface(IInvokable)
  ['{8091B155-5793-08E1-8C8C-B170D069C2CB}']
    function  GetWeather(const CityName: WideString; const CountryName: WideString): WideString; stdcall;
    function  GetCitiesByCountry(const CountryName: WideString): WideString; stdcall;
  end;

function GetGlobalWeatherSoap(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): GlobalWeatherSoap;


implementation

function GetGlobalWeatherSoap(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): GlobalWeatherSoap;
const
  defWSDL = 'http://www.webservicex.net/globalweather.asmx?WSDL';
  defURL  = 'http://www.webservicex.net/globalweather.asmx';
  defSvc  = 'GlobalWeather';
  defPrt  = 'GlobalWeatherSoap';
var
  RIO: THTTPRIO;
begin
  Result := nil;
  if (Addr = '') then
  begin
    if UseWSDL then
      Addr := defWSDL
    else
      Addr := defURL;
  end;
  if HTTPRIO = nil then
    RIO := THTTPRIO.Create(nil)
  else
    RIO := HTTPRIO;
  try
    Result := (RIO as GlobalWeatherSoap);
    if UseWSDL then
    begin
      RIO.WSDLLocation := Addr;
      RIO.Service := defSvc;
      RIO.Port := defPrt;
    end else
      RIO.URL := Addr;
  finally
    if (Result = nil) and (HTTPRIO = nil) then
      RIO.Free;
  end;
end;


initialization
  InvRegistry.RegisterInterface(TypeInfo(GlobalWeatherSoap), 'http://www.webserviceX.NET', 'utf-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(GlobalWeatherSoap), 'http://www.webserviceX.NET/%operationName%');
  InvRegistry.RegisterInvokeOptions(TypeInfo(GlobalWeatherSoap), ioDocument);

end.