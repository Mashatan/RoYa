{Fast Memory Manager: Meldungen

Deutsche �bersetzung von Uwe Queisser [uweq]

}
unit FastMM4Messages;

interface

{$Include FastMM4Options.inc}

const
  {Der Name der Debug-Info-DLL}
  FullDebugModeLibraryName = 'FastMM_FullDebugMode.dll';
  {Protokollaufzeichungs Erweiterung}
  LogFileExtension = '_FastMM_Log.txt'#0;  {*** (changed) geaendert 31.01.06 (to long) zu lang *** [uweq] ***}
  CRLF = #13#10;
  EventSeparator = '--------------------------------';
  {Klassenbezeichner Meldung}
  UnknownClassNameMsg = 'Unbekannt';
  {Stackverlauf Nachricht}
  CurrentStackTraceMsg = #13#10#13#10'Die aktuelle Stack ablaufverfolgung, die zu diesem Fehler f�hrte (R�ckgabeadresse): ';
  {Speicherauszugsnachricht}
  MemoryDumpMsg = #13#10#13#10'Aktueller Speicherauszug von 256 Byte, angefangen an der Zeigeradresse: ';
  {Block Fehlermeldungen}
  BlockScanLogHeader = 'Allocated block logged by LogAllocatedBlocksToFile. The size is: ';
  ErrorMsgHeader = 'FastMM hat einen Fehler erkannt, w�hrend ein';
  GetMemMsg = ' GetMem';
  FreeMemMsg = ' FreeMem';
  ReallocMemMsg = ' ReallocMem';
  BlockCheckMsg = 'er freier SpeicherBlock�berpr�fung';
  OperationMsg = ' Operation. ';
  BlockHeaderCorruptedMsg = 'Der Block-Header ist fehlerhaft. ';
  BlockFooterCorruptedMsg = 'Der Block-Footer (Line) ist fehlerhaft. ';
  FreeModifiedErrorMsg = 'FastMM hat festgestellt, da� ein Speicherblock modifiziert worden ist, nachdem er freigegeben wurde. ';
  DoubleFreeErrorMsg = 'Es wurde ein Versuch unternommen, einen freigegebenen Speicherblock freizugeben / wiederzuverwenden.';
  PreviousBlockSizeMsg = #13#10#13#10'Die vorherige Speicherblockgr��e war: ';
  CurrentBlockSizeMsg = #13#10#13#10'Die Speicherblockgr��e ist: ';
  StackTraceAtPrevAllocMsg = #13#10#13#10'Stackverfolgung - Speicherblock wurde bereits zugeordnet (R�ckgabeadresse):';
  StackTraceAtAllocMsg = #13#10#13#10'Stackverfolgung - Speicherpuffer wurde zugeordnet (R�ckgabeadresse):';
  PreviousObjectClassMsg = #13#10#13#10'Der Speicherpuffer wurde zuvor f�r ein Objekt der folgenden Klasse verwendet: ';
  CurrentObjectClassMsg = #13#10#13#10'Der Speicherpuffer wird gegenw�rtig f�r ein Objekt der folgenden Klasse verwendet: ';
  PreviousAllocationGroupMsg = #13#10#13#10'The allocation group was: ';
  PreviousAllocationNumberMsg = #13#10#13#10'The allocation number was: ';
  CurrentAllocationGroupMsg = #13#10#13#10'The allocation group is: ';
  CurrentAllocationNumberMsg = #13#10#13#10'The allocation number is: ';
  StackTraceAtFreeMsg = #13#10#13#10'Stackverfolgung des Speicherpuffers, wann der Speicherblock zuvor freigegeben wurde (R�ckgabeadresse):';
  BlockErrorMsgTitle = 'Speicherfehler gefunden';
  {Freigegebene Objekt aufgerufene virtuelle Methoden}
  StandardVirtualMethodNames: array[1 + vmtParent div 4 .. -1] of PChar = (
    'SafeCallException',
    'AfterConstruction',
    'BeforeDestruction',
    'Dispatch',
    'DefaultHandler',
    'NewInstance',
    'FreeInstance',
    'Destroy');
  VirtualMethodErrorHeader = 'FastMM hat einen Versuch festgestellt, eine virtuelle Methode eines freigegebenen Objekts aufzurufen.'+CRLF
                             +'Es wird jetzt eine Zugriffsverletzung erzeugt, um den aktuellen Betrieb abzubrechen.';
  InterfaceErrorHeader = 'FastMM hat einen Versuch festgestellt, eine Schnittstelle eines freigegebenen Objekts zu verwenden.'+CRLF
                         +'Es wird jetzt eine Zugriffsverletzung erzeugt, um den aktuellen Betrieb abzubrechen.';
  BlockHeaderCorruptedNoHistoryMsg = ' Leider ist der Speicherbereich fehlerhaft, so da� kein Protokoll verf�gbar ist.';
  FreedObjectClassMsg = #13#10#13#10'Freigegebene Objektklasse: ';
  VirtualMethodName = #13#10#13#10'Virtuelle Methode: ';
  VirtualMethodOffset = 'Relative Position +';
  VirtualMethodAddress = #13#10#13#10'Virtuelle Methodenadresse: ';
  StackTraceAtObjectAllocMsg = #13#10#13#10'Stackverfolgung des Speicherblocks, wann das Objekt zugeordnet wurde (R�ckgabeadresse):';
  StackTraceAtObjectFreeMsg = #13#10#13#10'Stackverfolgung des Speicherpuffers, wann das Objekt anschlie�end freigegeben wurde (R�ckgabeadresse):';
 {Installationsmeldungen}
  AlreadyInstalledMsg = 'FastMM4 ist bereits installiert.';
  AlreadyInstalledTitle = 'schon installiert.';
  OtherMMInstalledMsg = 'FastMM4 kann nicht noch einmal in den Speicher geladen werden. '
    + 'Manager hat sich bereits installiert.'#13#10'Wenn Sie FastMM4 verwenden wollen,'
    + 'vergewissern sie sich, da� FastMM4.pas die allererste Unit in der "uses"'
    + #13#10'-Anweisung ihrer Projekt-.dpr Datei ist.';
  OtherMMInstalledTitle = 'Kann die Installation von FastMM4 nicht fortsetzen - da ein anderer Speichermanager bereits geladen wurde';
  MemoryAllocatedMsg = 'FastMM4 kann sich nicht installieren, da der Speicher schon'
    + ' von einem anderen Speichermanager zugeordnet wurde.'#13#10'FastMM4.pas mu�'
    + ' die erste Unit in Ihrer Projekt-.dpr sein, sonst wird Speicher, '
    + 'vor Benutzung des FastMM4 '#13#10' durch den Standardspeichermanager zugeordnet'
    + ' und �bernommen. '#13#10#13#10'Wenn Sie eine Fehlerbehandlung benutzen '
    + 'm�chten, sollten Sie MadExcept (oder ein anderes Hilfsprogramm, das die Unit-Initialisierung modifiziert'
    + ' bestellen), '#13#10' und stellen in der Konfiguration sicher, da� die '
    + 'FastMM4.pas Unit vor jeder anderen Unit initialisiert wird.';
  MemoryAllocatedTitle = 'Keine Installation von FastMM4 - Speicher ist bereits zugeordnet worden.';
  {Speicherleck Meldungen}
  LeakLogHeader = 'Ein Speicher-Leck hat folgende Gr��e : ';
  LeakMessageHeader = 'Diese Anwendung hat Speicher-Lecks. ';
  SmallLeakDetail = 'Die kleineren Speicher-Lecks sind'
{$ifdef HideExpectedLeaksRegisteredByPointer}
    + ' (ausschlie�lich von Zeigern registrierte Lecks)'
{$endif}
    + ':'#13#10;
  LargeLeakDetail = 'Die gr��eren Speicher-Lecks sind'
{$ifdef HideExpectedLeaksRegisteredByPointer}
    + ' (ausschlie�lich von Zeiger registrierte Lecks)'
{$endif}
    + ': ';
  BytesMessage = ' bytes: ';
  StringBlockMessage = 'String';
  LeakMessageFooter = #13#10
{$ifndef HideMemoryLeakHintMessage}
    + #13#10'Hinweis: '
  {$ifdef RequireIDEPresenceForLeakReporting}
    + 'Diese Speicherleckpr�fung wird nur ausgef�hrt, wenn Delphi gegenw�rtig auf demselben Computer l�uft. '
  {$endif}
  {$ifdef FullDebugMode}
    {$ifdef LogMemoryLeakDetailToFile}
    + 'Speicherlecks werden in einer Textdatei im selben Ordner wie diese Anwendung protokolliert. '
    {$else}
    + 'Wenn Sie "{$ LogMemoryLeakDetailToFile}" aktivieren, erhalten sie in der  Protokolldatei die Details �ber Speicherlecks. '
    {$endif}
  {$else}
    + 'Um eine Protokolldatei zu erhalten, die Details �ber Speicherlecks enth�lt, aktivieren Sie die "{$ FullDebugMode}" und "{$ LogMemoryLeakDetailToFile}" Definitionen. '
  {$endif}
    + 'Um die Speicherleckpr�fung zu deaktivieren, deaktivieren sie die "{$ EnableMemoryLeakReporting} -Option".'#13#10
{$endif}
    + #0;
  LeakMessageTitle = 'Speicherleck entdeckt';
{$ifdef UseOutputDebugString}
  FastMMInstallMsg = 'FastMM ist wurde geladen.';
  FastMMInstallSharedMsg = 'Eine bereits vorhandene Instanz von FastMM wird gemeinsam benutzt.';
  FastMMUninstallMsg = 'FastMM ist aus dem Speicher entladen worden.';
  FastMMUninstallSharedMsg = 'Eine gemeinsam benutzte Instanz von FastMM wurde angehalten.';
{$endif}
{$ifdef DetectMMOperationsAfterUninstall}
  InvalidOperationTitle = 'MM nach dem Betrieb der Installation.';
  InvalidGetMemMsg = 'FastMM hat einen GetMem Aufruf gefunden, nachdem FastMM deinstalliert wurde.';
  InvalidFreeMemMsg = 'FastMM hat einen FreeMem Aufruf gefunden, nachdem FastMM deinstalliert wurde.';
  InvalidReallocMemMsg = 'FastMM hat einen ReallocMem Aufruf gefunden, nachdem FastMM deinstalliert wurde.';
  InvalidAllocMemMsg = 'FastMM hat einen ReallocMem Aufruf gefunden, nachdem FastMM deinstalliert wurde.';
{$endif}
implementation
end.