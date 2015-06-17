{

Fast Memory Manager: Messages

2006-07-18
Ukrainian translation by Andrey V. Shtukaturov.

}

unit FastMM4MessagesUKR;

interface

{$Include FastMM4Options.inc}

const
  {The name of the debug info support DLL}
  FullDebugModeLibraryName = 'FastMM_FullDebugMode.dll';
  {Event log strings}
  LogFileExtension = '_MemoryManager_EventLog.txt'#0;
  CRLF = #13#10;
  EventSeparator = '--------------------------------';
  {Class name messages}
  UnknownClassNameMsg = 'Unknown';
  {Stack trace Message}
  CurrentStackTraceMsg = #13#10#13#10'������� ���������� ����� ����� �� �� ������� (���������): ';
  {Memory dump message}
  MemoryDumpMsg = #13#10#13#10'�������� ���� ��쒒�� � 256 ���� ��������� � ������ ';
  {Block Error Messages}
  BlockScanLogHeader = ' �������� ���� ���������������� ���������� LogAllocatedBlocksToFile. �����: ';
  ErrorMsgHeader = 'FastMM ������ ������� �� ��� ';
  GetMemMsg = 'GetMem';
  FreeMemMsg = 'FreeMem';
  ReallocMemMsg = 'ReallocMem';
  BlockCheckMsg = '���������� ���������� ����� ';
  OperationMsg = ' ��������. ';
  BlockHeaderCorruptedMsg = ' ��������� ����� ����������. ';
  BlockFooterCorruptedMsg = ' ����� ������� ����� ���������. ';
  FreeModifiedErrorMsg = 'FastMM ������ �� ���� ���� ������������ ���� ���� ���������. ';
  DoubleFreeErrorMsg = ' ���� ������ ��������/����������� �� �������� ����.';
  PreviousBlockSizeMsg = #13#10#13#10'����� ������������ ����� ���: ';
  CurrentBlockSizeMsg = #13#10#13#10'����� �����: ';
  StackTraceAtPrevAllocMsg = #13#10#13#10'���������� ����� ���� ��� ���� ��� ����� �������� (���������):';
  StackTraceAtAllocMsg = #13#10#13#10'���������� ����� �� ��� �������� ����� (���������):';
  PreviousObjectClassMsg = #13#10#13#10'���� ��� ����� ������������ ��� �ᒒ���� �����: ';
  CurrentObjectClassMsg = #13#10#13#10'���� �� ����� ������ ��������������� ��� �ᒒ���� �����: ';
  PreviousAllocationGroupMsg = #13#10#13#10'������� ����� ����: ';
  PreviousAllocationNumberMsg = #13#10#13#10'�������� ����� ���: ';
  CurrentAllocationGroupMsg = #13#10#13#10'������� ����� �����: ';
  CurrentAllocationNumberMsg = #13#10#13#10'�������� ����� ����: ';
  StackTraceAtFreeMsg = #13#10#13#10'���������� ����� ���� ��� ���� ��� ����� ��������� (���������):';
  BlockErrorMsgTitle = '�������� ������� ��쒒��.';
  {Virtual Method Called On Freed Object Errors}
  StandardVirtualMethodNames: array[1 + vmtParent div 4 .. -1] of PChar = (
    'SafeCallException',
    'AfterConstruction',
    'BeforeDestruction',
    'Dispatch',
    'DefaultHandler',
    'NewInstance',
    'FreeInstance',
    'Destroy');
  VirtualMethodErrorHeader = 'FastMM ������ ������ ��������� ���������� ����� ���������� �ᒒ����. ����� ���� ��������� ��������� ������� ��� ����������� ������� ��������.';
  InterfaceErrorHeader = 'FastMM ������ ������ ����������� ��������� ���������� �ᒒ����. ����� ���� ��������� ��������� ������� ��� ����������� ������� ��������.';
  BlockHeaderCorruptedNoHistoryMsg = ' �� ���� ��������� ����� ���������� � ������ ����������.';
  FreedObjectClassMsg = #13#10#13#10'���� ���������� �ᒒ����: ';
  VirtualMethodName = #13#10#13#10'³��������� �����: ';
  VirtualMethodOffset = '���� +';
  VirtualMethodAddress = #13#10#13#10'������ ����������� ������: ';
  StackTraceAtObjectAllocMsg = #13#10#13#10'���������� ����� ���� ��쒒��� �� �ᒒ��� ���� ������� (���������):';
  StackTraceAtObjectFreeMsg = #13#10#13#10'���������� ����� ���� ��쒒��� �� �ᒒ��� ���� ������ �������� (���������):';
  {Installation Messages}
  AlreadyInstalledMsg = 'FastMM4 ��� �����������.';
  AlreadyInstalledTitle = '��� �����������.';
  OtherMMInstalledMsg = 'FastMM4 �� ���� ���� ����������� ���� ��� ����������� ����� �������� ��쒒��.'
    + #13#10'���� �� ������ ��������������� FastMM4, ����-����� ������������� �� FastMM4.pas � ����� ������ ������� �'
    + #13#10'������ "uses" ������ .dpr ����� �������.';
  OtherMMInstalledTitle = '��������� ���������� FastMM4 - ��� ����������� ����� �������� ��쒒��.';
  MemoryAllocatedMsg = 'FastMM4 ��������� ���������� ���� ��쒒��� ��� ���� '
    + '������� ����������� ���������� ��쒒���.'#13#10'FastMM4.pas ������� '
    + '���� ������ ������� � ������ ���� .dpr ���� �������, ������ ��쒒��� ���� '
    + '���� �������'#13#10'����� ����������� �������� ��쒒�� ����� ��� �� FastMM4 '
    + '������ ��������. '#13#10#13#10'���� �� ������������� �������� ��������� ��������, '
    + '��������� MadExcept (��� ����-���� ����� ���������� �� �������� ������� ����������� '
    + '�������),'#13#10'��� �������� �� ������� ���� ������������ �� �������������, �� '
    + 'FastMM4.pas ������ ������������ ����� ����-���� ����� �������.';
  MemoryAllocatedTitle = '��������� ���������� FastMM4 - ��쒒��� ��� ���� �������';
  {Leak checking messages}
  LeakLogHeader = '���� ��쒒�� ��� �������� �� �� ���������. �����: ';
  LeakMessageHeader = '� ����� ������� ����������� ������ ��쒒��.';
  SmallLeakDetail = '������ ����� ���''�� ���������� ������'
{$ifdef HideExpectedLeaksRegisteredByPointer}
    + ' (�� �������� ���������� ����� ���''�� ������������� �� ���������)'
{$endif}
    + ':'#13#10;
  LargeLeakDetail = '������ ����� ����� ���''�� ���������� ������'
{$ifdef HideExpectedLeaksRegisteredByPointer}
    + ' (�� �������� ���������� ����� ���''�� ������������� �� ���������)'
{$endif}
    + ': ';
  BytesMessage = ' ����: ';
  StringBlockMessage = 'String';
  LeakMessageFooter = #13#10
{$ifndef HideMemoryLeakHintMessage}
    + #13#10'Note: '
  {$ifdef RequireIDEPresenceForLeakReporting}
    + '�� �������� ������ ��쒒�� ���������� ���� � ������� ��������� ������ Delphi �� ���� � �������. '
  {$endif}
  {$ifdef FullDebugMode}
    {$ifdef LogMemoryLeakDetailToFile}
    + '�������� ���������� ��� ������ � ��쒒�� ������������ � ��������� ���� � ���� � �������, �� � �������. '
    {$else}
    + '�������� "LogMemoryLeakDetailToFile" ��� ���� ��� �������� ������, �� ������ �������� ���������� ��� ������ ��쒒��. '
    {$endif}
  {$else}
    + '��� ���� ��� �������� ������, �� ������ �������� ���������� ��� ������ ��쒒��, �������� ����� ��������� "FullDebugMode" �� "LogMemoryLeakDetailToFile". '
  {$endif}
    + '��� ���� ��� ��������� �� �������� ����� ��쒒��, ��������� �������� ���������� "EnableMemoryLeakReporting".'#13#10
{$endif}
    + #0;
  LeakMessageTitle = '�������� ������ ��쒒��';
{$ifdef UseOutputDebugString}
  FastMMInstallMsg = 'FastMM has been installed.';
  FastMMInstallSharedMsg = 'Sharing an existing instance of FastMM.';
  FastMMUninstallMsg = 'FastMM has been uninstalled.';
  FastMMUninstallSharedMsg = 'Stopped sharing an existing instance of FastMM.';
{$endif}
{$ifdef DetectMMOperationsAfterUninstall}
  InvalidOperationTitle = 'MM Operation after uninstall.';
  InvalidGetMemMsg = 'FastMM has detected a GetMem call after FastMM was uninstalled.';
  InvalidFreeMemMsg = 'FastMM has detected a FreeMem call after FastMM was uninstalled.';
  InvalidReallocMemMsg = 'FastMM has detected a ReallocMem call after FastMM was uninstalled.';
  InvalidAllocMemMsg = 'FastMM has detected a ReallocMem call after FastMM was uninstalled.';
{$endif}

implementation

end.

