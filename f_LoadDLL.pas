{
   File: f_LoadDLL

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
unit f_LoadDLL;

interface
uses Classes,Windows,DllLoader;

type
  TModeDll=(mdResource=1,mdFile=2,mdMemory=3);
  TLoadDll=class(TObject)
    private
      fMemoryStream: TMemoryStream;
      fHandel:THandle;
      fModeDll:TModeDll;
      fDllLoader:TDLLLoader;
      fLoaded:boolean;
    public
      constructor Create(pFileName:String);overload;
      constructor Create(pResName:String; pResType:PChar);overload;
      constructor Create(pStream:TMemoryStream);overload;
      destructor Destroy;override;
      function GetProcAddress(const pNameProc: PChar): Pointer;
      property IsLoaded:boolean read fLoaded;
  end;

implementation

{ TLoadDll }

constructor TLoadDll.Create(pFileName:String);
begin
  inherited Create();
  fModeDLL:=mdFile;
  fHandel:=LoadLibrary(Pchar(pFileName));
  fLoaded:= fHandel<>0;
end;

constructor TLoadDll.Create(pResName:String; pResType:PChar);
var
  rStream:TResourceStream;
begin
  inherited Create();
  fModeDLL:=mdResource;
  fMemoryStream := TMemoryStream.Create;
  rStream := TResourceStream.Create(hinstance, pResName , pResType);
  fMemoryStream.CopyFrom(rStream, 0);
  fMemoryStream.Position := 0;
  fDllLoader:=TDLLLoader.Create;
  fLoaded:=fDllLoader.Load(fMemoryStream);
  rStream.Free;
end;

constructor TLoadDll.Create(pStream: TMemoryStream);
begin
  fMemoryStream:=pStream;
  fMemoryStream.Position:=0;
  fDllLoader:=TDLLLoader.Create;
  fLoaded:=fDllLoader.Load(fMemoryStream);
end;

destructor TLoadDll.Destroy;
begin
  case  fModeDll of
  mdFile: begin
    if fHandel<> 0 then begin
      FreeLibrary(fHandel);
      fHandel:=0;
    end;
  end;
  mdResource: begin
    fMemoryStream.Free;
    fDllLoader.Free;
  end;
  mdMemory: begin
    fDllLoader.Free;
  end;
  end;
  inherited;
end;

function TLoadDll.GetProcAddress(const pNameProc: PChar): Pointer;
begin
  Result:=nil;
  case  fModeDll of
    mdResource: begin
      result:=fDllLoader.FindExport(pNameProc);
    end;
    mdFile: begin
      result:=Windows.GetProcAddress(fHandel, pNameProc);
    end;
  end;
end;

end.
