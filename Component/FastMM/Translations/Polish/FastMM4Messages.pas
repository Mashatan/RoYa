{

Fast Memory Manager: Messages

Polish translation by Artur Red�ko (arturr@opegieka.pl).

}

unit FastMM4Messages;

interface

{$Include FastMM4Options.inc}

const
  {The name of the debug info support DLL}
  FullDebugModeLibraryName = 'FastMM_FullDebugMode.dll';
  {Event log strings}
  LogFileExtension = '_MemoryManager_raport.txt'#0;
  CRLF = #13#10;
  EventSeparator = '--------------------------------';
  {Class name messages}
  UnknownClassNameMsg = 'Nieznany';
  {Stack trace Message}
  CurrentStackTraceMsg = #13#10#13#10'Aktualny �lad stosu prowadzi do tego b��du (zwraca adresy): ';
  {Memory dump message}
  MemoryDumpMsg = #13#10#13#10'Aktualny zrzut pami�ci 256 bajt�w zaczynaj�cy si� od adresu ';
  {Block Error Messages}
  BlockScanLogHeader = 'Zaalokowany blok zapisany przez LogAllocatedBlocksToFile. Rozmiar : ';
  ErrorMsgHeader = 'FastMM wykry� b��d podczas operacji ';
  GetMemMsg = 'GetMem';
  FreeMemMsg = 'FreeMem';
  ReallocMemMsg = 'ReallocMem';
  BlockCheckMsg = 'skanowania wolnego bloku';
  OperationMsg = '. ';
  BlockHeaderCorruptedMsg = 'Nag��wek bloku jest uszkodzony. ';
  BlockFooterCorruptedMsg = 'Stopka bloku jest uszkodzona. ';
  FreeModifiedErrorMsg = 'FastMM wykry� �e blok zosta� zmodyfikowany po tym jak zosta� zwolniony. ';
  DoubleFreeErrorMsg = 'Wykryto pr�b� zwolnienia/realokacji niezaalokowanego bloku.';
  PreviousBlockSizeMsg = #13#10#13#10'Poprzedni rozmiar bloku by�: ';
  CurrentBlockSizeMsg = #13#10#13#10'Rozmiar bloku jest: ';
  StackTraceAtPrevAllocMsg = #13#10#13#10'�lad stosu kiedy ten blok by� poprzednio zaalokowany (zwraca adresy):';
  StackTraceAtAllocMsg = #13#10#13#10'�lad stosu kiedy ten blok by� zaalokowany (zwraca adresy):';
  PreviousObjectClassMsg = #13#10#13#10'Blok zosta� poprzednio u�yty w obiekcie klasy: ';
  CurrentObjectClassMsg = #13#10#13#10'Blok jest aktualnie u�ywany w obiekcie klasy: ';
  PreviousAllocationGroupMsg = #13#10#13#10'By�a grupa alokacji : ';
  PreviousAllocationNumberMsg = #13#10#13#10'By�a ilo�� alokacji : ';
  CurrentAllocationGroupMsg = #13#10#13#10'Jest grupa alokacji : ';
  CurrentAllocationNumberMsg = #13#10#13#10'Jest ilo�� alokacji : ';
  StackTraceAtFreeMsg = #13#10#13#10'�lad stosu kiedy ten blok by� poprzednio zwolniony (zwraca adresy):';
  BlockErrorMsgTitle = 'Wykryto b��d pami�ci';
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
  VirtualMethodErrorHeader = 'FastMM wykry� pr�b� u�ycia wirtualnej metody zwolnionego obiektu. Zostanie wygenerowany teraz wyj�tek w celu przerwania aktualnej operacji.';
  InterfaceErrorHeader = 'FastMM wykry� pr�b� u�ycia interfejsu zwolnionego obiektu. Zostanie wygenerowany teraz wyj�tek w celu przerwania aktualnej operacji.';
  BlockHeaderCorruptedNoHistoryMsg = ' Niestety nag��wek bloku zosta� uszkodzony wi�c historia nie jest dost�pna.';
  FreedObjectClassMsg = #13#10#13#10'Klasa zwolnionego obiektu: ';
  VirtualMethodName = #13#10#13#10'Metoda wirtualna: ';
  VirtualMethodOffset = 'przesuni�cie +';
  VirtualMethodAddress = #13#10#13#10'Adres metody wirtualnej: ';
  StackTraceAtObjectAllocMsg = #13#10#13#10'�lad stosu kiedy obiekt zosta� zaalokowany (zwraca adresy):';
  StackTraceAtObjectFreeMsg = #13#10#13#10'�lad stosu kiedy obiekt zosta� p�niej zwolniony (zwraca adresy):';
  {Installation Messages}
  AlreadyInstalledMsg = 'FastMM4 jest ju� zainstalowany.';
  AlreadyInstalledTitle = 'Ju� zainstalowany.';
  OtherMMInstalledMsg = 'FastMM4 nie mo�e by� zainstalowany poniewa� inny mened�er pami�ci '
    + 'zosta� ju� zainstalowany.'#13#10'Je�li chcesz u�y� FastMM4, '
    + 'zapewniaj�c aby modu� FastMM4.pas by� zainicjowany jako pierwszy modu� w twoim projekcie.';
  OtherMMInstalledTitle = 'Nie mo�na zainstalowa� FastMM4 - inny mened�er pami�ci jest ju� zainstalowany';
  MemoryAllocatedMsg = 'FastMM4 nie mo�e by� zainstalowany poniewa� pami�� zosta�a '
    + 'juz zaalokowana przez domy�lny mened�er pami�ci.'#13#10'FastMM4.pas MUSI '
    + 'by� pierwszym modu�em w twoim projekcie, w przeciwnym wypadku pami�� mo�e '
    + 'by� zaalokowana'#13#10'przez domy�lny mened�er pami�ci zanim FastMM4 '
    + 'przejmie kontrol�.'#13#10#13#10'Je�li u�ywasz aplikacji do przechwytywania wyj�tk�w '
    + 'takich jak MadExcept,'#13#10'zmie� jego konfiguracj� zapewniaj�c aby modu� '
    + 'FastMM4.pas by� zainicjowany jako pierwszy modu�.';
  MemoryAllocatedTitle = 'Nie mo�na zainstalowa� FastMM4 - pami�� zosta�a ju� zaalokowana.'
    + 'FastMM4.pas jest inicjowany jako pierwszy modu�.';
  {Leak checking messages}
  LeakLogHeader = 'Wyciek� blok pami�ci. Rozmiar wynosi: ';
  LeakMessageHeader = 'Aplikacja wykry�a wycieki pami�ci. ';
  SmallLeakDetail = 'Ma�e bloki wyciek�w s�'
{$ifdef HideExpectedLeaksRegisteredByPointer}
    + ' (wy��czaj�c oczekiwane wycieki zarejestrowane przez wska�nik)'
{$endif}
    + ':'#13#10;
  LargeLeakDetail = 'Rozmiary �rednich i du�ych wyciek�w wynosz�'
{$ifdef HideExpectedLeaksRegisteredByPointer}
    + ' (wy��czaj�c oczekiwane wycieki zarejestrowane przez wska�nik)'
{$endif}
    + ': ';
  BytesMessage = ' bajt�w: ';
  StringBlockMessage = 'String';
  LeakMessageFooter = #13#10
{$ifndef HideMemoryLeakHintMessage}
    + #13#10'Uwaga: '
  {$ifdef RequireIDEPresenceForLeakReporting}
    + 'Sprawdzenie wyciek�w pami�ci wyst�puje tylko gdy Delphi jest uruchomione na tym samych komputerze. '
  {$endif}
  {$ifdef FullDebugMode}
    {$ifdef LogMemoryLeakDetailToFile}
    + 'Szczeg�y wyciek�w s� rejestrowane w pliku tekstowym w tym samym katalogu co aplikacja. '
    {$else}
    + 'W��cz "LogMemoryLeakDetailToFile" aby uzyska� szczeg�owy plik z wyciekami pami�ci. '
    {$endif}
  {$else}
    + 'Aby uzyska� plik ze szczeg�ami wyciek�w pami�ci, w��cz definicje warunkowe "FullDebugMode" i "LogMemoryLeakDetailToFile". '
  {$endif}
    + 'Aby wy��czy� raportowanie wyciek�w, wy��cz "EnableMemoryLeakReporting".'#13#10
{$endif}
    + #0;
  LeakMessageTitle = 'Wykryto wyciek pami�ci';
{$ifdef UseOutputDebugString}
  FastMMInstallMsg = 'FastMM zosta� zainstalowany.';
  FastMMInstallSharedMsg = 'Rozpocz�cie wsp�dzielenia istniej�cej instancji FastMM.';
  FastMMUninstallMsg = 'FastMM zosta� odinstalowany.';
  FastMMUninstallSharedMsg = 'Zako�czenie wsp�dzielenia istniej�cej instancji FastMM.';
{$endif}
{$ifdef DetectMMOperationsAfterUninstall}
  InvalidOperationTitle = 'Operacja MM po deinstalacji.';
  InvalidGetMemMsg = 'FastMM wykry� wywo�anie GetMem po tym jak FastMM zosta� odinstalowany.';
  InvalidFreeMemMsg = 'FastMM wykry� wywo�anie FreeMem po tym jak FastMM zosta� odinstalowany.';
  InvalidReallocMemMsg = 'FastMM wykry� wywo�anie ReallocMem po tym jak FastMM zosta� odinstalowany.';
  InvalidAllocMemMsg = 'FastMM wykry� wywo�anie AllocMem po tym jak FastMM zosta� odinstalowany.';
{$endif}

implementation

end.

