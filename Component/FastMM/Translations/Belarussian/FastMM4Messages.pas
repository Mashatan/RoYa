{

Fast Memory Manager: Messages

belarussian translation by dzmitry[li]
mailto:dzmitry@biz.by
����������� ����� ������ ˳��


}

unit FastMM4Messages;

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
  CurrentStackTraceMsg = #13#10#13#10'������� �������� ����� �������� �� ����� ������� (�����������): ';
  {Memory dump message}
  MemoryDumpMsg = #13#10#13#10'������ ���� ������ � 256 ���� ���������� � ������ ';
  {Block Error Messages}
  BlockScanLogHeader = 'Allocated block logged by LogAllocatedBlocksToFile. The size is: ';
  ErrorMsgHeader = 'FastMM ���Ⳣ ������� ������ ';
  GetMemMsg = 'GetMem';
  FreeMemMsg = 'FreeMem';
  ReallocMemMsg = 'ReallocMem';
  BlockCheckMsg = '���������� ����������� �����';
  OperationMsg = ' ��������. ';
  BlockHeaderCorruptedMsg = '��������� ����� ����������. ';
  BlockFooterCorruptedMsg = 'ͳ���� ������ ����� ����������. ';
  FreeModifiedErrorMsg = 'FastMM ���Ⳣ ��� ���� ��� ������������ ����� ��� ����������. ';
  DoubleFreeErrorMsg = '���� ��������� ������ ��������/������������ ���������� ����.';
  PreviousBlockSizeMsg = #13#10#13#10'����� ����������� ����� ���: ';
  CurrentBlockSizeMsg = #13#10#13#10'����� �����: ';
  StackTraceAtPrevAllocMsg = #13#10#13#10'�������� ����� ��� ���� ���� ��� ����� �������� (�����������):';
  StackTraceAtAllocMsg = #13#10#13#10'�������� ����� ��� �������� ����� (�����������):';
  PreviousObjectClassMsg = #13#10#13#10'���� ��� ����� ���������� ��� ��''���� �����: ';
  CurrentObjectClassMsg = #13#10#13#10'���� � �������� ��� ��������������� ��� ��''���� �����: ';
  PreviousAllocationGroupMsg = #13#10#13#10'The allocation group was: ';
  PreviousAllocationNumberMsg = #13#10#13#10'The allocation number was: ';
  CurrentAllocationGroupMsg = #13#10#13#10'The allocation group is: ';
  CurrentAllocationNumberMsg = #13#10#13#10'The allocation number is: ';
  StackTraceAtFreeMsg = #13#10#13#10'�������� ����� ��� ���� ���� ��� ����� ��������� (�����������):';
  BlockErrorMsgTitle = '��������� ������� ������.';
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
  VirtualMethodErrorHeader = 'FastMM ���Ⳣ ������ �������� ��������� ����� ����������� ��''����. ����� ����� �������� ��������� ������� ��� ����������� ������� ��������.';
  InterfaceErrorHeader = 'FastMM ���Ⳣ ������ ����������� ��������� ����������� ��''����. ����� ����� �������� ��������� ������� ��� ����������� ������� ��������.';
  BlockHeaderCorruptedNoHistoryMsg = ' ������ ��������� ����� ���������� � ������� �� ���������.';
  FreedObjectClassMsg = #13#10#13#10'���� ����������� ��''����: ';
  VirtualMethodName = #13#10#13#10'³�������� �����: ';
  VirtualMethodOffset = '�������� +';
  VirtualMethodAddress = #13#10#13#10'����� ����������� ������: ';
  StackTraceAtObjectAllocMsg = #13#10#13#10'�������� ����� ��� ������ ��� ��''��� ���� �������� (�����������):';
  StackTraceAtObjectFreeMsg = #13#10#13#10'�������� ����� ��� ������ ��� ��''��� ���� ����� ��������� (�����������):';
  {Installation Messages}
  AlreadyInstalledMsg = 'FastMM4 ��� ����������.';
  AlreadyInstalledTitle = '��� ����������.';
  OtherMMInstalledMsg = 'FastMM4 �� ���� ���� ���������� ��� ����������� ����� ��������� ������.'
    + #13#10'��� �� ������� ������������� FastMM4, ��� ����� ��������� ��� FastMM4.pas �''�������� ����� ������ ������� �'
    + #13#10'������ "uses" ������ ''s .dpr ����� �������.';
  OtherMMInstalledTitle = '��������� ���������� FastMM4 - ��� ���������� ���� �������� ������.';
  MemoryAllocatedMsg = 'FastMM4 ��������� ���������� ��� ������ ��� ���� '
    + '��������� ����������� ���������� ������.'#13#10'FastMM4.pas ��²��� '
    + '���� ������ ������� � ����� �����''s .dpr ����� �������, ����� ������ ���� '
    + '���� ��������'#13#10'���� ���������� �������� ������ ����� ��� �� FastMM4 '
    + '������� ��������. '#13#10#13#10'��� �� ������������ ���������� ����������� '
    + '���� MadExcept (��� ����� ����� �������, ���� ��������� ������� ����������� '
    + '�������),'#13#10'�� ��������� � �������� ��� ������������ � ���������, ��� '
    + 'FastMM4.pas ������ ������������ ����� ����� ����� �������.';
  MemoryAllocatedTitle = '�� ������� ���������� FastMM4 - ������ ��� ���� ��������';
  {Leak checking messages}
  LeakLogHeader = '���� ������ ��� �������� � �� ���������. �����: ';
  LeakMessageHeader = '� ����� �������� ���������� ����� ������. ';
  SmallLeakDetail = '����� ����� ������ ������'
{$ifdef HideExpectedLeaksRegisteredByPointer}
    + ' (���������� ������� ����� �������������� �� �����������)'
{$endif}
    + ':'#13#10;
  LargeLeakDetail = '������ ������ ����� ��������� ������'
{$ifdef HideExpectedLeaksRegisteredByPointer}
    + ' (���������� ������� ����� �������������� �� �����������)'
{$endif}
    + ': ';
  BytesMessage = ' �����: ';
  StringBlockMessage = 'String';
  LeakMessageFooter = #13#10
{$ifndef HideMemoryLeakHintMessage}
    + #13#10'Note: '
  {$ifdef RequireIDEPresenceForLeakReporting}
    + '����� �������� ����� ������ ����������� ����� � ������� ����������� ����� Delphi �� ��� �� ���������. '
  {$endif}
  {$ifdef FullDebugMode}
    {$ifdef LogMemoryLeakDetailToFile}
    + '�������� ���������� �� ������� ������ ����������� � �������� ���� � ��� �� ��������, ��� � ��������. '
    {$else}
    + '�������� "LogMemoryLeakDetailToFile" ��� ��������� �������, �� ������� �������� ���������� �� ������� ������. '
    {$endif}
  {$else}
    + '��� ��������� �������, �� ������� �������� ���������� �� ������� ������, �������� ����� ��������� "FullDebugMode" � "LogMemoryLeakDetailToFile". '
  {$endif}
    + '��� ���������� ����� �������� ����� ������, ��������� �������� "EnableMemoryLeakReporting".'#13#10
{$endif}
    + #0;
  LeakMessageTitle = '�������� ������ ������';
{$ifdef UseOutputDebugString}
  FastMMInstallMsg = 'FastMM ��� ����������.';
  FastMMInstallSharedMsg = 'Sharing an existing instance of FastMM.';
  FastMMUninstallMsg = 'FastMM ��� �������������.';
  FastMMUninstallSharedMsg = 'Stopped sharing an existing instance of FastMM.';
{$endif}
{$ifdef DetectMMOperationsAfterUninstall}
  InvalidOperationTitle = 'MM �������� ����� ������������.';
  InvalidGetMemMsg = 'FastMM ��������, ��� GetMem ��������� ����� ���� �� FastMM ��� �������������.';
  InvalidFreeMemMsg = 'FastMM ��������, ��� FreeMem ��������� ����� ���� �� FastMM ��� �������������.';
  InvalidReallocMemMsg = 'FastMM ��������, ��� ReallocMem ��������� ����� ���� �� FastMM ��� �������������.';
  InvalidAllocMemMsg = 'FastMM ��������, ��� ReallocMem ��������� ����� ���� �� FastMM ��� �������������.';
{$endif}

implementation

end.
