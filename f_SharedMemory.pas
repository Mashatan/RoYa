{
   File: f_SharedMemory

   Project:  RoYa
   Status:   Version 4.0
   Date:     2008-09-24
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
unit f_SharedMemory;

interface
uses
  Windows,Classes,SysUtils,ExtCtrls,f_IMConsts,f_IMAccount;
type
  THandledObject = class(TObject)
  protected
    fHandle: THandle;
  public
    destructor Destroy; override;
    property Handle: THandle read fHandle;
  end;

  TSharedMemory = class(THandledObject)
  private
    fName: string;
    fSize: Integer;
    fCreated: Boolean;
    fFileView: Pointer;
  public
    constructor Create(const pName: string; pSize: Integer);
    destructor Destroy; override;
    procedure Flush;
    property MemName: string read fName;
    property MemSize: Integer read fSize;
    property Buffer: Pointer read fFileView;
    property Created: Boolean read fCreated;
  end;

  TSharedMemStringList = class(TSharedMemory)
  private
    fStringList:TStringList;
  public
    constructor Create(const pName: string; pSize: Integer);
    destructor Destroy; override;
    procedure GetStringList(pPosition:LongInt=0);
    procedure SetStringList(pPosition:LongInt=0);
    Property StringList:TStringList read fStringList;
  end;


implementation
uses f_IMCommon;

procedure Error(const Msg: string);
begin
  raise Exception.Create(Msg);
end;

destructor THandledObject.Destroy;
begin
  if fHandle <> 0 then
    CloseHandle(fHandle);
  inherited;
end;

{ TSharedMemRoYaService }


constructor TSharedMemory.Create(const pName: string; pSize: Integer);
const
  SECURITY_DESCRIPTOR_REVISION = 1;
var
  SecurityDescriptor:TSecurityDescriptor;
  SecurityAttr:TSecurityAttributes;
  RetVal:Integer;
begin
  try
    fName := pName;
    fSize := pSize;

      SecurityAttr.nLength:=SizeOf(SECURITY_ATTRIBUTES);
      SecurityAttr.bInheritHandle:=TRUE;
      SecurityAttr.lpSecurityDescriptor:=@SecurityDescriptor;
      if not InitializeSecurityDescriptor(@SecurityDescriptor,SECURITY_DESCRIPTOR_REVISION1) then
      begin
          RetVal:=GetLastError;
          raise Exception.CreateFmt('Unable to initialize security descriptor. Windows error=%d', [RetVal]);
      end;
      if not SetSecurityDescriptorDacl(@SecurityDescriptor,TRUE,NIL,FALSE) then
      begin
          RetVal:=GetLastError;
          raise Exception.CreateFmt('Unable to set security descriptor dacl. Windows error=%d', [RetVal]);
      end;
      if not SetKernelObjectSecurity(GetCurrentProcess,DACL_SECURITY_INFORMATION,@SecurityDescriptor) then
      begin
          RetVal:=GetLastError;
          raise Exception.CreateFmt( 'Unable to set kernel object security. Windows error=%d', [RetVal]);
      end;

    fHandle := CreateFileMapping($FFFFFFFF, @SecurityAttr, PAGE_READWRITE, 0,
      fSize, PChar(fName));
    if fHandle = 0 then
      abort;
    FCreated := GetLastError = 0;
    FFileView := MapViewOfFile(fHandle, FILE_MAP_ALL_ACCESS, 0, 0, 0);
    if FFileView = nil then
      abort;
    Flush;
  except
    Error(Format('Error creating shared memory %s (%d)', [fName,
      GetLastError]));
  end;
end;

destructor TSharedMemory.Destroy;
begin
  if fFileView <> nil then
    UnmapViewOfFile(fFileView);
  inherited Destroy;
end;


procedure TSharedMemory.Flush;
begin
  FillChar(FFileView^,fSize,0);
end;

{ TSharedMemStringList }

constructor TSharedMemStringList.Create(const pName: string; pSize: Integer);
begin
  inherited Create(pName,pSize);
   fStringList:=TStringList.Create;
end;

destructor TSharedMemStringList.Destroy;
begin
  fStringList.Free;
  inherited;
end;

procedure TSharedMemStringList.GetStringList(pPosition:LongInt=0);
var
  MemStream:TMemoryStream;
begin
  MemStream:=TMemoryStream.Create;
  try
    MemStream.SetSize(MemSize);
    CopyMemory(MemStream.Memory,Pointer(Longint(Buffer) + pPosition), MemStream.Size);
    fStringList.LoadFromStream(MemStream);
  finally
    MemStream.Free;
  end;
end;

procedure TSharedMemStringList.SetStringList(pPosition:LongInt=0);
var
  MemStream:TMemoryStream;
begin
  MemStream:=TMemoryStream.Create;
  try
    fStringList.SaveToStream(MemStream);
    CopyMemory(Pointer(Longint(Buffer) + pPosition),MemStream.Memory, MemStream.Size);
    fStringList.Clear;
  finally
    MemStream.Free;
  end;
end;




end.
