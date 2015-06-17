{*_* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Author:       Fran�ois PIETTE
Creation:     May 1996
Version:      V2.106
Object:       TFtpClient is a FTP client (RFC 959 implementation)
              Support FTPS (SSL) if ICS-SSL is used (RFC 2228 implementation)
EMail:        http://www.overbyte.be        francois.piette@overbyte.be
Support:      Use the mailing list twsocket@elists.org
              Follow "support" link at http://www.overbyte.be for subscription.
Legal issues: Copyright (C) 1996-2006 by Fran�ois PIETTE
              Rue de Grady 24, 4053 Embourg, Belgium. Fax: +32-4-365.74.56
              <francois.piette@overbyte.be>
              SSL implementation includes code written by Arno Garrels,
              Berlin, Germany, contact: <arno.garrels@gmx.de>

              This software is provided 'as-is', without any express or
              implied warranty.  In no event will the author be held liable
              for any  damages arising from the use of this software.

              Permission is granted to anyone to use this software for any
              purpose, including commercial applications, and to alter it
              and redistribute it freely, subject to the following
              restrictions:

              1. The origin of this software must not be misrepresented,
                 you must not claim that you wrote the original software.
                 If you use this software in a product, an acknowledgment
                 in the product documentation would be appreciated but is
                 not required.

              2. Altered source versions must be plainly marked as such, and
                 must not be misrepresented as being the original software.

              3. This notice may not be removed or altered from any source
                 distribution.

              4. You must register this software by sending a picture postcard
                 to the author. Use a nice stamp and mention your name, street
                 address, EMail address and any comment you like to say.

Quick Reference:

Properties:
  HostName      - FTP server host name or IP address
  UserName      - User name for authentication on FTP server
  PassWord      - Passwor needed for user, can be blank
  HostDirName   - Directory as knwon of FTP server
  HostFileName  - File name as known on FTP server
  LocalFileName - Local file name (complete path)
  Binary        - Select binary or ascii file transfert (Need to call TypeSet
                  or TypeSetAsync to send it to FTP server).
  (There are other less used properties, see code below)

Methods:
  Open       - Open the connection with the FTP server
  User       - Send username
  Pass       - Send password
  Acct       - Send account
  Connect    - Open the connection, send username, password and account
  Quit       - Disconnect gracefully from FTP server
  Abort      - Disconnect (close connection) immediately
  AbortXfer  - Abort file transfer without disconnecting.
               Warning: LocalFilename property is lost after this command.
  Pwd        - Get current working directory
  Cwd        - Change Working Directory
  CDup       - Change to parent directory
  TypeSet    - Set type for file transfert (see Binary property)
  TypeBinary - Set to binary type transfert and call TypeSet
  TypeAscii  - Set to ascii type transfert and call TypeSet

  Put        - Upload a file
  Transmit   - Connect, Cwd, Upload a file & Quit

  Append     - Upload a file, appending to existing
  AppendFile - Connect, Cwd, Append a file & Quit

  Get        - Download a file
  Receive    - Connect, Cwd, Download a file & Quit

  RestGet    - Download a file, restarting from current local file size
  RestartGet - Connect, Cwd, Restart downloading a file & Quit

  RestPut    - Upload a file, restarting from ResumeAt property value
  RestartPut - Connect, Cwd, Restart uploading a file & Quit

  Dir        - Download a directory listing to a file
  Directory  - Connect, Cwd, Download a directory listing to a file & Quit

  Ls         - Download a file name listing to a file
  List       - Connect, Cwd, Download a file name listing to a file & Quit

  Mkd        - Create a directory on the server
  Mkdir      - Connect, Cwd, Create a directory on the server & Quit

  Ren        - Rename a file or directory on the server
  Rename     - Connect, Cwd, Rename a file or directory on the server & Quit

  Dele       - Delete a file on the server
  Delete     - Connect, Cwd, Delete a file on the server & Quit

  Rmd        - Remove a directoy from the server
  Rmdir      - Connect, Cwd, Remove a directoy from the server & Quit

  Syst       - Get system information from the server
  System     - Connect, Cwd, Get system information from the server & Quit

  Size       - Get file size
  FileSize   - Connect, Cwd, get file size & Quit

  Quote      - Send literal command (use LocalFileName as command to send)
  DoQuote    - Connect, Cwd, send literal command & Quit

  Feat       - Get extensions supported
               = SupportedExtensions which features server supports

  Mlsd       - Download a directory listing to a file, only supported if
               ftpFeatMLST in SupportedExtensions - V2.90

  Mlst       - Get facts for a specified file or directory, only supported if
               ftpFeatMLST in SupportedExtensions - V2.90
               Result is in RemFacts property, and may be decoded by
               DecodeMlsResp (in FtpSrvT)

  Mdtm       - Get file UTC modification time (to RemFileDT),
               only supported if ftpFeatMDTM in SupportedExtensions - V2.90

  Mdtmyy     - Set file UTC modification time (from RemFileDT),
               only supported if ftpFeatMDTMYY in SupportedExtensions - V2.90

  Auth       - Explizit TLS/SSL authentication (FTPS protocol support) - V2.106
               Params TLS (RFC4217) or SSL (no standard tracks).
               The parameter actually used needs to be specified by property
               SslType.
  CCC        - Revert a TLS/SSL-protected control channel back to plaintext. - V2.106

  Mfmt       - Modify file UTC modification time (from RemFileDT),
               only supported if ftpFeatMFftpFeatMLST in
               SupportedExtensionsMT in SupportedExtensionse - V2.94

  Md5        - Get MD5 hash sum for file (to ??),
               only supported if ftpFeatMD5 in SupportedExtensions - V2.94


  (There are two set of methods: Async and Sync. The Async are the prefered
   ones to build robust applications. Their name end with Async like GetAsync)
  (There are other less used methods, see code below)

How to use FTPS (TLS/SSL/Implizit SSL) ?                           - V2.106
   First you need to have ICS-SSL and recompile the component and your project
   having symbol USE_SSL defined. Then specify the SSLType, either use
   explicit command AUTH after Open command to request TLS/SSL protection of
   the control channel on standard port from server, or you may use one of
   the high level commands which will automatically invoke Auth TLS/SSl once
   connected to the server. Implizit SSL is another method that establishes
   always a secure control channel (no AUTH command is required). To protect
   the data channel as well issue "PBSZ 0" and "PROT P" once the control
   channel is protected, or "PROT C" to clear the data channel.
   Currently there's only one spec available specifying explizit SSL (AUTH TLS)
   it's RFC4217.

How to use a Proxy or Firewall ?
   First of all, not all proxies or firewalls are the same. So have a look at
   product documentation. However, most products support a transparent proxy
   which doesn't require any special programming:
   1) Instead of connection to a remote FTP server, you connect to the proxy
   2) User name is replaced by user name, followed by '@' sign then followed
      by target remote FTP server host name.
   3) Password is usual remote FTP server password.
   4) Most require using Passive mode.
   Example: You want to connect to ftp.borland.com, using anonymous connection,
            company firewall/proxy is running on host named proxyserver.
            FtpCli1.HostName := 'proxyserver';
            FtpCli1.UserName := 'anonymous@ftp.borland.com';
            FtpCli1.Password := 'your.email@company';
            FtpCli1.Passive  := TRUE;

FEAT Command - numerous extensions have been made to the FTP protocol over
the past few years, although support of these new commands is very sporadic.
RFC2389 describes the FEAT command, which returns a multiline list of
extension supported by the server. Note that the SIZE command is an extension,
and not supported on all FTP servers. An internet-draft 'Extensions to FTP'
document the most useful new commands. The responses of common FTP servers
to FEAT are listed below:

Microsoft IIS/5 in Windows 2000
500 'FEAT': command not understood

Microsoft IIS/6 in Windows 2003
211-FEAT
    SIZE
    MDTM
211 END

RhinoSoft Serv-U FTP 4.1
211-Extension supported
 MDTM
 MDTM YYYYMMDDHHMMSS[+-TZ] filename
 SIZE
 SITE PSWD;EXEC;SET;INDEX;ZONE;CHMOD;MSG
 REST STREAM
211 End

RhinoSoft Serv-U FTP Server v6.1
211-Extension supported
 AUTH TLS
 SSCN
 PBSZ
 PROT
 CCC
 CLNT
 MDTM
 MDTM YYYYMMDDHHMMSS[+-TZ];filename
 SIZE
 SITE PSWD;EXEC;SET;INDEX;ZONE;CHMOD;MSG
 REST STREAM
 XCRC filename;start;end
 MODE Z
 MLST Type*;Size*;Create;Modify*;Win32.ea*;
211 End

Ipswich WS_FTP Server 3.14
211-Extensions supported
 SIZE
 MDTM
 MLST size*;type*;perm*;create*;modify*;
 LANG EN*
 REST STREAM
 TVFS
 UTF8
 AUTH SSL;TLS-P;
 PBSZ
 PROT C;P;
211 end

Gene6 FTP Server v3.6.0
211-Extensions supported:
 AUTH TLS
 CCC
 CLNT
 CPSV
 EPRT
 EPSV
 MDTM
 MLST type*;size*;created;modify*;
 PASV
 PBSZ
 PROT
 REST STREAM
 SIZE
 SSCN
 TVFS
 UTF8
 XCRC "filename" SP EP
 XMD5 "filename" SP EP
211 End.

Unknown Unix Daemon
211-Features:
 MDTM
 REST STREAM
 SIZE
211 End

Another Unix Daemon
FEAT
211-Features:
 MDTM
 REST STREAM
 SIZE
 AUTH TLS
 PBSZ
 PROT
211 End

FileZilla Server 0.9.10 beta
211-Features:
 MDTM
 REST STREAM
 SIZE
 MODE Z
 MLST type*;size*;modify*;
211 End

Internet Component Suite TFtpServer V1.39 and later
211-Extensions supported:
  SIZE
  REST STREAM
  MDTM
  MDTM YYYYMMDDHHMMSS[+-TZ] filename
  MLST size*;type*;perm*;create*;modify*;
  MFMT
  MD5
211 END

The extensions supported by V2.94 of this component are:

MLST - Machine Listing, two listing commands:
  MLSD - much better version of LIST directory
  MLST - list a single file
  an example response from either command is as follows:
  size=17199;type=file;perm=fdrwa;create=20030616152030;
       modify=20031001190114; 00master.zip
  (note the date and time includes seconds which is missing from most LIST
   responses, and the time stamps should be UTC - but don't seem to be in
   WS_FTP Server)
MDTM - Get File Modification UTC Time - useful for resumed downloads,
       to see if file has changed
SIZE - Get File Size - useful for resumed downloads, to see if file has changed
MDTM YYYYMMDDHHMMSS[+-TZ] filename - Set File Modification Time after
                                     upload (+0 is UTC)
MFMT - Modify File Modification Time after upload (UTC)
MD5  - Check MD5 hash sum for specified file, used to check for corruption


History:
Nov 04, 1996  Better error handling
              Property for timeout, default to 15 sec
Dec 03, 1996  Adapted display functionnality for Delphi 2
Dec 27, 1996  Added transmit functions
              Changed all procedure to function returning boolean status
Aug 13, 1997  Added multiline response support
              Added support for strange Microsoft PWS FTP behaviour
Sep 10, 1997  Added support for Dir and Ls commands
              Corrected bugs to enable correct use of separate commands
Oct 16, 1997  V2.07 Adapted for changes in TWSocket object
              Added FtpCliVersion constant
Nov 25, 1997  V2.08 Accept 250 as well as 226 for successful file transfert
              Suggested by fdragon@world-net.net
Nov 26, 1997  V2.09 don't display error message in the receive event when
              the socket is no more connected.
Nov 29, 1997  V2.10 added Mkd and Mkdir functions to create a directory.
              As suggested by Christian R�sner <christian.roesner@usa.net>
Dec 04, 1997  V2.11 Added Ren, Dele, Rmd functions
              As suggested by Frank Riemann <riemann@student.uni-kl.de>
              Changed Mkd and Mkdir functions to take HostFileName to
              specify the directory name. This is more consistent with the
              rest of the component usage.
Dec 29, 1997  V2.12 Added a TrimLeft function for Delphi 1
Dec 30, 1997  V2.13 Added Syst and System commands as suggested by
              Fire Dragon <fdragon@nosferatu.world-net.net>
              Added the LastResponse property
              Corrected a message ("Daniel Fazekas" <fdsoft@dns.gyor-ph.hu>)
Jan 10, 1998  V2.14 Accept response 150 and 125 for Get Submitted by Fire
              Dragon <fdragon@nosferatu.world-net.net>.
              Added a quick reference for most used properties and methods.
              Made TFtpCli a TComponent descendant.
              Added the Size, FileSize, Quote, DoQuote, RestartGet method.
              Made ControlSocket a readonly property (allow easy DNSLookup).
              Added a Port property.
Jan 25, 1998  V2.15
              Completely revised to make it asynchronous.
                This means that a new set of functions is born. They all have
                a name ending with Async. For example GetAsync. Asynchronous
                means that when you call the function, it returns almost
                immediately. The operation is done in the background.
                The asynchronous operation allows to make several request
                simultaneously WITHOUT using threads. Just use two or more
                TFtpClient and call each GetAsync (or other) method as those
                method returns almost instantly, all the request will be done
                in the background, generating the OnRequestDone when finished.
                Added a State property
                This allows to check for component work in the background.
                You can call methods only when State = ftpReady (except the
                Abort method which can be called at any time)
                The Asynchronous methods are the prefered ones.

              Added Pwd command
                Returns the current working directory on the server.

              Added CDup command
                Change to parrent directory on FTP server.

              Added DirResult property
                Parse the LastResponse property to return the directory.
                Do no always work when the server returns multi-line responses.
                (updated by Pwd, Cwd, CDup and Mkd commands).

              Changed function IsConnected to Connected, a read-only property.
                It's more object oriented.

              Replaced file I/O by stream I/O.
                It's the first step to allow Stream I/O outside of the component.

              New sample application (Delphi only now, CPP later).
                Every command has now a button to excercize it
                (async version only)

              The synchronous commands (old commands) are implemented by
                calling the asynchronous version and waiting.

              Multi-threaded property
                Tells the component how to wait for command completion.

              Removed the TWait component use.
                No need to have a TWait component.
Jan 31, 1998 V2.16 Accept response 150 and 125 for Put.
Feb 01, 1998 V2.17 Added intermediate message for OnRequestDone event
Feb 02, 1998 V2.18 Corrected a bug: all sync function returned always FALSE.
             Added User and Pass synchronous functions.
             Made PutAsync return ftpPutAsync in the OnrequestDone event.
Feb 04, 1998 V2.19 Added an OnCommand event to give a chance to the user to
             modify the commands to make some custom commands. Also added the
             OnResponse event to allow custom commands to get the response
             and alter it as necessary.
Feb 15, 1998 V2.20 Added a FindClose after the FindFirst in GetFileSize routine
             as pointed by "Daniel Fazekas" <fdsoft@dns.gyor-ph.hu>
Feb 21, 1998 V2.21 Enabled progress updated on put
Feb 22, 1998 V2.22 Accept result code 250 after Put command
             Implemented Append and AppendFile commands
Mar 07, 1998 V2.23 Made RequestType a R/O property
Mar 15, 1998 V2.24 Reordered PORT/REST/RETR
             Added a port command
             The ByteCount passed to OnProgress now take into account the
             restart byte offset.
             Renamed Display to TriggerDisplay and made it virtual
             Used TriggerDisplay everywhere.
             Modified the Timeout mechanism to reset the timeout each
             time the OnProgress event is called.
             Abort command call CancelDnsLookup approprietedly
Mar 27, 1998 V2.25 Adapted for C++Builder 3
Avr 01, 1998 V2.26 Made a valid LastResponse and ErrorMessage when DNS lookup
             failed. Added some compiler options.
Apr 10, 1998 V2.27 Added some ftpFctCwd in some highlevel functions.
             Suggested by Ray Andrews <ray_andrews@steeltoad.com>.
Apr 13, 1998 V2.28 Save error code when the data connection is closed to use
             it later to return the status for file transfert.
             Implemented passive mode, with help from Yaron Golan
             <yarong@shani.com>. A new property Passive enable this mode.
             Put do not work [yet] is passive mode.
Apr 14, 1998 V2.29 Made passive mode PUT work.
             Added ShareMode property (see TFileStream.Create on-line help)
             Made ResumeAt property.
Apr 15, 1998 V2.30 Added the OnReadyToTransmit event.
             Correctly handled error when local file not found.
             Checked if socket connected in SendCommand
Apr 22, 1998 V2.31 Corrected CDupAsync procedure (thanks to Eric
             Engler englere@swcp.com)
Apr 26, 1998 V2.32 Added TypeBinary and TypeAscii just to help a little bit.
May 01, 1998 V2.33 Added check for continuation lines in NextxPutAsync
May 05, 1998 V2.34 Added some more delay in WMFtpCloseData.
May 13, 1998 V2.35 In passive mode STOR or APPE, changed the sequence: now
             wait for connection established before sending the STOR or APPE
             command to FTP server.
May 19, 1998 V2.36 TransfertStats made virtual.
Jun 25, 1998 V2.37 Revised code for 'connection reset by peer' syndrome
Jul 09, 1998 V2.38 Adpted for Delphi 4
Jul 23, 1998 V2.39 Made ResumeAt property R/W
             Added code from Yaron Golan <yarong@shani.com> to fix PASV + REST
             and to add OnDisplayFile code to view a file on the fly.
Aug 04, 1998 V2.40 Frank Neuhaus <neuhaus@cpa.de> found a problem in Put command
             for some FTP server. See V240 in the comments.
Aug 12, 1998 V2.41 Added 200 to the valid CWD responses.
Aug 18, 1998 V2.42 Added code to accept continuation lines not beginning by
             a number and a dash. Thanks to Al Cantu <cantu@bfs.e-mail.com>
             for pointing this problem.
Sep 16, 1998 V2.43 Made Synchronize and WaitUntilReady virtual function in
             protected section.
Oct 01, 1998 V2.44 Checked for errors in TriggerRequestDone.
Nov 09, 1998 V2.45 Reverted V2.40 changes ! Thanks to Grant Walker
             <gw@enternet.com.au> for his help in testing.
             Made block size equal to 1514 to minimize packet fragmentation
             on ethernet.
Nov 22, 1998 V2.46 changed GetTickCount cast from Integer to LongInt because
             of overflows with Delphi 1. Suggested by Terry Byrne
             <terryb@fidlar.com>
Dec 22, 1998 V2.47 Corrected DisplayFile which forgot the last character.
             Thanks to max@zab1.chita.ru for the bug report.
             Handled exceptions while trying to connect data session.
             Replaced DisplayFlag by DysplayFileFlag.
Feb 14, 1999 V2.48 Indirectly call winsock functions using wsocket because
             wsocket provide runtime dynamic link instead of loadtime link.
             This allows a program to use FTP if it discover that winsock is
             installed and still run if winsock is not installed.
Mar 13, 1999 V2.49 Added FPutSessionOpened flag and combine it with
             FStorAnswerRcvd flag to synchronize start of data sending.
             Thanks to Frank Neuhaus for his clear analysis.
Mar 20, 1999 V2.50 Added Options property
Mar 23, 1999 V2.51 Corrected a bug introcuded in last version which truncated
             the first character of the second line of a multiline answer on
             some servers.
May 04, 1999 V2.52 Corrected an access violation in DataSocketGetDataAvailable.
             Thanks to Steve Plegge for pointing that bug.
May 21, 1999 V2.53 Added FRequestResult to ControlSocketDnsLookupDone. Thanks
             to Wu'hao <wvhao@263.net> for finding this bug.
Jul 17, 1999 V2.54 Added OnError event and DisplayFileMode property. Thanks to
             Pieter Snyman <pgws@iafrica.com> for his work.
             Accepted answer 200 for successful rename.
             Leho Kraav <macmanos@online.ee> found that some FTP server return
             this code.
             Cleared FByteCount from PortAsync as suggested by Simon Hoerup
             <cas@casdk.com> to help some progress indicator implementation.
Aug 04, 1999 V2.55 Corrected a bug with Delphi 1 where a buffer overflow may
             occurs when receiving commands longer than 254 bytes.
             Thanks to Craig Johnson <Craig_Johnson@emsinfo.com> for finding it.
             Also casted FTimeOut to LongInt for computation to prevent
             overflow with Delphi 1 for long timeout.
Aug 12, 1999 V2.56 HandleError was not correctly handling error message !
             thank to Kim M�lg�rd Nielsen <kmn@bcview.com>
Aug 20, 1999 V2.57 Revised conditional compilation, adapted for BCB4, set
             compile options same as TWSocket.
             Added DnsResult property as suggested by Heedong Lim
             <hdlim@dcenlp.chungbuk.ac.kr>. This property is accessible from
             OnStateChange when state is ftpWaitingBanner.
             Added checks for FLocalStream being destroyed.
Sep 5, 1999  V2.58 Heedong Lim <hdlim@dcenlp.chungbuk.ac.kr> found a missing
             assignation to FRequestResult in ControlSocketSessionConnected.
Sep 11, 1999 V2.59 Added OnBgException. Thanks to William Sorensen
             <tzimisce@mwaccess.net> for suggesting it.
Oct 30, 1999 V2.60 Changed TargetPort and DataPort from integer to WORD so
             that Delphi 1 is able to handle port greater than 32K. Bug and
             and fix by Duncan Gold <Gold@esg-us.com>.
Nov 22, 1999 V2.61 Allow continuation lines in all responses.
Nov 24, 1999 V2.62 RestPut command by Alexander Burlakov <alex@helexis.com>
             Added RestartPut. Added ftpNoAutoResumeAt option.
Dec 26, 1999 V2.63 Corrected a bug in DoPutAppendAsync.
Jan 24, 1999 V2.64 Added LongInt cast to all GetTickCount.
Apr 01, 2000 V2.65 Removed any set of integer.
             Thanks to Grant Black <grant.black@smartmove.co.nz>,
             Davie <smatters@smatters.com> and
             Stephen Williams <SWilliams@fm.optus.net.au> for their work on
             this subject.
Apr 09, 2000 V2.66 Proxy / Socks / Local streams support added.
             Pieter Snyman <pgws@iafrica.com> added proxy and socks support.
             Eric <erv@sympatico.ca> added stream support (assign LocalStream
             property to switch to stream mode and LocalFileName to switch to
             normal file mode).
Jun 10, 2000 V2.67 Added NOFORMS conditional compile to be able to build a
             program (console mode, dll or other) without using the forms unit
             (because forms unit makes programs much bigger). See NOFORMS
             related comments in wsocket.pas source file for correct use.
             See also OnMessagePump event and Terminated property.
Jul 15, 2000 V2.68 Added ProxyPort property. Handled non standard port when
             connecting thru proxy.
Jul 21, 2000 V2.69 Implemented check for ABOR, STAT and QUIT commands so that
             it doesn't check if previous command is done.
             By Davie <smatters@smatters.com>.
             Tomas Lannestedt <proprat@algonet.se> found a bug when using
             streams. Now it correctly handled stream clearing.
Sep 17, 2000 V2.70 Eugene Mayevski <Mayevski@eldos.org> moved Controls use
             out of NOFORMS way.
Nov 11, 2000 V2.71 Cleared FErrorMessage in ExecAsync. Thanks to Jake Traynham
             <jake@comm-unity.net> for finding this bug.
Nov 30, 2000 V2.72 Added a Sleep in DataSocketPutDataSent, and use CloseDelayed
             this will prevent some trucated file transfers.
Feb 17, 2001 V2.73 Better WaitUntilReady: check also ftpInternalReady.
             By Davie <smatters@smatters.com>.
Jun 16, 2001 V2.74 Added conditional compile for Delphi 6
Jun 18, 2001 V2.75 Use AllocateHWnd and DeallocateHWnd from wsocket.
Jul 26, 2001 V2.76 Accept range 150-159 for status code after RETR command.
             Peter Calum <pemca@tdk.dk> found some FTP server returning
             unusual status code (and not conforming to RFC !). I don't like to
             work arround other's bugs, but in this case this shouldn't hurt
             anything.
Jul 28, 2001 V2.77 Cleared FNextRequest in HighLevelAsync and TriggerRequestDone
             as suggested by Davie <smatters@smatters.com>.
             Added AbortXfer and AbortXferAsync to abort a running transfert
             without breaking connection.
Sep 09, 2001 V2.78 Beat Boegli <leeloo999@bluewin.ch> added LocalAddr property
             for multihomed hosts.
Sep 13, 2001 V2.79 Bug fix by Beat Boegli <leeloo999@bluewin.ch> related to
             his previous changes. Now works with passive mode put.
Nov 02, 2001 V2.80 Added DisplayLastResponse in ControlSocketDataAvailable to
             give continuation lines to OnDisplay event.
             Accept 250 answer as well as 257 for MKD command as suggested by
             Simon Horup <cas@casdk.com>.
Feb 12, 2002 V2.82 "Soltann" <soltann@wanadoo.fr> added code to extract IP
             from passive mode reply so that transfer from another server is
             possible (See TargetIP in code).
Apr 06, 2002 V2.83 Added code 257 to allowed code list for CDUpAsync as
             suggest by <Davie@smatters.com>.
             Fixed a problem in ControlSocketSessionClosed where error code was
             not checked. Bug found by <Davie@smatters.com>.
Apr 20, 2002 V2.84 Removed useless units from uses clause.
Jun 28, 2002 V2.85 Removed check for ftpFctPut and FPassive in
             TriggerRequestDone which cause trouble with passive mode and sync
             operation. Thanks to "Gunnar" <gulb@gmx.de>.
Oct 26, 2002 V2.85 Use wsoNoReceiveLoop option with data session.
             Set OnSessionAvalable handler before calling listen as suggested
             by Gunnar <gulb@gmx.de>.
Nov 11, 2002 V2.86 Changed FtpCliDeallocateHWnd argument from HWND to Cardinal
             becasue BCB doesn't like HWND when deriving acomponent from
             TFtpCli (BCB bug ?).
Jan 04, 2003 V2.87 Published OnError event
Feb 15, 2003 V2.88 Ignore empty lines in responses from server. Thansk to
             Chris Rendell <appsolca@yahoo.ca> for finding this one.
Oct 26, 2003 V2.90 Added FEAT, MLSD, MDTM commands - not supported by all
             servers (not IIS5) added LastMultiResponse with last command
             response, may be multiple lines, all with CRLF by Angus Robertson,
             angus@magsys.co.uk
Jan 03, 2004 V2.91 Made OnMessagePump public, use it when MultiThread is true.
May 20, 2004 V2.92 Implemented FTPS (SSL) support. Require ICS-SSL.
Aug 20, 2004 V2.93 Use MsgWaitForMultipleObjects in WaitUntil ready instead
             of simple Sleep(). This make CPU use slow down considerably.
Aug 22, 2004 V2.94 Angus Robertson, added MFMT modify file modification time
             added MD5 command to get file hash sum (use FileMD5(file) in
             md5.pas to check it)
             added SupportedExtensions property set of TFtpFeat which features
             server supports (note SupportedExtensions replaces SupportXXX
             flags which have gone)
Aug 30, 2004 V2.95 Added option ftpWaitUsingSleep so that WaitUntilReady use
             Sleep instead of MsgWaitForMultipleObjects because Angus said he
             found a case where it is faster to use Sleep.
Oct 31, 2004 V2.96 Added support for ACCT command.
             Thanks to Igor Siticov <support@sicomponents.com> for his code.
Dec 06, 2004 V2.97 In TCustomFtpCli.HandleBackGroundException: Replaced Abort
             by AbortAsync. Thanks to Lee Grissom <leegrissom@earthlink.net>
             for finding this one.
May 23, 2005 V2.98 Added methods DataSocketPutAppendInit and DataSocketGetInit
             to ease SSL enabled version.
             Fixed DataSocketPutDataSent to call ShutDown instead of
             CloseDelayed. This avoid file truncation that rarely occured.
May 26, 2005 V2.99 Fixed Md5Async to correctly use MD5 command. Thanks to
             Johan 'Zarkow' Munkestam <Zarkow@missy.mine.nu>.
Sept 4, 2005 V2.100 fixed a long term problem with the data connection being
             closed before winsock had sent the last block, seemed to happen
             only with put files about 9 to 10K in size, now waiting until
             wsocket has sent the correct number of characters
             Also raise exception if put fails with a wsocket error
             Thanks to Tobias Giesen <tobias@tgtools.de> for the fix
             Allow TFtpCli to used again if linked with SSL
             Also minor additions to some response codes,
             and some async literal fixes, by Angus Robertson, my original bugs
             improved TransfertStats, allow wrap at 49 days, don't show 0 secs or silly bps
Sept 6, 2005 V2.101 64-bit support for Delphi 6 and later, for transfers larger
             than 2 gigs.  Note only LocalFileName mode supports resume over 2 gigs,
             due to limitation in TStream.  Check if seek fails and report error.
             Report real error opening local file (might be seek range error, not IO)
             by Angus Robertson, angus@magsys.co.uk
Dec 15, 2005 V2.102 A. Garrels,  missing SSL-properties added to
             DataSocketPutSessionAvailable.
Dec 18, 2005 V2.103 fix for zero duration transfers, by Angus
             Added Mode Z support which compresses data using ZLIB
Dec 30, 2005 V2.104 A. Garrels, added IcsLogger.
Jan 3, 2005  V2.105 Added TBufferedFileStream from Arno Garrels to improve performance, by Angus
             Replaced more old debug code with new loggin, by Angus
Jan 10, 2005 V2.106 Commands "AUTH TLS" and "CCC" added, re-issuing of the AUTH
             command performs a SSL re-negotiation now instead of an initial
             SSL handshake, see RFC4217, changes by Arno Garrels.

 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
unit FtpCli;

{$B-}             { Enable partial boolean evaluation   }
{$T-}             { Untyped pointers                    }
{$X+}             { Enable extended syntax              }
{$I ICSDEFS.INC}
{$IFDEF DELPHI6_UP}
    {$WARN SYMBOL_PLATFORM   OFF}
    {$WARN SYMBOL_LIBRARY    OFF}
    {$WARN SYMBOL_DEPRECATED OFF}
    {$DEFINE USE_MODEZ}          { V2.102 }
    {$DEFINE USE_BUFFERED_STREAM}   { V2.105 }
    {$DEFINE UseBandwidthControl}   { V2.106 }
{$ENDIF}
{$IFNDEF VER80}   { Not for Delphi 1                    }
    {$H+}         { Use long strings                    }
    {$J+}         { Allow typed constant to be modified }
{$ENDIF}
{$IFDEF BCB3_UP}
    {$ObjExportAll On}
{$ENDIF}
{_DEFINE TRACE}
{$IFDEF DELPHI1}
    {$DEFINE NO_DEBUG_LOG} { Not for Delphi 1 }
{$ENDIF}


interface

uses
    Messages,
{$IFDEF USEWINDOWS}
    Windows,
{$ELSE}
    WinTypes, WinProcs,
{$ENDIF}
    SysUtils, Classes,
{$IFNDEF NOFORMS}
    Forms, Controls,
{$ENDIF}
{ You must define USE_SSL so that SSL code is included in the component.    }
{ To be able to compile the component, you must have the SSL related files  }
{ which are _NOT_ freeware. See http://www.overbyte.be for details.         }
{$IFDEF USE_SSL}
    IcsSSLEAY, IcsLIBEAY,
{$ENDIF}
{$IFDEF USE_MODEZ}              { V2.102 }
    {$I IcsZlib.inc}
    IcsZlibHigh,
    {$IFDEF USE_ZLIB_OBJ}
        IcsZLibObj,                     {interface to access ZLIB C OBJ files}
    {$ELSE}
        IcsZLibDll,                     {interface to access zLib1.dll}
    {$ENDIF}
{$ENDIF}
{$IFDEF UseBandwidthControl}
    ExtCtrls,
{$ENDIF}
{$IFNDEF NO_DEBUG_LOG}
  IcsLogger,
{$ENDIF}
{$IFDEF USE_BUFFERED_STREAM}  { V2.103 }
    IcsStreams,
{$ENDIF}
  WSocket, FtpSrvT;    { V2.90  time and date functions }

const
  FtpCliVersion      = 2106;
  CopyRight : String = ' TFtpCli (c) 1996-2006 F. Piette V2.106 ';

const
  BLOCK_SIZE          = 1460; { 1514 - TCP header size }
  WM_FTP_REQUEST_DONE = WM_USER + 1;
  WM_FTP_SENDDATA     = WM_USER + 2;
  WM_FTP_CLOSEDOWN    = WM_USER + 3;  { V2.100 can we duplicate message Ids with wsocket? }
{$IFDEF VER80}
  { Delphi 1 has a 255 characters string limitation }
  FTP_RCV_BUF_SIZE = 255;
{$ELSE}
  FTP_RCV_BUF_SIZE = 4096;
{$ENDIF}

type
  { Types sslTypeAuthTls, sslTypeAuthSsl are known as explizit protection }
  TFtpCliSslType  = (sslTypeNone, sslTypeAuthTls, sslTypeAuthSsl,        { V2.106 }
                     sslTypeImplizit);
  TFtpOption      = (ftpAcceptLF, ftpNoAutoResumeAt, ftpWaitUsingSleep, ftpBandwidthControl); { V2.106 }
  TFtpOptions     = set of TFtpOption;
  TFtpExtension   = (ftpFeatNone, ftpFeatSize, ftpFeatRest, ftpFeatMDTMYY,
                     ftpFeatMDTM, ftpFeatMLST, ftpFeatMFMT, ftpFeatMD5,
                     ftpFeatAuthSSL, ftpFeatAuthTLS, ftpFeatProtP,
                     ftpFeatProtC, ftpFeatModeZ, ftpFeatCcc, ftpFeatPbsz);
  TFtpExtensions  = set of TFtpExtension; { V2.94 which features server supports }
  TFtpTransMode   = (ftpTransModeStream, ftpTransModeZDeflate) ;  { V2.102 }
  TZStreamState   = (ftpZStateNone, ftpZStateSaveDecom, ftpZStateSaveComp{,
                     ftpZStateImmDecon, ftpZStateImmComp});   { V2.102 }
  TFtpState       = (ftpNotConnected,  ftpReady,         ftpInternalReady,
                     ftpDnsLookup,     ftpConnected,     ftpAbort,
                     ftpInternalAbort, ftpWaitingBanner, ftpWaitingResponse,
                     ftpPasvReady);
  TFtpRequest     = (ftpNone,          ftpOpenAsync,     ftpUserAsync,
                     ftpPassAsync,     ftpCwdAsync,      ftpConnectAsync,
                     ftpReceiveAsync,  ftpDirAsync,      ftpLsAsync,
                     ftpPortAsync,     ftpGetAsync,      ftpDirectoryAsync,
                     ftpListAsync,     ftpSystemAsync,   ftpSystAsync,
                     ftpQuitAsync,     ftpAbortXferAsync,
                     ftpSizeAsync,     ftpPutAsync,      ftpAppendAsync,
                     ftpFileSizeAsync, ftpRqAbort,       ftpMkdAsync,
                     ftpRmdAsync,      ftpRenameAsync,   ftpDeleAsync,
                     ftpRenAsync,      ftpRenToAsync,    ftpRenFromAsync,
                     ftpDeleteAsync,   ftpMkdirAsync,    ftpRmdirAsync,
                     ftpPwdAsync,      ftpQuoteAsync,    ftpCDupAsync,
                     ftpDoQuoteAsync,  ftpTransmitAsync, ftpTypeSetAsync,
                     ftpRestAsync,     ftpRestGetAsync,  ftpRestartGetAsync,
                     ftpRestPutAsync,  ftpRestartPutAsync,
                     ftpMlsdAsync,     ftpFeatAsync,     ftpMlstAsync,
                     ftpMdtmAsync,     ftpMdtmyyAsync,   ftpAuthAsync,
                     ftpMfmtAsync,     ftpMd5Async,      ftpAccountAsync,
                     ftpProtAsync,     ftpPbszAsync,     ftpModeZAsync,
                     ftpOptsAsync,     ftpCccAsync);
  TFtpFct         = (ftpFctNone,       ftpFctOpen,       ftpFctUser,
                     ftpFctPass,       ftpFctCwd,        ftpFctSize,
                     ftpFctMkd,        ftpFctRmd,        ftpFctRenFrom,
                     ftpFctRenTo,      ftpFctGet,        ftpFctDir,
                     ftpFctQuit,       ftpFctSyst,       ftpFctDele,
                     ftpFctPwd,        ftpFctQuote,      ftpFctPut,
                     ftpFctTypeSet,    ftpFctRest,       ftpFctCDup,
                     ftpFctLs,         ftpFctAppend,     ftpFctPort,
                     ftpFctAbortXfer,  ftpFctMlsd,       ftpFctFeat,
                     ftpFctMlst,       ftpFctMdtm,       ftpFctMdtmyy,
                     ftpFctAuth,       ftpFctMfmt,       ftpFctMd5,
                     ftpFctAcct,       ftpFctProt,       ftpFctPbsz,
                     ftpFctModeZ,      ftpFctOpts,       ftpFctCcc);
  TFtpFctSet      = set of TFtpFct;
  TFtpShareMode   = (ftpShareCompat,    ftpShareExclusive,
                     ftpShareDenyWrite, ftpShareDenyRead,
                     ftpShareDenyNone);
  TFtpDisplayFileMode = (ftpLineByLine, ftpBinary);
  TFtpConnectionType  = (ftpDirect, ftpProxy, ftpSocks4, ftpSocks4A, ftpSocks5);
  TFtpDisplay     = procedure(Sender    : TObject;
                              var Msg   : String) of object;
  TFtpProgress    = procedure(Sender    : TObject;
                              Count     : LongInt;
                              var Abort : Boolean) of object;
{$IFDEF STREAM64}                      { V2.101 }
  TFtpProgress64  = procedure(Sender    : TObject;
                              Count     : Int64;
                              var Abort : Boolean) of object;
{$ENDIF}
  TFtpCommand     = procedure(Sender    : TObject;
                              var Cmd   : String) of object;
  TFtpRequestDone = procedure(Sender    : TObject;
                              RqType    : TFtpRequest;
                              ErrCode   : Word) of object;
  TFtpReadyToTransmit = procedure(Sender      : TObject;
                                  var bCancel : Boolean) of object;
  TFtpNextProc    = procedure of object;

  FtpException = class(Exception);

  TCustomFtpCli = class(TComponent)
  protected
    FWindowHandle       : HWND;
    FHostName           : String;
    FPort               : String;
    FDataPortRangeStart : DWORD;  {JT}
    FDataPortRangeEnd   : DWORD;  {JT}
    FLastDataPort       : DWORD;  {JT}
    FLocalAddr          : String; {bb}
    FUserName           : String;
    FPassWord           : String;
    FAccount            : String;
    FLocalFileName      : String;
    FHostFileName       : String;
    FHostDirName        : String;
    FDnsResult          : String;
    FType               : Char;
    FShareMode          : Word;
    FDisplayFileMode    : TFtpDisplayFileMode;
    FConnectionType     : TFTPConnectionType;
    FProxyServer        : String;
    FProxyPort          : String;
    FAppendFlag         : Boolean;
    FDisplayFileFlag    : Boolean;
    FControlSocket      : TWSocket;
    FDataSocket         : TWSocket;
    FStartTime          : LongInt;
    FStopTime           : LongInt;
    FState              : TFtpState;
    FStatusCode         : LongInt;
    FRequestResult      : Integer;
    FFctSet             : TFtpFctSet;
    FFctPrv             : TFtpFct;
    FHighLevelResult    : Integer;
    FHighLevelFlag      : Boolean;
    FRestartFlag        : Boolean;
    FOptions            : TFtpOptions;
    FOnDisplay          : TFtpDisplay;
    FOnDisplayFile      : TFtpDisplay;
    FOnError            : TFtpDisplay;
    FOnCommand          : TFtpCommand;
    FOnResponse         : TNotifyEvent;
    FOnSessionConnected : TSessionConnected;
    FOnSessionClosed    : TSessionClosed;
    FOnStateChange      : TNotifyEvent;
    FOnRequestDone      : TFtpRequestDone;
    FOnProgress         : TFtpProgress;
    FOnReadyToTransmit  : TFtpReadyToTransmit;
    FOnBgException      : TBgExceptionEvent;
    FLocalStream        : TStream;
    FRequestType        : TFtpRequest;
    FRequestDoneFlag    : Boolean;
    FReceiveBuffer      : array [0..FTP_RCV_BUF_SIZE - 1] of char;
    FReceiveLen         : Integer;
    FLastResponse       : String;
    FLastResponseSave   : String;  { To save FLastResponse when quitting }
    FPasvResponse       : String;  { To fix REST + PASV transfers }
    FStatusCodeSave     : LongInt; { To save FStatusCode when quitting }
    FErrorMessage       : String;
    FError              : Word;    { To save Error when data connection closed }
    FGetCommand         : String;
    FConnected          : Boolean;
    FSendBuffer         : array [0..BLOCK_SIZE - 1] of char;
{$IFDEF STREAM64}                      { V2.101 }
    FByteCount          : Int64;
    FSizeResult         : Int64;
    FResumeAt           : Int64;
    FOnProgress64       : TFtpProgress64;
{$ELSE}
    FByteCount          : LongInt;
    FSizeResult         : LongInt;
    FResumeAt           : LongInt;
{$ENDIF}
    FDirResult          : String;
    FNext               : TFtpNextProc;
    FWhenConnected      : TFtpNextProc;
    FDoneAsync          : TFtpNextProc;
    FOkResponses        : array [0..15] of Integer;
    FNextRequest        : TFtpNextProc;
    FServerSaidDone     : Boolean;
    FFileReceived       : Boolean;
    FFileSent           : Boolean;
    FPassive            : Boolean;
    FEofFlag            : Boolean;
    FStorAnswerRcvd     : Boolean;
    FPutSessionOpened   : Boolean;
    FStreamFlag         : Boolean;
    FSupportedExtensions : TFtpExtensions; { V2.94  which features server supports }
    FMLSTFacts          : String;     { V2.90  specific new list stuff supported   }
    FRemFileDT          : TDateTime;  { V2.90  date/time for MdtmAsync and MdtmYYYYAsync and MfmtAsync }
    FRemFacts           : String;     { V2.90 response to MLST command, facts about remote file }
    FLastMultiResponse  : String;     { V2.90  last command response, may be multiple lines, all with CRLF }
    FMd5Result          : String;     { V2.94 result for MD5 }
    FCloseEndTick       : DWORD;      { V2.100 to avoid waiting for ever  }
    FCloseEndSecs       : DWORD;      { V2.100 how long to wait for final packet to be sent }
    FNewOpts            : string;        { V2.102 arguments for OPTS command }
    FTransferMode       : TFtpTransMode; { V2.102 new tranfer mode }
    FCurrTransMode      : TFtpTransMode; { V2.102 current transfer mode }
    FSslType            : TFtpCliSslType;{ V2.106 }
{$IFDEF USE_MODEZ}
    FZStreamState       : TZStreamState; { V2.102 current Zlib stream state }
    FZStreamRec         : TZStreamRec;   { V2.102 Zlib stream control record }
    FModeZStream        : TMemoryStream;   { V2.102 compressed data stream  }
{$ENDIF}
{$IFDEF UseBandwidthControl}              { V2.106 }
    FBandwidthLimit     : Integer;  // Bytes per second
    FBandwidthSampling  : Integer;  // mS sampling interval
    FBandwidthCount     : Int64;    // Byte counter
    FBandwidthMaxCount  : Int64;    // Bytes during sampling period
    FBandwidthTimer     : TTimer;
    FBandwidthPaused    : Boolean;
    procedure BandwidthTimerTimer(Sender : TObject);
{$ENDIF}
    procedure SetSslType(const Value: TFtpCliSslType); virtual; { V2.106 }
{$IFNDEF NO_DEBUG_LOG}
    function  GetIcsLogger: TIcsLogger;   { 2.104 }
    procedure SetIcsLogger(const Value: TIcsLogger);
    procedure DebugLog(LogOption: TLogOption; const Msg : string); virtual; { 2.104 }
    function  CheckLogOptions(const LogOption: TLogOption): Boolean; virtual; { 2.104 }
{$ENDIF}
    procedure   SetErrorMessage;
    procedure   DataSocketGetDataAvailable(Sender: TObject; ErrCode : word);
    procedure   DataSocketGetSessionConnected(Sender: TObject; ErrCode : word);
    procedure   DataSocketPutSessionConnected(Sender: TObject; ErrCode : word);
    procedure   DataSocketGetSessionAvailable(Sender: TObject; ErrCode : word);
    procedure   DataSocketGetSessionClosed(Sender: TObject; ErrCode : word);
    procedure   DataSocketPutDataAvailable(Sender: TObject; ErrCode : word);
    procedure   DataSocketPutDataSent(Sender: TObject; ErrCode : word);
    procedure   DataSocketPutSessionAvailable(Sender: TObject; ErrCode : word);
    procedure   DataSocketPutSessionClosed(Sender: TObject; ErrCode : word);
    procedure   SendCommand(Cmd : String); virtual;
    procedure   TriggerDisplay(Msg : String); virtual;
    procedure   TriggerReadyToTransmit(var bCancel : Boolean); virtual;
    procedure   TriggerDisplayFile(Msg : String); virtual;
    procedure   TriggerError(Msg: String); virtual;
    procedure   DisplayLastResponse;
    procedure   Notification(AComponent: TComponent; Operation: TOperation); override;
    function    Progress : Boolean; virtual;
    procedure   ControlSocketDnsLookupDone(Sender: TObject; ErrCode: Word);
    procedure   ControlSocketSessionConnected(Sender: TObject; ErrCode: Word); virtual;
    procedure   ControlSocketDataAvailable(Sender: TObject; ErrCode: Word);
    procedure   ControlSocketSessionClosed(Sender: TObject; ErrCode: Word);
    procedure   DataSocketPutAppendInit(const TargetPort, TargetIP : String); virtual;
    procedure   DataSocketGetInit(const TargetPort, TargetIP : String); virtual;
    procedure   TriggerRequestDone(ErrCode: Word);
    procedure   TriggerStateChange;
    procedure   StateChange(NewState : TFtpState);
    procedure   PortAsync; virtual;
    procedure   DoneQuitAsync;
    procedure   ExecAsync(RqType      : TFtpRequest;
                          Cmd         : String;
                          OkResponses : array of Word;
                          DoneAsync   : TFtpNextProc);
    procedure   NextExecAsync;
    procedure   DoGetAsync(RqType : TFtpRequest);
    procedure   Next1GetAsync;
    procedure   Next2GetAsync;
    procedure   Next3GetAsync;
    procedure   Next1PutAsync;
    procedure   Next2PutAsync;
    procedure   Next3PutAsync;
    procedure   DoHighLevelAsync;
    procedure   DoPutAppendAsync;
    procedure   HighLevelAsync(RqType : TFtpRequest; Fcts : TFtpFctSet);
    procedure   HandleError(const Msg : String);
    function    CheckReady : Boolean;
    procedure   TransfertStats; virtual;
    procedure   ExtractMoreResults;
    procedure   SetBinary(Value: Boolean);
    function    GetBinary: Boolean;
    function    GetConnected: Boolean;
    procedure   SetShareMode(newValue: TFtpShareMode);
    function    GetShareMode: TFtpShareMode;
    procedure   SetDisplayFileMode(NewValue: TFtpDisplayFileMode);
    function    GetDisplayFileMode: TFtpDisplayFileMode;
    procedure   SetConnectionType(NewValue: TFtpConnectionType);
    function    GetConnectionType: TFtpConnectionType;
    procedure   SetSocksPassword(NewValue: String);
    function    GetSocksPassword: String;
    procedure   SetSocksPort(NewValue: String);
    function    GetSocksPort: String;
    procedure   SetSocksServer(NewValue: String);
    function    GetSocksServer: String;
    procedure   SetSocksUserCode(NewValue: String);
    function    GetSocksUserCode: String;
    procedure   SetPassive(NewValue: Boolean);
    procedure   WndProc(var MsgRec: TMessage); virtual;
    function    FtpCliAllocateHWnd(Method: TWndMethod): HWND; virtual;
    procedure   FtpCliDeallocateHWnd(WHandle: Cardinal); virtual;
    procedure   HandleBackGroundException(E: Exception); virtual;
    procedure   WMFtpRequestDone(var msg: TMessage);
                message WM_FTP_REQUEST_DONE;
    procedure   WMFtpSendData(var msg: TMessage);
                message WM_FTP_SENDDATA;
    procedure   WMFtpCloseDown(var msg: TMessage);      { V2.100 }
                message WM_FTP_CLOSEDOWN;
    procedure   DestroyLocalStream;
    procedure   SetLocalStream (Stream:TStream);
    procedure   SetLocalFileName (FileName:String);
    procedure   SetDataPortRangeStart (NewValue:DWord); {JT}
    procedure   SetDataPortRangeEnd (NewValue:DWord); {JT}
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;

    procedure   OpenAsync;       virtual;
    procedure   UserAsync;       virtual;
    procedure   PassAsync;       virtual;
    procedure   AcctAsync;       virtual;
    procedure   ConnectAsync;    virtual;
    procedure   QuitAsync;       virtual;
    procedure   AbortAsync;      virtual;
    procedure   GetAsync;        virtual;
    procedure   ExecGetAsync;    virtual;
    procedure   ReceiveAsync;    virtual;
    procedure   PutAsync;        virtual;
    procedure   ExecPutAsync;    virtual;
    procedure   TransmitAsync;   virtual;
    procedure   AppendAsync;     virtual;
    procedure   ExecAppendAsync; virtual;
    procedure   AppendFileAsync; virtual;
    procedure   ExecDirAsync;    virtual;
    procedure   DirAsync;        virtual;
    procedure   ExecLsAsync;     virtual;
    procedure   LsAsync;         virtual;
    procedure   TypeSetAsync;    virtual;
    procedure   TypeBinaryAsync; virtual;
    procedure   TypeAsciiAsync;  virtual;
    procedure   PwdAsync;        virtual;
    procedure   CwdAsync;        virtual;
    procedure   CDupAsync;       virtual;
    procedure   DirectoryAsync;  virtual;
    procedure   ListAsync;       virtual;
    procedure   SystAsync;       virtual;
    procedure   SystemAsync;     virtual;
    procedure   SizeAsync;       virtual;
    procedure   FileSizeAsync;   virtual;
    procedure   MkdAsync;        virtual;
    procedure   MkdirAsync;      virtual;
    procedure   RmdAsync;        virtual;
    procedure   RmdirAsync;      virtual;
    procedure   DeleAsync;       virtual;
    procedure   DeleteAsync;     virtual;
    procedure   RenFromAsync;    virtual;
    procedure   RenToAsync;      virtual;
    procedure   RenAsync;        virtual;
    procedure   RenameAsync;     virtual;
    procedure   QuoteAsync;      virtual;
    procedure   DoQuoteAsync;    virtual;
    procedure   AbortXferAsync;  virtual;
    procedure   RestAsync;       virtual;
    procedure   RestGetAsync;    virtual;
    procedure   RestartGetAsync; virtual;
    procedure   RestPutAsync;    virtual;
    procedure   RestartPutAsync; virtual;
    procedure   ExecMlsdAsync;   virtual;    { V2.90 }
    procedure   MlsdAsync;       virtual;    { V2.90  machine list directory     }
    procedure   MlstAsync;       virtual;    { V2.90  machine list file          }
    procedure   FeatAsync;       virtual;    { V2.90  supported extensions       }
    procedure   MdtmAsync;       virtual;    { V2.90  get file modification time }
    procedure   MdtmyyAsync;     virtual;    { V2.90  set file modification time }
    procedure   AuthAsync;       virtual;    { V2.106 }
    procedure   ProtAsync;       virtual;
    procedure   PbszAsync;       virtual;
    procedure   CccAsync;        virtual;    { V2.106 }
    procedure   AuthenticateSslAsync; virtual;
    procedure   MfmtAsync;       virtual;    { V2.94  modify file modification time }
    procedure   Md5Async;        virtual;    { V2.94  md5 hash sum  }
    procedure   ModeZAsync;      virtual;    { V2.102  Mode Z  }
    procedure   OptsAsync;       virtual;    { V2.102  Opts, set Mode Z options }
    property    Handle            : HWND                 read  FWindowHandle;
    property    LastResponse      : String               read  FLastResponse;
    property    LastMultiResponse : String               read  FLastMultiResponse;  { V2.90  multiple lines }
    property    ErrorMessage      : String               read  FErrorMessage;
    property    DnsResult         : String               read  FDnsResult;
    property    DirResult         : String               read  FDirResult;
    property    ControlSocket     : TWSocket             read  FControlSocket;
    property    DataSocket        : TWSocket             read  FDataSocket;
    property    Connected         : Boolean              read  GetConnected;
    property    StatusCode        : LongInt              read  FStatusCode;
    property    State             : TFtpState            read  FState;
    property    RequestType       : TFtpRequest          read  FRequestType;
    property    MLSTFacts         : String               read  FMLSTFacts;     { V2.90 specific new list stuff supported }
    property    RemFacts          : String               read  FRemFacts;      { V2.90 facts about remote file           }
    property    SupportedExtensions : TFtpExtensions     read  FSupportedExtensions;   { V2.94  which supported features }
    property    RemFileDT         : TDateTime            read  FRemFileDT      { V2.90 date/time for MdtmAsync           }
                                                         write FRemFileDT;     {       and MdtmYYYYAsync;                }
    property    Md5Result         : String               read  FMd5Result;     { V2.94 MD5 sum                           }
    property    Options           : TFtpOptions          read  FOptions
                                                         write FOptions;
    property    LocalStream       : TStream              read  FLocalStream
                                                         write SetLocalStream;
{$IFDEF STREAM64}                { V2.101 }
    property    ByteCount         : Int64                read  FByteCount;
    property    SizeResult        : Int64                read  FSizeResult;
    property    ResumeAt          : Int64                read  FResumeAt
                                                         write FResumeAt;
    property    OnProgress64      : TFtpProgress64       read  FOnProgress64
                                                         write FOnProgress64;
{$ELSE}
    property    ByteCount         : LongInt              read  FByteCount;
    property    SizeResult        : LongInt              read  FSizeResult;
    property    ResumeAt          : LongInt              read  FResumeAt
                                                         write FResumeAt;
{$ENDIF}
{$IFDEF UseBandwidthControl}
    property BandwidthLimit       : Integer              read  FBandwidthLimit    { V2.106 }
                                                         write FBandwidthLimit;
    property BandwidthSampling    : Integer              read  FBandwidthSampling { V2.106 }
                                                         write FBandwidthSampling;
{$ENDIF}
    property TransferMode         : TFtpTransMode        read  FTransferMode    { V2.102 }
                                                         write FTransferMode;
    property NewOpts              : string               read  FNewOpts         { V2.102 }
                                                         write FNewOpts;

    property HostName             : String               read  FHostName
                                                         write FHostName;
    property Port                 : String               read  FPort
                                                         write FPort;
    property DataPortRangeStart   : DWORD                read  FDataPortRangeStart
                                                         write SetDataPortRangeStart; {JT}
    property DataPortRangeEnd     : DWORD                read  FDataPortRangeEnd
                                                         write SetDataPortRangeEnd; {JT}
    property LocalAddr            : String               read  FLocalAddr
                                                         write FLocalAddr; {bb}
    property UserName             : String               read  FUserName
                                                         write FUserName;
    property PassWord             : String               read  FPassWord
                                                         write FPassWord;
    property HostDirName          : String               read  FHostDirName
                                                         write FHostDirName;
    property HostFileName         : String               read  FHostFileName
                                                         write FHostFileName;
{$IFNDEF NO_DEBUG_LOG}
    property IcsLogger            : TIcsLogger           read  GetIcsLogger  { 2.104 }
                                                         write SetIcsLogger;
{$ENDIF}
    property LocalFileName        : String               read  FLocalFileName
                                                         write SetLocalFileName;
    property DisplayFileFlag      : Boolean              read  FDisplayFileFlag
                                                         write FDisplayFileFlag;
    property Binary               : Boolean              read  GetBinary
                                                         write SetBinary;
    property Passive              : Boolean              read  FPassive
                                                         write SetPassive;
    property ShareMode            : TFtpShareMode        read  GetShareMode
                                                         write SetShareMode;
    property DisplayFileMode      : TFtpDisplayFileMode  read  GetDisplayFileMode
                                                         write SetDisplayFileMode;
    property ConnectionType       : TFtpConnectionType   read  GetConnectionType
                                                         write SetConnectionType;
    property ProxyServer          : String               read  FProxyServer
                                                         write FProxyServer;
    property ProxyPort            : String               read  FProxyPort
                                                         write FProxyPort;
    property SocksPassword        : String               read  GetSocksPassword
                                                         write SetSocksPassword;
    property SocksPort            : String               read  GetSocksPort
                                                         write SetSocksPort;
    property SocksServer          : String               read  GetSocksServer
                                                         write SetSocksServer;
    property SocksUserCode        : String               read  GetSocksUserCode
                                                         write SetSocksUserCode;
    property Account              : String               read  FAccount
                                                         write FAccount;
    property CloseEndSecs         : DWORD                read  FCloseEndSecs  { V2.100 }
                                                         write FCloseEndSecs;
    property OnDisplay            : TFtpDisplay          read  FOnDisplay
                                                         write FOnDisplay;
    property OnDisplayFile        : TFtpDisplay          read  FOnDisplayFile
                                                         write FOnDisplayFile;
    property OnError              : TFTPDisplay          read  FOnError
                                                         write FOnError;
    property OnCommand            : TFtpCommand          read  FOnCommand
                                                         write FOnCommand;
    property OnResponse           : TNotifyEvent         read  FOnResponse
                                                         write FOnResponse;
    property OnProgress           : TFtpProgress         read  FOnProgress
                                                         write FOnProgress;
    property OnSessionConnected   : TSessionConnected    read  FOnSessionConnected
                                                         write FOnSessionConnected;
    property OnSessionClosed      : TSessionClosed       read  FOnSessionClosed
                                                         write FOnSessionClosed;
    property OnRequestDone        : TFtpRequestDone      read  FOnRequestDone
                                                         write FOnRequestDone;
    property OnStateChange        : TNotifyEvent         read  FOnStateChange
                                                         write FOnStateChange;
    property OnReadyToTransmit    : TFtpReadyToTransmit  read  FOnReadyToTransmit
                                                         write FOnReadyToTransmit;
    property OnBgException        : TBgExceptionEvent    read  FOnBgException
                                                         write FOnBgException;
  end;

  TFtpClient = class(TCustomFtpCli)
  protected
    FTimeout       : Integer;                 { Given in seconds }
    FTimeStop      : LongInt;                 { Milli-seconds    }
    FMultiThreaded : Boolean;
    FTerminated    : Boolean;
    FOnMessagePump : TNotifyEvent;
    function    Progress : Boolean; override;
    function    Synchronize(Proc : TFtpNextProc) : Boolean; virtual;
    function    WaitUntilReady : Boolean; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    procedure   MessagePump;
    function    Open       : Boolean;
    function    User       : Boolean;
    function    Pass       : Boolean;
    function    acct       : Boolean;
    function    Connect    : Boolean;
    function    Cwd        : Boolean;
    function    Pwd        : Boolean;
    function    CDup       : Boolean;
    function    TypeSet    : Boolean;
    function    TypeBinary : Boolean;
    function    TypeAscii  : Boolean;
    function    Get        : Boolean;
    function    Put        : Boolean;
    function    RestPut    : Boolean;
    function    RestartPut : Boolean;
    function    Quit       : Boolean;
    function    Abort      : Boolean;
    function    Receive    : Boolean;
    function    Transmit   : Boolean;
    function    Append     : Boolean;
    function    AppendFile : Boolean;
    function    Dir        : Boolean;
    function    Directory  : Boolean;
    function    Ls         : Boolean;
    function    List       : Boolean;
    function    Mkd        : Boolean;
    function    Mkdir      : Boolean;
    function    Ren        : Boolean;
    function    Rename     : Boolean;
    function    Dele       : Boolean;
    function    Delete     : Boolean;
    function    Rmd        : Boolean;
    function    Rmdir      : Boolean;
    function    Syst       : Boolean;
    function    System     : Boolean;
    function    Size       : Boolean;
    function    FileSize   : Boolean;
    function    Quote      : Boolean;
    function    DoQuote    : Boolean;
    function    AbortXfer  : Boolean;
    function    RestGet    : Boolean;
    function    RestartGet : Boolean;
    function    Mlsd       : Boolean;    { V2.90 machine list directory     }
    function    Mlst       : Boolean;    { V2.90 machine list file          }
    function    Feat       : Boolean;    { V2.90 supported extensions       }
    function    Mdtm       : Boolean;    { V2.90 get file modification time }
    function    Mdtmyy     : Boolean;    { V2.90 set file modification time }
    function    Auth       : Boolean;    { V2.106 }
    function    Ccc        : Boolean;    { V2.106 }
    function    Prot       : Boolean;
    function    Pbsz       : Boolean;
    function    AuthenticateSsl    : Boolean;
    function    Mfmt       : Boolean;    { V2.94 modify file modification time }
    function    Md5        : Boolean;    { V2.94 get MD5 hash sum  }
    function    ModeZ      : Boolean;    { V2.102 set mode z }
    function    Opts       : Boolean;    { V2.102 set mode z options }
{$IFDEF NOFORMS}
    property    Terminated         : Boolean        read  FTerminated
                                                    write FTerminated;
{$ENDIF}
    property    OnMessagePump      : TNotifyEvent   read  FOnMessagePump
                                                    write FOnMessagePump;
  published
    property Timeout       : Integer read FTimeout       write FTimeout;
    property MultiThreaded : Boolean read FMultiThreaded write FMultiThreaded;
    property HostName;
    property Port;
    property DataPortRangeStart; {JT}
    property DataPortRangeEnd; {JT}
    property LocalAddr; {bb}
    property UserName;
    property PassWord;
    property HostDirName;
    property HostFileName;
    property LocalFileName;
    property DisplayFileFlag;
    property Binary;
    property ErrorMessage;
    property ShareMode;
    property Options;
    property ConnectionType;
    property ProxyServer;
    property SocksPassword;
    property SocksPort;
    property SocksServer;
    property SocksUserCode;
    property Account;
    property OnDisplay;
    property OnDisplayFile;
    property OnCommand;
    property OnError;
    property OnResponse;
    property OnProgress;
    property OnSessionConnected;
    property OnSessionClosed;
    property OnRequestDone;
    property OnStateChange;
    property OnReadyToTransmit;
    property OnBgException;
{$IFNDEF NO_DEBUG_LOG}
    property IcsLogger;                                             { 2.104 }
{$ENDIF}
{$IFDEF UseBandwidthControl}
    property BandwidthLimit;                                       { V2.106 }
    property BandwidthSampling;                                    { V2.106 }
{$ENDIF}
  end;

{ You must define USE_SSL so that SSL code is included in the component.    }
{ To be able to compile the component, you must have the SSL related files  }
{ which are _NOT_ freeware. See http://www.overbyte.be for details.         }
{$IFDEF USE_SSL}
    {$I FtpCliIntfSsl.inc}
{$ENDIF}

procedure Register;

implementation

uses WinSock;

{$IFNDEF WIN32}
const
    HFILE_ERROR = $FFFF;
{$ENDIF}

{$B-}  { Do not evaluate boolean expressions more than necessary }


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure Register;
begin
    RegisterComponents('FPiette', [TFtpClient
{$IFDEF USE_SSL}
                       , TSslFtpClient
{$ENDIF}
                       ]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{$IFNDEF WIN32}
procedure SetLength(var Str : String; Len : Integer);
begin
    Str[0] := chr(Len);
end;
{$ENDIF}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{$IFDEF VER80}
function TrimRight(Str : String) : String;
var
    i : Integer;
begin
    i := Length(Str);
    while (i > 0) and (Str[i] in [' ', #9]) do
        i := i - 1;
    Result := Copy(Str, 1, i);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TrimLeft(Str : String) : String;
var
    i : Integer;
begin
    if Str[1] <> ' ' then
        Result := Str
    else begin
        i := 1;
        while (i <= Length(Str)) and (Str[i] = ' ') do
            i := i + 1;
        Result := Copy(Str, i, Length(Str) - i + 1);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function Trim(Str : String) : String;
begin
    Result := TrimLeft(TrimRight(Str));
end;
{$ENDIF}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function GetFileSize(const FileName: String): LongInt;
var
    SearchRec: TSearchRec;
begin
    if FindFirst(ExpandFileName(FileName), faAnyFile, SearchRec) = 0 then begin
        Result := SearchRec.Size;
        SysUtils.FindClose(SearchRec);
    end
    else
        Result := -1;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Step over blank spaces                                                    }
function StpBlk(Data : PChar) : PChar;
begin
    Result := Data;
    if Result <> nil then begin
        while (Result^ <> #0) and (Result^ in [' ', #9, #13, #10]) do
            Inc(Result);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function GetInteger(Data : PChar; var Number : LongInt) : PChar;
var
    bSign : Boolean;
begin
    Number := 0;
    Result := StpBlk(Data);

    if Result = nil then
        Exit;

    { Remember the sign }
    if Result^ in ['-', '+'] then begin
        bSign := (Result^ = '-');
        Inc(Result);
    end
    else
        bSign  := FALSE;

    { Convert any number }
    while (Result^ <> #0) and (Result^ in ['0'..'9']) do begin
        Number := Number * 10 + ord(Result^) - ord('0');
        Inc(Result);
    end;

    { Correct for sign }
    if bSign then
        Number := -Number;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{$IFDEF STREAM64}                      { V2.101 }
function GetInt64(Data : PChar; var Number : Int64) : PChar;
var
    bSign : Boolean;
begin
    Number := 0;
    Result := StpBlk(Data);

    if Result = nil then
        Exit;

    { Remember the sign }
    if Result^ in ['-', '+'] then begin
        bSign := (Result^ = '-');
        Inc(Result);
    end
    else
        bSign  := FALSE;

    { Convert any number }
    while (Result^ <> #0) and (Result^ in ['0'..'9']) do begin
        Number := Number * 10 + ord(Result^) - ord('0');
        Inc(Result);
    end;

    { Correct for sign }
    if bSign then
        Number := -Number;
end;
{$ENDIF}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function GetQuotedString(Data : PChar; var Dst : String) : PChar;
begin
    Dst := '';
    Result := StpBlk(Data);

    if (Result = nil) then
        Exit;

    if Result^ <> '"' then
        Exit;
    Inc(Result);

    while Result^ <> #0 do begin
        if Result^ <> '"' then
            Dst := Dst + Result^
        else begin
            Inc(Result);
            if Result^ <> '"' then
                Break;
            Dst := Dst + Result^;
        end;
        Inc(Result);
    end;
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function GetNextString(Data : PChar; var Dst : String) : PChar;  { V2.94 }
begin
    Dst := '';
    Result := StpBlk(Data);

    if Result = nil then
        Exit;

    while (Result^ <> #0) and (Result^ = #32) do
        Inc(Result);  { skip leading spaces }

    while (Result^ <> #0) and (Result^ <> #32) do begin
        Dst := Dst + Result^;
        Inc(Result);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{* *                                                                     * *}
{* *                            TCustomFtpCli                            * *}
{* *                                                                     * *}
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{$IFDEF NOFORMS}
{ This function is a callback function. It means that it is called by       }
{ windows. This is the very low level message handler procedure setup to    }
{ handle the message sent by windows (winsock) to handle messages.          }
function FtpCliWindowProc(
    ahWnd   : HWND;
    auMsg   : Integer;
    awParam : WPARAM;
    alParam : LPARAM): Integer; stdcall;
var
    Obj    : TObject;
    MsgRec : TMessage;
begin
    { At window creation asked windows to store a pointer to our object     }
    Obj := TObject(GetWindowLong(ahWnd, 0));

    { If the pointer doesn't represent a TCustomFtpCli, just call the default procedure}
    if not (Obj is TCustomFtpCli) then
        Result := DefWindowProc(ahWnd, auMsg, awParam, alParam)
    else begin
        { Delphi use a TMessage type to pass parameter to his own kind of   }
        { windows procedure. So we are doing the same...                    }
        MsgRec.Msg    := auMsg;
        MsgRec.wParam := awParam;
        MsgRec.lParam := alParam;
        { May be a try/except around next line is needed. Not sure ! }
        TCustomFtpCli(Obj).WndProc(MsgRec);
        Result := MsgRec.Result;
    end;
end;
{$ENDIF}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomFtpCli.FtpCliAllocateHWnd(Method: TWndMethod) : HWND;
begin
{$IFDEF NOFORMS}
    Result := XSocketAllocateHWnd(Self);
    SetWindowLong(Result, GWL_WNDPROC, LongInt(@FtpCliWindowProc));
{$ELSE}
     { If you have AllocateHWnd undefined, then your last project was }
     { compiled with NOFORMS defined. Just recompile everything for   }
     { the new project. This will recompile wsocket.pas according to  }
     { this project settings.                                         }
     Result := WSocket.AllocateHWnd(Method);
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.FtpCliDeallocateHWnd(WHandle : Cardinal);
begin
{$IFDEF NOFORMS}
    XSocketDeallocateHWnd(WHandle);
{$ELSE}
    WSocket.DeallocateHWnd(WHandle);
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
constructor TCustomFtpCli.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);

    FWindowHandle       := FtpCliAllocateHWnd(WndProc);
    FOnDisplay          := nil;
    FOnDisplayFile      := nil;
    FType               := 'I';
    FPort               := 'ftp';
    FDataPortRangeStart := 0; {JT}
    FDataPortRangeEnd   := 0; {JT}
    FCloseEndSecs       := 5;       { V2.100 }
    FTransferMode       := FtpTransModeZDeflate ; { V2.102 new tranfer mode }
    FCurrTransMode      := FtpTransModeStream ;   { V2.102 current transfer mode }
    FNewOpts            := 'MODE Z LEVEL 8';       { V2.102 argument for OPTS command }
    FProxyPort          := 'ftp';
    FState              := ftpReady;
    FShareMode          := fmShareExclusive;
    FConnectionType     := ftpDirect;
    FProxyServer        := '';    { Should Socks properties be set to '' as well? }
    FOptions            := [ftpAcceptLF];
    FLocalAddr          := '0.0.0.0'; {bb}
    FControlSocket      := TWSocket.Create(Self);
    FControlSocket.OnSessionConnected := ControlSocketSessionConnected;
    FControlSocket.OnDataAvailable    := ControlSocketDataAvailable;
    FControlSocket.OnSessionClosed    := ControlSocketSessionClosed;
    FControlSocket.OnDnsLookupDone    := ControlSocketDnsLookupDone;
    FDataSocket                       := TWSocket.Create(Self);
    FStreamFlag                       := FALSE;
{$IFDEF UseBandwidthControl}
    FBandwidthLimit     := 10000;  // Bytes per second
    FBandwidthSampling  := 1000;   // mS sampling interval
{$ENDIF}
{$IFDEF USE_SSL}
    __DataSocket             := FDataSocket;
    FControlSocket.SslEnable := FALSE;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
destructor TCustomFtpCli.Destroy;
begin
    FtpCliDeallocateHWnd(FWindowHandle);
    { Be sure to have LocalStream closed }
    { FStreamFlag := FALSE; }
    DestroyLocalStream;
{$IFDEF UseBandwidthControl}
    if Assigned(FBandwidthTimer) then begin
        FBandwidthTimer.Free;
        FBandwidthTimer := nil;
    end;
{$ENDIF}    
    inherited Destroy;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.WndProc(var MsgRec: TMessage);
begin
    try
         with MsgRec do begin
             case Msg of
             WM_FTP_REQUEST_DONE : WMFtpRequestDone(MsgRec);
             WM_FTP_SENDDATA     : WMFtpSendData(MsgRec);
             WM_FTP_CLOSEDOWN    : WMFtpCloseDown(MsgRec);     { V2.100 }
             else
                 Result := DefWindowProc(Handle, Msg, wParam, lParam);
             end;
        end;
    except
        on E:Exception do
            HandleBackGroundException(E);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ All exceptions *MUST* be handled. If an exception is not handled, the     }
{ application will be shut down !                                           }
procedure TCustomFtpCli.HandleBackGroundException(E: Exception);
var
    CanAbort : Boolean;
begin
    CanAbort := TRUE;
    { First call the error event handler, if any }
    if Assigned(FOnBgException) then begin
        try
            FOnBgException(Self, E, CanAbort);
        except
        end;
    end;
    { Then abort the component }
    if CanAbort then begin
        try
            AbortAsync;  { 06/12/2004: Abort replaced by AbortAsync }
        except
        end;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.WMFtpRequestDone(var msg: TMessage);
begin
    if Assigned(FOnRequestDone) then
        FOnRequestDone(Self, FRequestType, Msg.LParam);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.Notification(AComponent: TComponent; Operation: TOperation);
begin
    inherited Notification(AComponent, Operation);
    if Operation = opRemove then begin
        if AComponent = FControlSocket then
            FControlSocket := nil
        else if AComponent = FDataSocket then
            FDataSocket := nil;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.SetErrorMessage;
begin
    if FErrorMessage = '' then
        FErrorMessage := FLastResponse;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.DestroyLocalStream;
{$IFDEF USE_MODEZ}
var
    NewSize: Int64;
{$ENDIF}
begin
{$IFDEF USE_MODEZ}
    if FCurrTransMode = ftpTransModeZDeflate then begin    { V1.103 }
        if FZStreamState > ftpZStateNone then begin
            if (FZStreamState = ftpZStateSaveDecom) and
                 (FModeZStream.Size > 0) and Assigned(FLocalStream) then begin
                try
                    FModeZStream.Position := 0;
                    NewSize := FLocalStream.Size ;
                    ZlibDecompressStream (FModeZStream, FLocalStream) ;
                    NewSize := FLocalStream.Size - NewSize ;
                    TriggerDisplay('! Download Size, Compressed ' + IntToStr
                            (FModeZStream.Size) + ' bytes, Uncompressed ' +
                                               IntToStr (NewSize) + ' bytes') ;
                except
                    on E:Exception do begin
                        FModeZStream.Destroy;
                        FModeZStream := nil;
                        HandleError('Failed to Decompress Stream - ' + E.Message);
                    end;
                end;
            end;
            if Assigned (FModeZStream) then FModeZStream.Destroy;
            FModeZStream := nil;
            FZStreamState := ftpZStateNone;
        end;
    end;
{$ENDIF}
    if Assigned(FLocalStream) and (FStreamFlag = FALSE) then begin
        FLocalStream.Destroy;
        FLocalStream := nil;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.SetLocalFileName(FileName: String);
begin
    FLocalFileName := FileName;
    if FileName <> '' then
        FStreamFlag := FALSE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.SetLocalStream(Stream: TStream);
begin
    FLocalStream := Stream;
    FStreamFlag  := (Stream <> nil);
    if FStreamFlag then
        FLocalFileName := '';
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.SetDataPortRangeStart(NewValue: DWORD); {JT}
begin
    if NewValue > 65535 then
        HandleError('DataPortRangeStart must be in the range 0..65535')
    else
        FDataPortRangeStart := NewValue;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.SetDataPortRangeEnd(NewValue: DWORD); {JT}
begin
    if NewValue > 65535 then
        HandleError('DataPortRangeEnd must be in the range 0..65535')
    else
        FDataPortRangeEnd := NewValue
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.TriggerDisplay(Msg : String);
begin
    if Assigned(FOnDisplay) then
        FOnDisplay(Self, Msg);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.TriggerDisplayFile(Msg : String);
begin
    if Assigned(FOnDisplayFile) then
        FOnDisplayFile(Self, Msg);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.TriggerError(Msg : String);
begin
    if Assigned(FOnError) then
        FOnError(Self, Msg);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.DisplayLastResponse;
begin
     TriggerDisplay('< ' + FLastResponse);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.StateChange(NewState : TFtpState);
begin
    if FState <> NewState then begin
        FState := NewState;
        TriggerStateChange;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomFtpCli.GetBinary : Boolean;
begin
     Result := (FType = 'I');
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.SetBinary(Value : Boolean);
begin
     if Value then
         FType := 'I'
     else
         FType := 'A';
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomFtpCli.Progress : Boolean;
var
    Abort : Boolean;
begin
    Abort := FALSE;
    if Assigned(FOnProgress) then
        FOnProgress(Self, FByteCount + FResumeAt, Abort);
{$IFDEF STREAM64}                      { V2.101 }
    if Assigned(FOnProgress64) then
        FOnProgress64(Self, FByteCount + FResumeAt, Abort);
{$ENDIF}
    if Abort then begin
        TriggerDisplay('! Abort requested');
        FDataSocket.Close;
    end;

    Result := not Abort;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.SendCommand(Cmd : String);
begin
    if Assigned(FOnCommand) then
        FOnCommand(Self, Cmd);
    TriggerDisplay('> ' + Cmd);
    if FControlSocket.State = wsConnected then
        FControlSocket.SendStr(Cmd + #13 + #10)
    { Quit when not connected never returned. }                { 01/14/06 AG}
    else begin
        if cmd = 'QUIT' then
            FStatusCode := 200
        else
            FStatusCode := 550;

         FNextRequest   := nil;
         FDoneAsync     := nil;
         FConnected     := FALSE;
         FRequestResult := FStatusCode;
         FLastResponse  := IntToStr(FStatusCode) + ' not connected';
         if FStatusCode = 550 then begin
            SetErrorMessage;
            TriggerRequestDone(550);
         end
         else
            TriggerRequestDone(0);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.HandleError(const Msg : String);
begin
    { Reset some defaults }                                         { V2.106 }
    FFctSet           := [];
    FFctPrv           := ftpFctNone;
    FLastResponse     := '';
    FErrorMessage     := '';
    FNextRequest      := nil;
    if Assigned(FOnError) then
        TriggerError(Msg)
    else
        raise FtpException.Create(Msg);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{* Return TRUE if component is ready for next operation.                    }
{* Trigger an error or return FALSE if not ready                            }
function TCustomFtpCli.CheckReady : Boolean;
begin
    Result := (FState in [ftpReady, ftpInternalReady, ftpPasvReady]);
    if not Result then
        HandleError('FTP component not ready');
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.OpenAsync;
begin
    if not CheckReady then
        Exit;
    if FConnected then begin
        HandleError('FTP component already connected');
        Exit;
    end;

    if not FHighLevelFlag then
        FRequestType := ftpOpenAsync;

    FRequestDoneFlag     := FALSE;
    FReceiveLen          := 0;
    FRequestResult       := 0;
    FDnsResult           := '';
    FMLSTFacts           := '';   { V2.90 supported extensions }
    FSupportedExtensions := [];   { V2.94 supported extensions }
    StateChange(ftpDnsLookup);
    case FConnectionType of
    ftpDirect, ftpSocks4, ftpSocks4A, ftpSocks5:
          FControlSocket.DnsLookup(FHostName);
    ftpProxy:
          FControlSocket.DnsLookup(FProxyServer);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.ExecAsync(
    RqType      : TFtpRequest;
    Cmd         : String;         { Command to execute                      }
    OkResponses : array of Word;  { List of responses like '200 221 342'    }
    DoneAsync   : TFtpNextProc);  { What to do when done                    }
var
    I : Integer;
begin
    if not((Cmd = 'ABOR') or (Cmd = 'STAT') or (Cmd = 'QUIT')) then begin
        if not CheckReady then
            Exit;

        if not FConnected then begin
            HandleError('FTP component not connected');
            Exit;
        end;
    end;

    if not FHighLevelFlag then
        FRequestType := RqType;

    for I := 0 to High(OkResponses) do
        FOkResponses[I] := OkResponses[I];
    FOkResponses[High(OkResponses) + 1] := 0;

    { V2.90 some FTP responses are multiline, welcome banner, FEAT command, }
    { keep them all                                                         }
    FLastMultiResponse := '';
    FRequestDoneFlag   := FALSE;
    FNext              := NextExecAsync;
    FDoneAsync         := DoneAsync;
    FErrormessage      := '';
    StateChange(ftpWaitingResponse);
    SendCommand(Cmd); 
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.ExtractMoreResults;
var
    NumericCode : LongInt;
    p           : PChar;
    S           : String;
begin
    if FRequestResult = 0 then begin
        if FFctPrv in [ftpFctSize] then begin
            p := GetInteger(@FLastResponse[1], NumericCode);
{$IFDEF STREAM64}                      { V2.101 }
            GetInt64(p, FSizeResult);
{$ELSE}
            GetInteger(p, FSizeResult);
{$ENDIF}
        end;
        if FFctPrv in [ftpFctMdtm] then begin  { V2.90 get file modification time }
            p := GetInteger(@FLastResponse[1], NumericCode);
            if NumericCode = 213 then begin
               GetNextString (p, S);        { V2.94 }
               FRemFileDT := MDTM2Date(S);  { UTC time }
            end
            else
                FRemFileDT := -1;
        end;
        if FFctPrv in [ftpFctCDup, ftpFctPwd, ftpFctMkd, ftpFctCwd] then begin
            p := GetInteger(@FLastResponse[1], NumericCode);
            GetQuotedString(p, FDirResult);
        end;
        if FFctPrv in [ftpFctMd5] then begin  { V2.94 get MD5 hash sum }
            FDirResult := '';
            FMd5Result := '';
            p := GetInteger(@FLastResponse[1], NumericCode);
            if NumericCode = 251 then begin
                p := GetQuotedString(p, FDirResult);
                if FDirResult = '' then p := GetNextString(p, FDirResult);
                GetNextString(p, FMd5Result);
            end;
        end;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.NextExecAsync;
var
    I : Integer;
    p : PChar;
begin
    DisplayLastResponse;
    if not (FLastResponse[1] in ['0'..'9']) then
        Exit; { Continuation line, nothing to do }
    p := GetInteger(@FLastResponse[1], FStatusCode);
    if p^ = '-' then
        Exit; { Continuation line, nothing to do }

    if FOkResponses[0] = 0 then begin
        { The list of ok responses is empty }
        if FStatusCode >= 500 then begin
            { Not a good response }
            FRequestResult := FStatusCode;
            SetErrorMessage;
        end
        else
            FRequestResult := 0;
    end
    else begin
        { We have a list of ok response codes }
        for I := 0 to High(FOkResponses) do begin
            if FOkResponses[I] = 0 then begin
                { No good response found }
                FRequestResult := FStatusCode;
                SetErrorMessage;
                break;
            end;
            if FOkResponses[I] = FStatusCode then begin
                { Good response found }
                FRequestResult := 0;
                Break;
            end;
        end;
    end;

    if FPassive and (FStatusCode = 227) then begin
        StateChange(ftpPasvReady);               { 19.09.2002 }
        FPasvResponse := FLastResponse;
    end;

    if (FFctPrv in [ftpFctModeZ]) and (FStatusCode = 200) then
        FCurrTransMode := FTransferMode; { V2.102 }

    ExtractMoreResults;

{$IFDEF USE_SSL}
    if (FFctPrv in [ftpFctAuth]) and
       ((FStatusCode = 234) or (FStatusCode = 334)) then begin
        { Renegotiate the session if already in secure mode }  { V2.106 }
        if Assigned(FControlSocket.SSL) and
           (f_SSL_state(FControlSocket.Ssl) = SSL_ST_OK) then begin
            if (f_SSL_version(FControlSocket.Ssl) >= SSL3_VERSION) then begin
                if not FControlSocket.SslStartRenegotiation then
                    raise FtpException.Create('! SslStartRenegotiation failed');
                TSslFtpClient(Self).FRenegInitFlag := TRUE;
                TriggerDisplay('! Re-negotiate SSL');
                Exit;
            end
            else begin
                { Do nothing in SSLv2 }
                if Assigned(FDoneAsync) then
                    FDoneAsync
                else
                    TriggerRequestDone(FRequestResult);
                Exit;
            end;
        end;

        FControlSocket.SslEnable := TRUE;
        try
            FControlSocket.SslMode             := sslModeClient;
            FControlSocket.OnSslHandshakeDone  := TSslFtpClient(Self).TransferSslHandshakeDone;
            FControlSocket.OnSslVerifyPeer     := TSslFtpClient(Self).TransferSslVerifyPeer;
            FControlSocket.OnSslCliGetSession  := TSslFtpClient(Self).TransferSslCliGetSession;
            FControlSocket.OnSslCliNewSession  := TSslFtpClient(Self).TransferSslCliNewSession;
            FControlSocket.OnSslCliCertRequest := TSslFtpClient(Self).TransferSslCliCertRequest;

            FControlSocket.StartSslHandshake;
        except
            on E:Exception do begin
                TriggerDisplay('! Init SSL failed ' + E.Message);
                FStatusCode    := 550;
                FNextRequest   := nil;
                FRequestResult := FStatusCode;
                FLastResponse  := IntToStr(FStatusCode) + ' ' + E.Message;
                SetErrorMessage;
                if Assigned(FDoneAsync) then
                    FDoneAsync
                else
                    TriggerRequestDone(FRequestResult);
                Exit;
            end;
        end;
        //TriggerDisplay('! Starting SSL handshake');
    end
    else if (FFctPrv in [ftpFctCcc]) and (FStatusCode = 200) then begin  { V2.106 }
        TriggerDisplay('! SSL shutdown control channel started');
        FControlSocket.OnSslShutDownComplete :=
                           TSslFtpClient(Self).ControlSocketSslShutDownComplete;
        FControlSocket.SslBiShutDownAsync;
    end
    else
{$ENDIF}
    if Assigned(FDoneAsync) then
        FDoneAsync
    else
        TriggerRequestDone(FRequestResult);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.QuitAsync;
begin
    DestroyLocalStream;
    FFctPrv := ftpFctQuit;
    ExecAsync(ftpQuitAsync, 'QUIT', [221], DoneQuitAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.DoneQuitAsync;
begin
    FControlSocket.Close;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.CwdAsync;
begin
    if Length(FHostDirName) <= 0 then begin
        HandleError('HostDirName empty');
        Exit;
    end;

    FFctPrv := ftpFctCwd;
    ExecAsync(ftpCwdAsync, 'CWD '+ FHostDirName, [200, 250, 257], nil);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.UserAsync;
var
    CmdBuf : String;
begin
    if Length(FUserName) <= 0 then begin
        HandleError('UserName empty');
        Exit;
    end;
    FFctPrv := ftpFctUser;
    if FConnectionType = ftpProxy then begin
        if (CompareText(FPort, 'ftp') = 0) or
           (CompareText(FPort, '21') = 0) then
            CmdBuf := 'USER ' + FUserName + '@' + FHostName
        else
            CmdBuf := 'USER ' + FUserName + '@' + FHostName + ':' + FPort;
    end
    else
        CmdBuf := 'USER ' + FUserName;
    ExecAsync(ftpUserAsync, CmdBuf, [331, 230], nil);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.PassAsync;
begin
    if Length(FPassword) <= 0 then begin
        HandleError('Password empty');
        Exit;
    end;
    FFctPrv := ftpFctPass;
    ExecAsync(ftpPassAsync, 'PASS '+ FPassword, [230, 332], nil);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.AcctAsync;
begin
    if Length(FAccount) <= 0 then begin
        HandleError('Account empty!');
        Exit;
    end;
    FFctPrv := ftpFctAcct;
    ExecAsync(ftpAccountAsync, 'ACCT '+ FAccount, [230, 202], nil);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.SystAsync;
begin
    FFctPrv := ftpFctSyst;
    ExecAsync(ftpSystAsync, 'SYST', [215], nil);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.AuthAsync;                                    { V2.106 }
begin
    raise FtpException.Create('AUTH SSL/TLS requires ICS-SSL version');
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.ProtAsync;
begin
    raise FtpException.Create('PROT require ICS-SSL version');
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.PbszAsync;
begin
    raise FtpException.Create('PBSZ require ICS-SSL version');
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.CccAsync;                                     { V2.106 }
begin
    raise FtpException.Create('CCC require ICS-SSL version');
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.RestAsync;
begin
    FFctPrv   := ftpFctRest;
    { When restarting a download, we always start from current local file   }
    { size. When restarting a upload, we restart from ResumeAt property     }
    { value. This property could be initialized using Size command.         }
    if (not (FRequestType in [ftpRestartPutAsync, ftpRestPutAsync])) and
       (not (ftpNoAutoResumeAt in FOptions)) then
{$IFDEF STREAM64}                      { V2.101 }
        FResumeAt := GetFileSize64(FLocalFileName);
{$ELSE}
        FResumeAt := GetFileSize(FLocalFileName);
{$ENDIF}
{$IFDEF STREAM64}                      { V2.101 }
    { V2.101 TStream does not have 64-bit seek, only TFileStream }
    if FStreamFlag and (FResumeAt >= High(LongInt))then begin
        HandleError('Unable to restart TStream xfer from this position');
        exit;
    end;
{$ENDIF}
    if FResumeAt > 0 then
        ExecAsync(ftpRestAsync, 'REST ' + IntToStr(FResumeAt), [0], nil)
    else begin
        FRequestDoneFlag  := FALSE;
        FNext             := NextExecAsync;
        FDoneAsync        := nil;
        TriggerRequestDone(0);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.SizeAsync;
begin
    FSizeResult := 0;
    FFctPrv := ftpFctSize;
    ExecAsync(ftpSizeAsync, 'SIZE ' + FHostFileName, [213], nil);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.TypeSetAsync;
begin
    FFctPrv := ftpFctTypeSet;
    ExecAsync(ftpTypeSetAsync, 'TYPE ' + FType, [200], nil);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.TypeBinaryAsync;
begin
    Binary := TRUE;
    TypeSetAsync;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.TypeAsciiAsync;
begin
    Binary := FALSE;
    TypeSetAsync;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.MkdAsync;
begin
    FFctPrv := ftpFctMkd;
    ExecAsync(ftpMkdAsync, 'MKD ' + FHostFileName, [200, 250, 257], nil);  { V2.100 }
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.RmdAsync;
begin
    FFctPrv := ftpFctRmd;
    ExecAsync(ftpRmdAsync, 'RMD ' + FHostFileName, [200, 250, 257], nil);  { V2.100 }
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.DeleAsync;
begin
    FFctPrv := ftpFctDele;
    ExecAsync(ftpDeleAsync, 'DELE ' + FHostFileName, [200, 250, 257], nil); { V2.100 }
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.AbortXferAsync;
begin
    FFctPrv := ftpFctAbortXfer;
    ExecAsync(ftpAbortXferAsync, 'ABOR', [0], nil);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.QuoteAsync;
begin
    FFctPrv := ftpFctQuote;
    ExecAsync(ftpQuoteAsync, FLocalFileName, [0], nil);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.PwdAsync;
begin
    FFctPrv := ftpFctPwd;
    ExecAsync(ftpPwdAsync, 'PWD', [250, 257], nil);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.CDupAsync;
begin
    FFctPrv := ftpFctCDup;
    ExecAsync(ftpCDupAsync, 'CDUP', [250, 257], nil);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.RenFromAsync;
begin
    FFctPrv := ftpFctRenFrom;
    ExecAsync(ftpRenFromAsync, 'RNFR ' + FHostFileName, [350], nil);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.RenToAsync;
begin
    FFctPrv := ftpFctRenTo;
    ExecAsync(ftpRenToAsync, 'RNTO ' + FLocalFileName, [200, 250, 257], nil);
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.MlstAsync;     { V2.90 machine list one file        }
begin
    FFctPrv   := ftpFctMlst;
    FRemFacts := '';
    ExecAsync(ftpMlstAsync, 'MLST ' + FHostFileName, [250], nil); { V2.100 }
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.FeatAsync;     { V2.90 supported extensions         }
begin
    FFctPrv := ftpFctFeat;
    ExecAsync(ftpFeatAsync, 'FEAT', [211], nil); { V2.100 }
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.MdtmAsync;     { V2.90 get file modification time   }
begin
    FFctPrv := ftpFctMdtm;
    ExecAsync(ftpMdtmAsync, 'MDTM ' + FHostFileName, [213], nil); { V2.100 }
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.MdtmyyAsync;   { V2.90 set file modification time - RhinoSoft Serv-U }
var
    S: String;
begin
    if FRemFileDT < 10 then begin
        HandleError('Modification date empty');
        Exit;
    end;
    FFctPrv := ftpFctMdtmyy;
    S       := FormatDateTime('yyyymmddhhnnss', FRemFileDT) + '+0';  { no time offset=UTC }
    ExecAsync(ftpMdtmyyAsync, 'MDTM ' + S + ' ' + FHostFileName, [213, 253], nil);  { V2.100 }
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.MfmtAsync;   { V2.94 modify file modification time }
var
    S: String;
begin
    if FRemFileDT < 10 then begin
        HandleError('Modification date empty');
        Exit;
    end;
    FFctPrv := ftpFctMfmt;
    S       := FormatDateTime('yyyymmddhhnnss', FRemFileDT);  { UTC }
    ExecAsync(ftpMfmtAsync, 'MFMT ' + S + ' ' + FHostFileName, [213], nil);  { V2.100 }
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.Md5Async;     { V2.94 get MD5 hash sum   }
begin
    FFctPrv := ftpFctMd5;
    ExecAsync(ftpMd5Async, 'MD5 ' + FHostFileName, [251], nil);
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.ModeZAsync;    { V2.102  Mode Z  }
var
    S: string;
begin
    FFctPrv := ftpFctModeZ;
    if FTransferMode = ftpTransModeZDeflate then
        S := 'MODE Z'
    else
        S := 'MODE S';
    ExecAsync(ftpModeZAsync, S, [200], nil);
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.OptsAsync;     { V2.102  Opts, set Mode Z options }
begin
    FFctPrv := ftpFctOpts;
    ExecAsync(ftpOptsAsync, 'OPTS ' + FNewOpts, [200], nil);
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.AbortAsync;
{var
    bFlag : Boolean; }                                             { 2.106 }
begin
{$IFNDEF NO_DEBUG_LOG}                                             { 2.105 }
    if CheckLogOptions(loProtSpecInfo) then
        DebugLog(loProtSpecInfo, '! Aborting');
{$ENDIF}
    {bFlag := (FState = ftpDnsLookup);}                            { 2.106 }
    StateChange(ftpAbort);
{$IFDEF USE_SSL}
    if Assigned(FControlSocket.OnSslShutDownComplete) then
        TSslFtpClient(Self).ControlSocketSslShutDownComplete(FControlSocket,
        TRUE, 426);
{$ENDIF}                  
    DestroyLocalStream;
    {if bFlag then                                                 // 2.106
        FControlSocket.CancelDnsLookup;
    if FControlSocket.State <> wsClosed then
        FControlSocket.Close;
    if FDataSocket.State <> wsClosed then
        FDataSocket.Close; }
    FControlSocket.Abort;
    FDataSocket.Abort;
    {DestroyLocalStream;}
    FConnected := FALSE;                                          { 2.106 }
    StateChange(ftpReady);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.DoHighLevelAsync;
begin
{$IFNDEF NO_DEBUG_LOG}                                             { 2.105 }
    if CheckLogOptions(loProtSpecDump) then
        DebugLog(loProtSpecDump, '! HighLevelAsync ' + IntToStr(FRequestResult));
{$ENDIF}
    if FState = ftpAbort then begin
{$IFNDEF NO_DEBUG_LOG}                                             { 2.105 }
        if CheckLogOptions(loProtSpecInfo) then
            DebugLog(loProtSpecInfo, '! Abort detected');
{$ENDIF}
        FFctSet := [];
        FHighLevelResult := 426;
        FErrorMessage    := '426 Operation aborted.';
    end;

    FNextRequest := DoHighLevelAsync;

    if FRequestResult <> 0 then begin
        { Previous command had errors }
        FHighLevelResult := FRequestResult;
        if (FFctPrv = ftpFctQuit) or (not (ftpFctQuit in FFctSet)) then
            FFctSet := []
        else
            FFctSet := [ftpFctQuit];
    end;

    ExtractMoreResults;

    if ftpFctOpen in FFctSet then begin
        FFctPrv := ftpFctOpen;
        FFctSet := FFctSet - [FFctPrv];
        OpenAsync;
        Exit;
    end;

    if (ftpFctAuth in FFctSet) and                    { V2.106 }
       ((FSslType = sslTypeAuthSsl) or (FSslType = sslTypeAuthTls)) then begin
        FFctPrv := ftpFctAuth;
        FFctSet := FFctSet - [ftpFctAuth];
        AuthAsync;
        Exit;
    end;

    if ftpFctPbsz in FFctSet then begin
        FFctPrv := ftpFctPbsz;
        FFctSet := FFctSet - [ftpFctPbsz];
        PbszAsync;
        Exit;
    end;

    if ftpFctProt in FFctSet then begin
        FFctPrv := ftpFctProt;
        FFctSet := FFctSet - [ftpFctProt];
        ProtAsync;
        Exit;
    end;

    if ftpFctCcc in FFctSet then begin                  { V2.106 }                
        FFctPrv := ftpFctCcc;
        FFctSet := FFctSet - [ftpFctCcc];
        CccAsync;
        Exit;
    end;

    if ftpFctUser in FFctSet then begin
        FFctPrv := ftpFctUser;
        FFctSet := FFctSet - [FFctPrv];
        UserAsync;
        Exit;
    end;

    if ftpFctPass in FFctSet then begin
        FFctSet := FFctSet - [ftpFctPass];
        if (FFctPrv <> ftpFctUser) or
           ((FfctPrv = ftpFctUser) and (FStatusCode = 331)) then begin
            FFctPrv := ftpFctPass;
            PassAsync;
            Exit;
        end;
    end;

    if ftpFctAcct in FFctSet then begin
        FFctSet := FFctSet - [ftpFctAcct];
        if (FFctPrv <> ftpFctPass) or
           ((FfctPrv = ftpFctPass) and (FStatusCode = 332)) then begin
            FFctPrv := ftpFctAcct;
            AcctAsync;
            Exit;
        end;
    end;

    if ftpFctCwd in FFctSet then begin
        FFctSet := FFctSet - [ftpFctCwd];
        if Length(FHostDirName) > 0 then begin
            FFctPrv := ftpFctCwd;
            CwdAsync;
            Exit;
        end;
    end;

    if ftpFctCDup in FFctSet then begin
        FFctPrv := ftpFctCDup;
        FFctSet := FFctSet - [FFctPrv];
        CDupAsync;
        Exit;
    end;

    if ftpFctTypeSet in FFctSet then begin
        FFctPrv := ftpFctTypeSet;
        FFctSet := FFctSet - [FFctPrv];
        TypeSetAsync;
        Exit;
    end;

    if ftpFctPort in FFctSet then begin
        FFctPrv := ftpFctPort;
        FFctSet := FFctSet - [FFctPrv];
        PortAsync;
        Exit;
    end;

    if ftpFctRest in FFctSet then begin
        FFctPrv := ftpFctRest;
        FFctSet := FFctSet - [FFctPrv];
        RestAsync;
        Exit;
    end;

    if ftpFctGet in FFctSet then begin
        if (FFctPrv <> ftpFctRest) or
           (FResumeAt < 0) or
           ((FFctPrv = ftpFctRest) and (FStatusCode <> 350)) then
            FResumeAt := 0;

        FFctPrv   := ftpFctGet;
        FFctSet   := FFctSet - [FFctPrv];
        ExecGetAsync;
        Exit;
    end;

    if ftpFctPut in FFctSet then begin
        FFctPrv := ftpFctPut;
        FFctSet := FFctSet - [FFctPrv];
        ExecPutAsync;
        Exit;
    end;

    if ftpFctAppend in FFctSet then begin
        FFctPrv := ftpFctAppend;
        FFctSet := FFctSet - [FFctPrv];
        ExecAppendAsync;
        Exit;
    end;

    if ftpFctDir in FFctSet then begin
        FFctPrv := ftpFctDir;
        FFctSet := FFctSet - [FFctPrv];
        ExecDirAsync;
        Exit;
    end;

    if ftpFctLs in FFctSet then begin
        FFctPrv := ftpFctLs;
        FFctSet := FFctSet - [FFctPrv];
        ExecLsAsync;
        Exit;
    end;

    if ftpFctSyst in FFctSet then begin
        FFctPrv := ftpFctSyst;
        FFctSet := FFctSet - [FFctPrv];
        SystAsync;
        Exit;
    end;

    if ftpFctMkd in FFctSet then begin
        FFctPrv := ftpFctMkd;
        FFctSet := FFctSet - [FFctPrv];
        MkdAsync;
        Exit;
    end;

    if ftpFctRmd in FFctSet then begin
        FFctPrv := ftpFctRmd;
        FFctSet := FFctSet - [FFctPrv];
        RmdAsync;
        Exit;
    end;

    if ftpFctRenFrom in FFctSet then begin
        FFctPrv := ftpFctRenFrom;
        FFctSet := FFctSet - [FFctPrv];
        RenFromAsync;
        Exit;
    end;

    if ftpFctRenTo in FFctSet then begin
        FFctPrv := ftpFctRenTo;
        FFctSet := FFctSet - [FFctPrv];
        RenToAsync;
        Exit;
    end;

    if ftpFctSize in FFctSet then begin
        FFctPrv := ftpFctSize;
        FFctSet := FFctSet - [FFctPrv];
        SizeAsync;
        Exit;
    end;

    if ftpFctDele in FFctSet then begin
        FFctPrv := ftpFctDele;
        FFctSet := FFctSet - [FFctPrv];
        DeleAsync;
        Exit;
    end;

    if ftpFctPwd in FFctSet then begin
        FFctPrv := ftpFctPwd;
        FFctSet := FFctSet - [FFctPrv];
        PwdAsync;
        Exit;
    end;

    if ftpFctAbortXfer in FFctSet then begin
        FFctPrv := ftpFctAbortXfer;
        FFctSet := FFctSet - [FFctPrv];
        AbortXferAsync;
        Exit;
    end;

    if ftpFctQuote in FFctSet then begin
        FFctPrv := ftpFctQuote;
        FFctSet := FFctSet - [FFctPrv];
        QuoteAsync;
        Exit;
    end;

    if ftpFctQuit in FFctSet then begin
        FFctPrv := ftpFctQuit;
        FFctSet := FFctSet - [FFctPrv];
        FLastResponseSave := FLastResponse;
        FStatusCodeSave   := FStatusCode;
        QuitAsync;
        Exit;
    end;

    if ftpFctMlsd in FFctSet then begin     { V2.90 }
        FFctPrv := ftpFctMlsd;
        FFctSet := FFctSet - [FFctPrv];
        ExecMlsdAsync;
        Exit;
    end;

    if ftpFctModeZ in FFctSet then begin     { V2.102 }
        FFctPrv := ftpFctModeZ;
        FFctSet := FFctSet - [FFctPrv];
        ModeZAsync;
        Exit;
    end;

    if ftpFctOpts in FFctSet then begin     { V2.102 }
        FFctPrv := ftpFctOpts;
        FFctSet := FFctSet - [FFctPrv];
        OptsAsync;
        Exit;
    end;

{$IFNDEF NO_DEBUG_LOG}                                             { 2.105 }
    if CheckLogOptions(loProtSpecDump) then
        DebugLog(loProtSpecDump, '! HighLevelAsync done');
{$ENDIF}
    FFctSet          := [];
    FNextRequest     := nil;
    FRequestDoneFlag := FALSE;
    TriggerRequestDone(FHighLevelResult);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.HighLevelAsync(RqType : TFtpRequest; Fcts : TFtpFctSet);
begin
    if FConnected and (ftpFctOpen in Fcts) then begin
        HandleError('FTP component already connected');
        Exit;
    end;
    if not CheckReady then
        Exit;
    FLastResponseSave := FLastResponse;
    FStatusCodeSave   := -1;
    FRequestType      := RqType;
    FRequestResult    := 0;
    FFctSet           := Fcts;
    FFctPrv           := ftpFctNone;
    FHighLevelResult  := 0;
    FHighLevelFlag    := TRUE;
    FLastResponse     := '';
    FErrorMessage     := '';
    FRestartFlag      := FALSE;
    FNextRequest      := nil;
    DoHighLevelAsync;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.ConnectAsync;
begin
    HighLevelAsync(ftpConnectAsync,
                   [ftpFctOpen, ftpFctAuth, ftpFctUser, ftpFctPass,
                    ftpFctAcct]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.ReceiveAsync;
begin
    HighLevelAsync(ftpReceiveAsync,
                   [ftpFctOpen, ftpFctAuth, ftpFctUser, ftpFctPass,
                    ftpFctAcct, ftpFctCwd,  ftpFctTypeSet, ftpFctPort,
                    ftpFctGet,  ftpFctQuit]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.PutAsync;
begin
	DataSocket.LastError := 0; { V2.100 }
    HighLevelAsync(ftpPutAsync,
                   [ftpFctPort, ftpFctPut]);
    if DataSocket.LastError <> 0 then    { V2.100 }
       raise FtpException.Create('Socket Error ' +
                                 IntToStr(DataSocket.LastError)); { V2.100 }
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ By A.Burlakov: new procedure for resuming uploads                         }
{ Uses REST + STOR commands instead APPEND                                  }
procedure TCustomFtpCli.RestPutAsync;
begin
    HighLevelAsync(ftpRestPutAsync,
                   [ftpFctRest, ftpFctPort, ftpFctPut]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.RestartPutAsync;
begin
    HighLevelAsync(ftpRestartPutAsync,
                   [ftpFctOpen,    ftpFctAuth,    ftpFctUser,    ftpFctPass,
                    ftpFctAcct,    ftpFctCwd,     ftpFctTypeSet, ftpFctRest,
                    ftpFctPort,    ftpFctPut,     ftpFctQuit]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.TransmitAsync;
begin
    HighLevelAsync(ftpTransmitAsync,
                   [ftpFctOpen, ftpFctAuth,    ftpFctUser,    ftpFctPass,
                    ftpFctAcct, ftpFctCwd,     ftpFctTypeSet, ftpFctPort,
                    ftpFctPut,  ftpFctQuit]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.AppendAsync;
begin
    HighLevelAsync(ftpAppendAsync,
                   [ftpFctPort, ftpFctAppend]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.AppendFileAsync;
begin
    HighLevelAsync(ftpTransmitAsync,
                   [ftpFctOpen,   ftpFctAuth,    ftpFctUser,    ftpFctPass,
                    ftpFctAcct,   ftpFctCwd,     ftpFctTypeSet, ftpFctPort,
                    ftpFctAppend, ftpFctQuit]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.DirAsync;
begin
    HighLevelAsync(ftpDirAsync,
                   [ftpFctPort, ftpFctDir]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.DirectoryAsync;
begin
    HighLevelAsync(ftpDirectoryAsync,
                   [ftpFctOpen, ftpFctAuth,    ftpFctUser, ftpFctPass,
                    ftpFctAcct, ftpFctCwd,     ftpFctPort, ftpFctDir,
                    ftpFctQuit]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.LsAsync;
begin
    HighLevelAsync(ftpLsAsync,
                   [ftpFctPort, ftpFctLs]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.ListAsync;
begin
    HighLevelAsync(ftpListAsync,
                   [ftpFctOpen, ftpFctAuth,    ftpFctUser, ftpFctPass,
                    ftpFctAcct, ftpFctCwd,     ftpFctPort, ftpFctLs,
                    ftpFctQuit]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.SystemAsync;
begin
    HighLevelAsync(ftpSystemAsync,
                   [ftpFctOpen, ftpFctAuth,    ftpFctUser, ftpFctPass,
                    ftpFctAcct, ftpFctSyst,    ftpFctQuit]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.AuthenticateSslAsync;
begin
    HighLevelAsync(ftpAuthAsync,
                   [ftpFctOpen, ftpFctAuth, ftpFctQuit]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.RestartGetAsync;
begin
    HighLevelAsync(ftpRestartGetAsync,
                   [ftpFctOpen,    ftpFctAuth,    ftpFctUser,    ftpFctPass,
                    ftpFctAcct,    ftpFctCwd,     ftpFctTypeSet, ftpFctRest,
                    ftpFctPort,    ftpFctGet,     ftpFctQuit]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.RestGetAsync;
begin
    HighLevelAsync(ftpRestGetAsync,
                   [ftpFctRest, ftpFctPort, ftpFctGet]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.GetAsync;
begin
    HighLevelAsync(ftpGetAsync,
                   [ftpFctPort, ftpFctGet]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.MkdirAsync;
begin
    HighLevelAsync(ftpMkdirAsync,
                   [ftpFctOpen, ftpFctAuth,    ftpFctUser,    ftpFctPass,
                    ftpFctAcct, ftpFctCwd,     ftpFctMkd,     ftpFctQuit]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.RmdirAsync;
begin
    HighLevelAsync(ftpRmdirAsync,
                   [ftpFctOpen, ftpFctAuth,    ftpFctUser,    ftpFctPass,
                    ftpFctAcct, ftpFctCwd,     ftpFctRmd,     ftpFctQuit]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.DeleteAsync;
begin
    HighLevelAsync(ftpDeleteAsync,
                   [ftpFctOpen, ftpFctAuth,    ftpFctUser, ftpFctPass,
                    ftpFctAcct, ftpFctCwd,     ftpFctDele,    ftpFctQuit]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.DoQuoteAsync;
begin
    HighLevelAsync(ftpDoQuoteAsync,
                   [ftpFctOpen,  ftpFctAuth,    ftpFctUser,    ftpFctPass,
                    ftpFctAcct,  ftpFctCwd,     ftpFctQuote,   ftpFctQuit]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.RenameAsync;
begin
    HighLevelAsync(ftpRenameAsync,
                   [ftpFctOpen,    ftpFctAuth,    ftpFctUser,    ftpFctPass,
                    ftpFctAcct,    ftpFctCwd,     ftpFctRenFrom, ftpFctRenTo,
                    ftpFctQuit]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.RenAsync;
begin
    HighLevelAsync(ftpRenAsync, [ftpFctRenFrom, ftpFctRenTo]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.FileSizeAsync;
begin
    HighLevelAsync(ftpSizeAsync,
                   [ftpFctOpen, ftpFctAuth,    ftpFctUser,    ftpFctPass,
                    ftpFctAcct, ftpFctCwd,     ftpFctSize,    ftpFctQuit]);
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.MlsdAsync;    { V2.90 machine list directory        }
begin
    HighLevelAsync(ftpMlsdAsync,
                   [ftpFctPort, ftpFctMlsd]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.DataSocketGetDataAvailable(
    Sender  : TObject;
    ErrCode : Word);
const
    OutBufSize = 32768 ;
var
    Len     : Integer;
    Buffer  : array [1..4096] of Char;  { Should use a dynamic buffer instead... }
    aSocket : TWSocket;
    I, J    : Integer;
    Line    : String;
begin
    if not Progress then
        Exit;

    aSocket := Sender as TWSocket;

    Len := aSocket.Receive(@Buffer[1], High(Buffer));
{TriggerDisplay('! Data received ' + IntToStr(Len));}
    if Len = 0 then
        { Remote has closed, ignore }
    else if Len < 0 then begin
        { An error has occured }
        if (aSocket.State = wsConnected) and
           (aSocket.LastError <> WSAEWOULDBLOCK) then begin
            TriggerDisplay('! Data: Receive error ' + IntToStr(aSocket.LastError));
            aSocket.Shutdown(2);
            Exit;
        end;
    end
    else begin
{$IFDEF UseBandwidthControl}
    Inc(FBandwidthCount, Len);
    if ftpBandwidthControl in FOptions then begin
        if (FBandwidthCount > FBandwidthMaxCount) and
           (not FBandwidthPaused) then begin
            FBandwidthPaused := TRUE;
            aSocket.Pause;
        end;
    end;
{$ENDIF}
{$IFDEF USE_MODEZ}
        if FZStreamState = ftpZStateSaveDecom then begin   { V1.103 }
            FModeZStream.WriteBuffer(Buffer, Len);
            FByteCount := FByteCount + Len;  { compressed size }
            exit;
        end ;
{$ENDIF}
        if FLocalStream <> nil then begin
            try
                FLocalStream.WriteBuffer(Buffer, Len);
            except
                TriggerDisplay('! Error writing local file');
                aSocket.Shutdown(2);
                Exit;
            end;
        end;

        { Update our statistics }
        FByteCount := FByteCount + Len;

        { If requested to display the received data, do it line by line }
        if FDisplayFileFlag then begin
            case FDisplayFileMode of
            ftpBinary:
                begin
                    {$IFDEF VER80}
                    { 16 bit has max 255 characters per String }
                    if Len > 255 then
                        SetLength(Line, 255)
                    else
                    {$ENDIF}
                    SetLength(Line, Len);
                    Move(Buffer[1], Line[1], Length(Line));
                    TriggerDisplayFile(Line);
                end;
            ftpLineByLine:
                if Len > 0 then begin
                    i := 1;
                    while (i <= Len) do begin
                        j := 1;
                        while (i <= Len) and (Buffer[i] <> #10) and (Buffer[i] <> #13) do begin
                            i := i + 1;
                            j := j + 1;
                        end;
                        {$IFDEF VER80}
                        if (j - 1) > 255 then
                            SetLength(Line, 255)
                        else
                        {$ENDIF}
                        SetLength(Line, j - 1);
                        if Length(Line) > 0 then
                            Move(Buffer[i - j + 1], Line[1], Length(Line));
                        TriggerDisplayFile(Line);
                        while (i <= Len) and ((Buffer[i] = #10) or (Buffer[i] = #13)) do
                            i := i + 1;
                    end;
                end;
            end;
        end;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.DataSocketGetSessionConnected(
    Sender  : TObject;
    ErrCode : word);
begin
{$IFNDEF NO_DEBUG_LOG}                                             { 2.104 }
    if CheckLogOptions(loProtSpecInfo) then
        DebugLog(loProtSpecInfo, '! Data Session Connected (Get)');
{$ENDIF}
    { Use the socket for the data transmission }
    FDataSocket.OnSessionClosed := DataSocketGetSessionClosed;
    FDataSocket.OnDataAvailable := DataSocketGetDataAvailable;
    FDataSocket.OnDataSent      := nil;

    { Record the starting time }
    FStartTime := LongInt(GetTickCount);

    if ErrCode <> 0 then begin
        FLastResponse := 'Unable to establish data connection, error #' +
                         IntToStr(ErrCode);
        FStatusCode   := 550;
        SetErrorMessage;
        FDataSocket.Close;
        FRequestResult := FStatusCode;
        TriggerRequestDone(FRequestResult);
    end
    else begin
{$IFDEF UseBandwidthControl}
        FBandwidthCount := 0; // Reset byte counter
        if ftpBandwidthControl in FOptions then begin
            if not Assigned(FBandwidthTimer) then
                FBandwidthTimer := TTimer.Create(nil);
            FBandwidthTimer.Enabled  := FALSE;
            FBandwidthTimer.Interval := FBandwidthSampling;
            FBandwidthTimer.OnTimer  := BandwidthTimerTimer;
            FBandwidthTimer.Enabled  := TRUE;
            // Number of bytes we allow during a sampling period
            FBandwidthMaxCount := Int64(FBandwidthLimit) * FBandwidthSampling div 1000;
            FBandwidthPaused   := FALSE;
        end;
{$ENDIF}
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Used for passive mode                                                     }
procedure TCustomFtpCli.DataSocketPutSessionConnected(
    Sender  : TObject;
    ErrCode : word);
begin
{$IFNDEF NO_DEBUG_LOG}                                             { 2.105 }
    if CheckLogOptions(loProtSpecInfo) then
        DebugLog(loProtSpecInfo, '! Data Session opened (Put)');
{$ENDIF}
    { Use the socket for the data transmission }
    FDataSocket.OnSessionClosed := DataSocketPutSessionClosed;
    FDataSocket.OnDataAvailable := nil;
    FDataSocket.OnDataSent      := nil;

    { Record we opened data session }
    FPutSessionOpened := TRUE;

    { Record the starting time }
    FStartTime := LongInt(GetTickCount);

    if ErrCode <> 0 then begin
        FLastResponse := 'Unable to establish data connection, error #' +
                         IntToStr(ErrCode);
        FStatusCode   := 550;
        SetErrorMessage;
        FDataSocket.Close;
        FRequestResult := FStatusCode;
        TriggerRequestDone(FRequestResult);
        Exit;
    end;
{$IFDEF UseBandwidthControl}
    FBandwidthCount := 0; // Reset byte counter
    if ftpBandwidthControl in FOptions then begin
        if not Assigned(FBandwidthTimer) then
            FBandwidthTimer := TTimer.Create(nil);
        FBandwidthTimer.Enabled  := FALSE;
        FBandwidthTimer.Interval := FBandwidthSampling;
        FBandwidthTimer.OnTimer  := BandwidthTimerTimer;
        FBandwidthTimer.Enabled  := TRUE;
        // Number of bytes we allow during a sampling period
        FBandwidthMaxCount := Int64(FBandwidthLimit) * FBandwidthSampling div 1000;
        FBandwidthPaused   := FALSE;
    end;
{$ENDIF}
    StateChange(ftpWaitingResponse);
    FNext := Next1PutAsync;

    if FAppendFlag then
        SendCommand('APPE ' + FHostFileName)
    else
        SendCommand('STOR ' + FHostFileName);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.DataSocketGetSessionAvailable(
    Sender  : TObject;
    ErrCode : word);
var
    aSocket : TSocket;
begin
{$IFNDEF NO_DEBUG_LOG}                                             { 2.105 }
    if CheckLogOptions(loProtSpecInfo) then
        DebugLog(loProtSpecInfo, '! Data Session requested');
{$ENDIF}
    { Accept the incomming connection initiated by the FTP server for data }
    aSocket := FDataSocket.Accept;

    { Close the listening socket, we don't need it anymore }
    FDataSocket.Close;
{$IFDEF USE_SSL}
    TCustomSslWSocket(FDataSocket).SslEnable := TSslFtpClient(Self).FProtLevelSent = 'P';
    if TCustomSslWSocket(FDataSocket).SslEnable then begin
        TCustomSslWSocket(FDataSocket).SslContext          := FControlSocket.SslContext;
        TCustomSslWSocket(FDataSocket).SslMode             := sslModeClient;
        TCustomSslWSocket(FDataSocket).OnSslVerifyPeer     := FControlSocket.OnSslVerifyPeer;
        TCustomSslWSocket(FDataSocket).OnSslHandshakeDone  := FControlSocket.OnSslHandshakeDone;
        TCustomSslWSocket(FDataSocket).OnSslCliGetSession  := FControlSocket.OnSslCliGetSession;
        TCustomSslWSocket(FDataSocket).OnSslCliNewSession  := FControlSocket.OnSslCliNewSession;
        TCustomSslWSocket(FDataSocket).OnSslCliCertRequest := FControlSocket.OnSslCliCertRequest;
    end;
{$ENDIF}
    { Reuse the socket for the data transmission }
    FDataSocket.OnSessionClosed  := DataSocketGetSessionClosed;
    FDataSocket.OnDataAvailable  := DataSocketGetDataAvailable;
    FDataSocket.OnDataSent       := nil;
    FDataSocket.HSocket          := aSocket;
    FDataSocket.ComponentOptions := [wsoNoReceiveLoop];   { 26/10/02 }
{$IFDEF UseBandwidthControl}
    FBandwidthCount := 0; // Reset byte counter
    if ftpBandwidthControl in FOptions then begin
        if not Assigned(FBandwidthTimer) then
            FBandwidthTimer := TTimer.Create(nil);
        FBandwidthTimer.Enabled  := FALSE;
        FBandwidthTimer.Interval := FBandwidthSampling;
        FBandwidthTimer.OnTimer  := BandwidthTimerTimer;
        FBandwidthTimer.Enabled  := TRUE;
        // Number of bytes we allow during a sampling period
        FBandwidthMaxCount := Int64(FBandwidthLimit) * FBandwidthSampling div 1000;
        FBandwidthPaused   := FALSE;
    end;
{$ENDIF}
    { Record the starting time }
    FStartTime := LongInt(GetTickCount);
{$IFNDEF NO_DEBUG_LOG}                                             { 2.105 }
    if CheckLogOptions(loProtSpecInfo) then
        DebugLog(loProtSpecInfo, '! Data Session opened');
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.DataSocketGetSessionClosed(
    Sender  : TObject;
    ErrCode : word);
begin
{$IFNDEF NO_DEBUG_LOG}                                             { 2.105 }
    if CheckLogOptions(loProtSpecInfo) then
        DebugLog(loProtSpecInfo, '! Data Session closed');
{$ENDIF}
{$IFDEF UseBandwidthControl}
    if Assigned(FBandwidthTimer) and FBandwidthTimer.Enabled then begin
        FBandwidthTimer.Enabled := FALSE;
        FBandwidthPaused := TRUE;
    end;
{$ENDIF}
    DestroyLocalStream;
    FFileReceived := TRUE;
    FError        := ErrCode;
    Next3GetAsync;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.DataSocketPutSessionAvailable(
    Sender  : TObject;
    ErrCode : word);
var
    aSocket : TSocket;
    SndBufSize : Integer;
    OptLen     : Integer;
begin
{$IFNDEF NO_DEBUG_LOG}                                             { 2.105 }
    if CheckLogOptions(loProtSpecInfo) then
        DebugLog(loProtSpecInfo, '! Data Session requested');
{$ENDIF}
    { Accept the incomming connection initiated by the FTP server for data }
    aSocket := FDataSocket.Accept;

    { Close the listening socket, we don't need it anymore }
    FDataSocket.Close;
{$IFDEF USE_SSL}                                                    // 12/15/05 Many properties missing!
    TCustomSslWSocket(FDataSocket).SslMode   := sslModeClient;
    TCustomSslWSocket(FDataSocket).SslEnable := (TSslFtpClient(Self).FProtLevelSent = 'P');
    if TCustomSslWSocket(FDataSocket).SslEnable then begin
        TCustomSslWSocket(FDataSocket).SslContext          := FControlSocket.SslContext;
        TCustomSslWSocket(FDataSocket).OnSslVerifyPeer     := FControlSocket.OnSslVerifyPeer;
        TCustomSslWSocket(FDataSocket).OnSslHandshakeDone  := FControlSocket.OnSslHandshakeDone;
        TCustomSslWSocket(FDataSocket).OnSslCliGetSession  := FControlSocket.OnSslCliGetSession;
        TCustomSslWSocket(FDataSocket).OnSslCliNewSession  := FControlSocket.OnSslCliNewSession;
        TCustomSslWSocket(FDataSocket).OnSslCliCertRequest := FControlSocket.OnSslCliCertRequest;
    end;
{$ENDIF}

    { Reuse the socket for the data transmission }
    FDataSocket.OnSessionClosed  := DataSocketPutSessionClosed;
    FDataSocket.OnDataAvailable  := DataSocketPutDataAvailable;
    FDataSocket.OnDataSent       := DataSocketPutDataSent;
{   FDataSocket.OnDisplay        := FOnDisplay; } { Debugging only }
    FDataSocket.HSocket          := aSocket;
    FDataSocket.ComponentOptions := [wsoNoReceiveLoop];   { 26/10/02 }

    OptLen := SizeOf(SndBufSize);
    if WSocket_getsockopt(FDataSocket.HSocket, SOL_SOCKET,
                          SO_SNDBUF,
                          @SndBufSize, OptLen) = SOCKET_ERROR then begin
        HandleError('winsock.getsockopt(SO_SNDBUF) failed');
        Exit;
    end;

    { Be sure to gracefully close the socket }
    FDataSocket.LingerOnOff   := wsLingerOff;
    FDataSocket.LingerTimeout := 10;
    FDataSocket.SetLingerOption;
{   FStorAnswerRcvd := TRUE; } { V240 INSERTED line }
{$IFDEF UseBandwidthControl}
    FBandwidthCount := 0; // Reset byte counter
    if ftpBandwidthControl in FOptions then begin
        if not Assigned(FBandwidthTimer) then
            FBandwidthTimer := TTimer.Create(nil);
        FBandwidthTimer.Enabled  := FALSE;
        FBandwidthTimer.Interval := FBandwidthSampling;
        FBandwidthTimer.OnTimer  := BandwidthTimerTimer;
        FBandwidthTimer.Enabled  := TRUE;
        // Number of bytes we allow during a sampling period
        FBandwidthMaxCount := Int64(FBandwidthLimit) * FBandwidthSampling div 1000;
        FBandwidthPaused   := FALSE;
    end;
{$ENDIF}
    FPutSessionOpened := TRUE;
    if FStorAnswerRcvd and (FStartTime = 0) then
        PostMessage(Handle, WM_FTP_SENDDATA, 0, 0);

{$IFNDEF NO_DEBUG_LOG}                                             { 2.105 }
    if CheckLogOptions(loProtSpecInfo) then
        DebugLog(loProtSpecInfo, '! Data Session opened');
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.WMFtpSendData(var msg: TMessage);
begin
    { Record the starting time }
    FStartTime := LongInt(GetTickCount);

    { Send first data block }
    DataSocketPutDataSent(FDataSocket, 0);
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure  TCustomFtpCli.WMFtpCloseDown(var msg: TMessage);      { V2.100 }
begin
    { see if last buffer has been fully sent, or given up waiting }
    if (FDataSocket.BufferedByteCount = 0) or 
       (FCloseEndTick < GetTickCount) then begin
        FDataSocket.ShutDown(1); { 18/05/2005 was CloseDelayed; }
        FEofFlag := TRUE;
    end
    else if ((FControlSocket.State = wsConnected) and
             (FDataSocket.State    = wsConnected)) then
        PostMessage(Handle, WM_FTP_CLOSEDOWN, 0, 0);  { not finished, call ourself again }
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.DataSocketPutDataSent(
    Sender  : TObject;
    ErrCode : Word);
var
    Count : Integer;
begin
    if (FLocalStream = nil) or (not Progress) then
        Exit;
    if FLocalStream = nil then
        Exit;   { Could be set to nil by Progress function }

    if ErrCode <> 0 then begin
        TriggerDisplay('! Error #' + IntToStr(ErrCode) + ' sending data');
        FDataSocket.Close;
        Exit;
    end;

    if FEofFlag or (not FStorAnswerRcvd) or (not FPutSessionOpened) then begin
        Exit;
    end;

    try
{$IFDEF USE_MODEZ}
        if FZStreamState = ftpZStateSaveComp then
            Count := FModeZStream.Read(FSendBuffer, BLOCK_SIZE)
         else
{$ENDIF}
            Count := FLocalStream.Read(FSendBuffer, BLOCK_SIZE);
{$IFNDEF NO_DEBUG_LOG}                                        { 2.104 }
        if CheckLogOptions(loProtSpecInfo) then
            DebugLog(loProtSpecInfo, 'DataSocketPutDataSent ' + IntToStr(Count));
{$ENDIF}
        if Count > 0 then begin
            FByteCount := FByteCount + Count;
            FDataSocket.Send(@FSendBuffer, Count);
{$IFDEF UseBandwidthControl}
            Inc(FBandwidthCount, Count);
            if ftpBandwidthControl in FOptions then begin
                if (FBandwidthCount > FBandwidthMaxCount) and
                   (not FBandwidthPaused) then begin
                    FBandwidthPaused := TRUE;
                    FDataSocket.Pause;
                end;
            end;
{$ENDIF}
        end
        else begin { EOF }
            {$IFNDEF VER80}
            { For an unknown reason, winsock need time to send last data }
            { buffer. Without this delay, we may end with a partial file }
            { transfer. See comments in DoPutAppendAsync function.       }
            { Normally using Linger option would handle this case. But   }
            { many winsock implementations will end with a 10055 error   }
            { after a lot of consecutive file transfers.                 }
            {  Sleep(100);  did not really work }

            { V2.100 new close down message which repeats until last buffer sent }
            FCloseEndTick := GetTickCount + (FCloseEndSecs * 1000);  { but not forever }
            PostMessage(Handle, WM_FTP_CLOSEDOWN, 0, 0);
            exit;
            {$ENDIF}
            FDataSocket.ShutDown(1); { 18/05/2005 was CloseDelayed; }
            FEofFlag := TRUE;
        end;
    except
        on E:Exception do begin
            TriggerDisplay('! Error reading file ' + E.ClassName + ': ' + E.Message);
            FDataSocket.Close;
        end;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.DataSocketPutSessionClosed(
    Sender  : TObject;
    ErrCode : word);
begin
{$IFNDEF NO_DEBUG_LOG}                                             { 2.105 }
    if CheckLogOptions(loProtSpecInfo) then
        DebugLog(loProtSpecInfo, '! Data Session closed');
{$ENDIF}
{$IFDEF UseBandwidthControl}
    if Assigned(FBandwidthTimer) and FBandwidthTimer.Enabled then begin
        FBandwidthTimer.Enabled := FALSE;
        FBandwidthPaused := TRUE;
    end;
{$ENDIF}
    { close the local file }
    DestroyLocalStream;
    FFileSent := TRUE;
    FError    := ErrCode;
    Next3PutAsync;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.DataSocketPutDataAvailable(
    Sender  : TObject;
    ErrCode : word);
var
    Buffer  : array [1..2048] of Char;
    aSocket : TWSocket;
begin
    { We don't wants to receive data here because we are sending, not       }
    { receiving. But in order to not crash if we receive somthing, just     }
    { get it and do nothing with it !                                       }
    aSocket := Sender as TWSocket;
    aSocket.Receive(@Buffer[1], High(Buffer));
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.TransfertStats;
var
    Buffer   : String;
    BytesSec : LongInt;
    Duration : LongInt;  { V2.100 allow wrap at 49 days, don't show 0 secs or silly bps }
begin
    FStopTime := LongInt(GetTickCount);
    Buffer    := IntToSTr(FByteCount) + ' bytes received/sent in ';
    if DWORD (FStopTime) >= DWORD (FStartTime) then   { V2.102 fix zero duration downloads }
        Duration := DWORD (FStopTime) - DWORD (FStartTime)
    else
        Duration := ($FFFFFFFF - DWORD (FStartTime)) + DWORD (FStopTime);
    if Duration < 5000 then
        Buffer := Buffer + IntToStr(Duration) + ' milliseconds'
    else begin
        Buffer := Buffer + IntToStr(Duration div 1000) + ' seconds';
    if FStopTime <> FStartTime then begin
        if FByteCount > 32767 then
                BytesSec := 1000 * (FByteCount div Duration)
        else
                BytesSec := (1000 * FByteCount) div Duration;
        Buffer := Buffer + ' (' + IntToStr(BytesSec) + ' Bytes/sec)';
    end;
    end;
    TriggerDisplay('! ' + Buffer);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.ExecGetAsync;
begin
    DoGetAsync(ftpGetAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.ExecDirAsync;
begin
    DoGetAsync(ftpDirAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.ExecLsAsync;
begin
    DoGetAsync(ftpLsAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.ExecMlsdAsync;     { V2.90 }
begin
    DoGetAsync(ftpMlsdAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.SetShareMode(newValue : TFtpShareMode);
begin
{$IFNDEF VER80}{$WARNINGS OFF}{$ENDIF}
    case newValue of
    ftpShareCompat    : FShareMode := fmShareCompat;
    ftpShareExclusive : FShareMode := fmShareExclusive;
    ftpShareDenyWrite : FShareMode := fmShareDenyWrite;
    ftpShareDenyRead  : FShareMode := fmShareDenyRead;
    ftpShareDenyNone  : FShareMode := fmShareDenyNone;
    else
        FShareMode := fmShareExclusive;
    end;
{$IFNDEF VER80}{$WARNINGS ON}{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomFtpCli.GetShareMode : TFtpShareMode;
begin
{$IFNDEF VER80}{$WARNINGS OFF}{$ENDIF}
    case FShareMode of
    fmShareCompat    : Result := ftpShareCompat;
    fmShareExclusive : Result := ftpShareExclusive;
    fmShareDenyWrite : Result := ftpShareDenyWrite;
    fmShareDenyRead  : Result := ftpShareDenyRead;
    fmShareDenyNone  : Result := ftpShareDenyNone;
    else
        Result := ftpShareExclusive;
    end;
{$IFNDEF VER80}{$WARNINGS ON}{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.SetDisplayFileMode(NewValue : TFtpDisplayFileMode);
begin
    case NewValue of
        ftpLineByLine, ftpBinary : FDisplayFileMode := NewValue;
    else
        FDisplayFileMode := ftpLineByLine;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomFtpCli.GetDisplayFileMode : TFtpDisplayFileMode;
begin
    case FDisplayFileMode of
      ftpLineByLine: Result := ftpLineByLine;
      ftpBinary: Result := ftpBinary;
    else
      Result := ftpLineByLine;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.SetConnectionType(NewValue: TFtpConnectionType);
begin
    { Must be disconnected to change the connection type }
    if FConnected then begin
        HandleError('FTP component connected');
        Exit;
    end;
    { Change connection type }
    case NewValue of
    ftpDirect: begin
                 FConnectionType                    := NewValue;
                 FControlSocket.SocksAuthentication := socksNoAuthentication;
                 FDataSocket.SocksAuthentication    := socksNoAuthentication;
               end;
    ftpProxy: begin
                FConnectionType                     := NewValue;
                FPassive                            := TRUE;
                FControlSocket.SocksAuthentication  := socksNoAuthentication;
                FDataSocket.SocksAuthentication     := socksNoAuthentication;
              end;
    ftpSocks4: begin
                 FConnectionType := NewValue;
                 FPassive        := TRUE;
                 with FControlSocket do begin
                     SocksLevel          := '4';
                     SocksAuthentication := socksAuthenticateUsercode;
                 end;
                 with FDataSocket do begin
                     SocksLevel          := '4';
                     SocksAuthentication := socksAuthenticateUsercode;
                 end;
               end;
    ftpSocks4A: begin
                  FConnectionType := NewValue;
                  FPassive        := TRUE;
                  with FControlSocket do begin
                      SocksLevel          := '4A';
                      SocksAuthentication := socksAuthenticateUsercode;
                  end;
                  with FDataSocket do begin
                      SocksLevel          := '4A';
                      SocksAuthentication := socksAuthenticateUsercode;
                  end;
                end;
    ftpSocks5: begin
                 FConnectionType := NewValue;
                 FPassive        := TRUE;
                 with FControlSocket do begin
                     SocksLevel          := '5';
                     SocksAuthentication := socksAuthenticateUsercode;
                 end;
                 with FDataSocket do begin
                   SocksLevel          := '5';
                   SocksAuthentication := socksAuthenticateUsercode;
                 end;
               end;
    else
        FConnectionType                    := ftpDirect;
        FControlSocket.SocksAuthentication := socksNoAuthentication;
        FDataSocket.SocksAuthentication    := socksNoAuthentication;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomFtpCli.GetConnectionType: TFtpConnectionType;
begin
    case FConnectionType of
    ftpDirect  : Result := ftpDirect;
    ftpProxy   : Result := ftpProxy;
    ftpSocks4  : Result := ftpSocks4;
    ftpSocks4A : Result := ftpSocks4A;
    ftpSocks5  : Result := ftpSocks5;
    else
        Result := ftpDirect;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.SetSocksPassword(NewValue: String);
begin
    FControlSocket.SocksPassword := NewValue;
    FDataSocket.SocksPassword    := NewValue;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomFtpCli.GetSocksPassword: String;
begin
    Result := FControlSocket.SocksPassword;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.SetSocksPort(NewValue: String);
begin
    FControlSocket.SocksPort := NewValue;
    FDataSocket.SocksPort    := NewValue;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomFtpCli.GetSocksPort: String;
begin
    Result := FControlSocket.SocksPort;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.SetSocksServer(NewValue: String);
begin
    FControlSocket.SocksServer := NewValue;
    FDataSocket.SocksServer    := NewValue;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomFtpCli.GetSocksServer: String;
begin
    Result := FControlSocket.SocksServer;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.SetSocksUserCode(NewValue: String);
begin
    FControlSocket.SocksUserCode := NewValue;
    FDataSocket.SocksUserCode    := NewValue;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomFtpCli.GetSocksUserCode: String;
begin
    Result := FControlSocket.SocksUserCode;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.SetPassive(NewValue: Boolean);
begin
    { Passive state must not be changed if Proxy or Socks connection        }
    { type is selected                                                      }
    case FConnectionType of
    ftpDirect: FPassive := NewValue;
    ftpProxy, ftpSocks4, ftpSocks4A, ftpSocks5: FPassive := TRUE;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.DataSocketGetInit(const TargetPort, TargetIP : String);
begin
    FDataSocket.Port               := TargetPort;
    FDataSocket.Addr               := TargetIP; {ControlSocket.Addr;}
    FDataSocket.LocalAddr          := FLocalAddr; {bb}
    FDataSocket.OnSessionConnected := DataSocketGetSessionConnected;
    FDataSocket.LingerOnOff        := wsLingerOff;
    FDataSocket.LingerTimeout      := 0;
    FDataSocket.ComponentOptions   := [wsoNoReceiveLoop];   { 26/10/02 }
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Receive a file or a directory list of a file list                         }
procedure TCustomFtpCli.DoGetAsync(RqType : TFtpRequest);
{$IFDEF VER80}
const
    FILE_END = 2;
{$ENDIF}
var
    Temp       : String;
    I {, MaxWbits} : Integer;
    TargetPort : WORD;    { 10/30/99 }
    TargetIP   : String;
{$IFDEF STREAM64}                      { V2.101 }
    NewPos     : Int64;
{$ELSE}
    NewPos     : LongInt;
{$ENDIF}

    procedure OpenFileStream (Mode: Word);   { V2.105 }
    begin
{$IFDEF USE_BUFFERED_STREAM}
        FLocalStream := TBufferedFileStream.Create(FLocalFileName,
                                                    Mode, MAX_BUFSIZE);
{$ELSE}
        FLocalStream := TFileStream.Create(FLocalFileName, Mode);
{$ENDIF}
    end ;

begin
    if not FConnected then begin
        HandleError(FGetCommand + ': not connected');
        Exit;
    end;

    { If no filename was assigned, check if maybe we wanna view it, }
    { meaning - FDisplayFileFlag }
    if (Length(FLocalFileName) <= 0) and
       not (FDisplayFileFlag or FStreamFlag) then begin
        HandleError('LocalFileName empty');
        Exit;
    end;

    if not FHighLevelFlag then
        FRequestType := RqType;

    case RqType of
    ftpGetAsync:  FGetCommand := 'RETR';
    ftpDirAsync:  FGetCommand := 'LIST';
    ftpLsAsync:   FGetCommand := 'NLST';
    ftpMlsdAsync: FGetCommand := 'MLSD';    { V2.90 }
    end;

    FServerSaidDone    := FALSE;
    FFileReceived      := FALSE;
    FRequestDoneFlag   := FALSE;
    FByteCount         := 0;
    FError             := 0;

    FDataSocket.OnSessionAvailable := DataSocketGetSessionAvailable;

{$IFDEF VER80}
    { With Delphi 1 you need to nul terminate each string }
    FLocalFileName[Length(FLocalFileName) + 1] := chr(0);
{$ENDIF}

    { open the destination file }
    { Don't open a file if we're on FDisplayFileFlag }
    if not FDisplayFileFlag then
    try
        DestroyLocalStream;
        if FResumeAt <= 0 then begin
            if not Assigned(FLocalStream) and not FStreamFlag then begin
                OpenFileStream(fmCreate);   { V2.105 }
                if FShareMode <> 0 then begin
                    { Not default mode, need to close and reopen file with }
                    { the given mode                                       }
                    FLocalStream.Destroy;
                    OpenFileStream(fmOpenWrite + FShareMode);
                end;
            end;
        end
        else begin
            { V2.101 TStream does not have 64-bit seek, only TFileStream, check seek works }
            if not Assigned(FLocalStream) and not FStreamFlag then begin
                OpenFileStream (fmOpenWrite + FShareMode);
{$IFDEF USE_BUFFERED_STREAM}   { V2.105 }
                NewPos := TBufferedFileStream(FLocalStream).Seek(FResumeAt,  { V2.103 }
                                                             soFromBeginning) ;
{$ELSE}
    {$IFDEF STREAM64}             { V2.101 D6 seems to call integer version of Seek, not Int64 }
                NewPos := MySeek64 (FLocalStream, FResumeAt, soFromBeginning);
    {$ELSE}
                NewPos := TFileStream(FLocalStream).Seek(FResumeAt, soFromBeginning) ;
    {$ENDIF}
{$ENDIF}
            end
            else
                NewPos := FLocalStream.Seek(FResumeAt, soFromBeginning) ;
            if NewPos <> FResumeAt then begin
                FLastResponse := 'Unable to set resume position in local file';
                FStatusCode   := 550;
                SetErrorMessage;
                FDataSocket.Close;
                FRequestResult := FStatusCode;
                TriggerRequestDone(FRequestResult);
                exit;
            end;
        end;
{$IFDEF USE_MODEZ}
        if FCurrTransMode = ftpTransModeZDeflate then begin    { V1.103 }
            zlibProblemString := '';
            FModeZStream := TMemoryStream.Create;
         // option 1 - save all data into stream, decompress on close
            FZStreamState := ftpZStateSaveDecom;

         // option 2 - decode immediately (still need to save a little - not done yet)
        end;
{$ENDIF}
    except
        on E:Exception do begin
            FLastResponse := 'Unable to open local file ' +
                                           FLocalFileName + ': ' + E.Message; { V2.101}
            FStatusCode   := 550;
            SetErrorMessage;
            FDataSocket.Close;
            FRequestResult := FStatusCode;
            TriggerRequestDone(FRequestResult);
            exit;
        end;
    end;

    if FPassive then begin
        Temp := FPasvResponse;
        Delete(Temp, 1, Pos('(', Temp));

        TargetIP := '';
        for I := 1 to 4 do begin
            TargetIP := TargetIP + Copy(Temp, 1, Pos(',',Temp) - 1) + '.';
            Delete(Temp, 1, Pos(',', Temp));
        end;
        TargetIP := Copy(TargetIP, 1, Length(TargetIP) - 1);

        TargetPort := StrToInt(Copy(Temp, 1, Pos(',', Temp) - 1)) * 256;
        Delete(Temp, 1, Pos(',', Temp));
        TargetPort := TargetPort + StrToInt(Copy(Temp, 1, Pos(')', Temp) - 1));

        DataSocketGetInit(IntToStr(TargetPort), TargetIP);
{$IFDEF USE_SSL}
__DataSocket := FDataSocket;
{$IFNDEF NO_DEBUG_LOG}                                              { 2.104 }
    if CheckLogOptions(loProtSpecInfo) then
        DebugLog(loProtSpecInfo, '! Data Socket Connect');
{$ENDIF}
{$ENDIF}
        try
            FDataSocket.Connect;
        except
            on E:Exception do begin
                FLastResponse := '550 ' + E.ClassName + ': ' + E.Message;
                FStatusCode   := 550;
                SetErrorMessage;
                FDataSocket.Close;
                FRequestResult := FStatusCode;
                TriggerRequestDone(FRequestResult);
                exit;
            end;
        end;
    end;

    StateChange(ftpWaitingResponse);
    FNext := Next1GetAsync;
    if Length(FHostFileName) > 0 then
        SendCommand(FGetCommand + ' ' + FHostFileName)
    else
        SendCommand(FGetCommand);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ We comes here when receiving the response for the RETR command we sent    }
procedure TCustomFtpCli.Next1GetAsync;
begin
    DisplayLastResponse;
    GetInteger(@FLastResponse[1], FStatusCode);
    if not (((FStatusCode div 10) = 15) or   { Accept range 150-159 }
            (FStatusCode = 125)) then begin  { Accept code 125      }
        SetErrorMessage;
        FNext := nil;
        FDataSocket.Close;
        DestroyLocalStream;
        { Reset the starting position }
        FResumeAt      := 0;
        FRequestResult := FStatusCode;
        TriggerRequestDone(FRequestResult);
        Exit;
    end;
    FNext := Next2GetAsync;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ We comes here when the FTP server has sent the file we asked to GET       }
procedure TCustomFtpCli.Next2GetAsync;
begin
    DisplayLastResponse;
    GetInteger(@FLastResponse[1], FStatusCode);
    if not ((FStatusCode = 125) or (FStatusCode = 226) or
            (FStatusCode = 250)) then begin
        SetErrorMessage;
        DestroyLocalStream;
        FDataSocket.Close;
        TriggerDisplay('! RETR/LIST/NLST Failed');
        FRequestResult := FStatusCode;
        TriggerRequestDone(FRequestResult);
        Exit;
    end;
    FServerSaidDone := TRUE;
    Next3GetAsync;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ We comes here either if the file has been received of the FTP server has  }
{ his response.                                                             }
procedure TCustomFtpCli.Next3GetAsync;
begin
{$IFNDEF NO_DEBUG_LOG}                                             { 2.105 }
    if CheckLogOptions(loProtSpecDump) then
        DebugLog(loProtSpecDump, '! Next3GetAsync');
{$ENDIF}
    if (not FServerSaidDone) or (not FFileReceived) then
        Exit;

    { Display statistics }
    TransfertStats;

    { Reset the starting position }
    FResumeAt      := 0;
    FRequestResult := FError;
    TriggerRequestDone(FRequestResult);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.ExecPutAsync;
begin
    FAppendFlag  := FALSE;
    FRequestType := ftpPutAsync;
    DoPutAppendAsync;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.ExecAppendAsync;
begin
    FAppendFlag  := TRUE;
    FRequestType := ftpAppendAsync;
    DoPutAppendAsync;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.DataSocketPutAppendInit(const TargetPort, TargetIP : String);
begin
    FDataSocket.Port               := TargetPort;
    FDataSocket.Addr               := TargetIP; {ControlSocket.Addr;}
    FDataSocket.LocalAddr          := FLocalAddr; {bb}
    FDataSocket.OnSessionConnected := DataSocketPutSessionConnected;
    { Normally we should use LingerOn with a timeout. But doing so will }
    { often result in error 10055 triggered after a lot of consecutive  }
    { file transfers. There is code in DataSocketPutDataSent to make    }
    { sure last packet is sent completely.                              }
    FDataSocket.LingerOnOff        := wsLingerOff;
    FDataSocket.LingerTimeout      := 0;
    FDataSocket.ComponentOptions   := [wsoNoReceiveLoop];   { 26/10/02 }
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.DoPutAppendAsync;
{$IFDEF VER80}
const
    FILE_END = 2;
{$ENDIF}
var
    Temp        : String;
    I           : Integer;
    TargetPort  : WORD;   { 10/30/99 }
    TargetIP    : String;
    bCancel     : Boolean;
{$IFDEF STREAM64}                      { V2.101 }
    NewPos      : Int64;
    Uploadsize  : Int64;
{$ELSE}
    NewPos      : LongInt;
    Uploadsize  : LongInt;
{$ENDIF}
begin
    if not FConnected then begin
        HandleError('STOR/APPE: not connected');
        Exit;
    end;

    if (not FStreamFlag) and (Length(FLocalFileName) <= 0) then begin
        HandleError('LocalFileName empty');
        Exit;
    end;

    FServerSaidDone    := FALSE;
    FFileSent          := FALSE;
    FRequestDoneFlag   := FALSE;
    FPutSessionOpened  := FALSE;
    FStorAnswerRcvd    := FALSE;
    FStartTime         := 0;
    FByteCount         := 0;
    FError             := 0;

    bCancel := FALSE;
    TriggerReadyToTransmit(bCancel);
    if bCancel then begin
        FErrorMessage := '426 Transmit cancelled by application';
        FStatusCode   := 426;
        TriggerDisplay('! ' + FErrorMessage);
        FRequestResult := FStatusCode;
        TriggerRequestDone(FRequestResult);
        Exit;
    end;

    FDataSocket.OnSessionAvailable := DataSocketPutSessionAvailable;
{$IFDEF VER80}
    { With Delphi 1 you need to nul terminate each string }
    FLocalFileName[Length(FLocalFileName) + 1] := chr(0);
{$ENDIF}

    { open the local source file }
    try
        { Be sure to have previous instance closed }
        DestroyLocalStream;
        FEofFlag     := FALSE;
          { V2.101 TStream does not have 64-bit seek, only TFileStream }
        NewPos := FResumeAt;
        if not Assigned(FLocalStream) and not FStreamFlag then begin
{$IFDEF USE_BUFFERED_STREAM}    { V2.105 } 
            FLocalStream := TBufferedFileStream.Create(FLocalFileName,
                            fmOpenRead + FShareMode, MAX_BUFSIZE);  { V2.103 }
{$ELSE}
            FLocalStream := TFileStream.Create(FLocalFileName,
                                               fmOpenRead + FShareMode);
{$ENDIF}
            if FResumeAt > 0 then begin
{$IFDEF USE_BUFFERED_STREAM}    { V2.105 } 
                NewPos := TBufferedFileStream(FLocalStream).Seek(FResumeAt,
                                              soFromBeginning);  { V2.103 }

{$ELSE}
    {$IFDEF STREAM64}             { V2.101 D6 seems to call integer version of Seek, not Int64 }
                NewPos := MySeek64 (FLocalStream, FResumeAt, soFromBeginning);
    {$ELSE}
                NewPos := TFileStream(FLocalStream).Seek(FResumeAt, soFromBeginning);
    {$ENDIF}
{$ENDIF}
            end;
        end
        else begin
        if FResumeAt > 0 then
                NewPos := FLocalStream.Seek(FResumeAt, soFromBeginning);
        end ;
        if NewPos <> FResumeAt then begin
            FLastResponse := 'Unable to set resume position in local file';
            FStatusCode   := 550;
            SetErrorMessage;
            FDataSocket.Close;
            FRequestResult := FStatusCode;
            TriggerRequestDone(FRequestResult);
            exit;
        end;
    except
        on E:Exception do begin
            FLastResponse := 'Unable to open local file ' +
                                           FLocalFileName + ': ' + E.Message; { V2.101}
            FStatusCode   := 426;
            TriggerDisplay('! ' + FErrorMessage);
            FDataSocket.Close;
            FRequestResult := FStatusCode;
            TriggerRequestDone(FRequestResult);
            Exit;
        end;
    end;

    Uploadsize := FLocalStream.Size - FLocalStream.Position;
{$IFDEF USE_MODEZ}
    if FCurrTransMode = ftpTransModeZDeflate then begin    { V1.103 }
        zlibProblemString := '';
        FModeZStream := TMemoryStream.Create;
     { option 1 - compress data into stream, send stream  }
        FZStreamState := ftpZStateSaveComp;
        try
            ZlibCompressStreamEx (FLocalStream, FModeZStream, clFastest, zsZLib, false);
            FModeZStream.Position := 0 ;
            TriggerDisplay('! Upload Size, Compressed ' + IntToStr
                      (FModeZStream.Size) + ' bytes, Uncompressed ' +
                                            IntToStr (Uploadsize) + ' bytes') ;
        except
            on E:Exception do begin
                FModeZStream.Destroy;
                FModeZStream := nil;
                HandleError('Failed to Compress Stream - ' + E.Message);
                FStatusCode   := 426;
                FDataSocket.Close;
                FRequestResult := FStatusCode;
                TriggerRequestDone(FRequestResult);
            end;
        end;

     { option 2 - compress during send - not implemented yet }
    end
    else
{$ENDIF}
        TriggerDisplay('! Upload Size ' + IntToStr (Uploadsize)) ;

    if FPassive then begin
        Temp := FPasvResponse;  { 26/12/99 }
        Delete(Temp, 1, Pos('(', Temp));
        TargetIP := '';
        for I := 1 to 4 do begin
            TargetIP := TargetIP + Copy(Temp, 1, Pos(',',Temp) - 1) + '.';
            Delete(Temp, 1, Pos(',', Temp));
        end;
        TargetIP := Copy(TargetIP, 1, Length(TargetIP) - 1);

        TargetPort := StrToInt(Copy(Temp, 1, Pos(',', Temp) - 1)) * 256;
        Delete(Temp, 1, Pos(',', Temp));
        TargetPort := TargetPort + StrToInt(Copy(Temp, 1, Pos(')', Temp) - 1));

        DataSocketPutAppendInit(IntToStr(TargetPort), TargetIP);
        try
            FDataSocket.Connect;
        except
            on E:Exception do begin
                FLastResponse := '426 ' + E.ClassName + ': ' + E.Message;
                FStatusCode   := 426;
                SetErrorMessage;
                FDataSocket.Close;
                FRequestResult := FStatusCode;
                TriggerRequestDone(FRequestResult);
                Exit;
            end;
        end;
        Exit;
    end;

    StateChange(ftpWaitingResponse);
    FNext := Next1PutAsync;

    if FAppendFlag then
        SendCommand('APPE ' + FHostFileName)
    else
        SendCommand('STOR ' + FHostFileName);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ We comes here when receiving the response for the STOR command we sent    }
procedure TCustomFtpCli.Next1PutAsync;
var
    p : PChar;
begin
    DisplayLastResponse;
    if not (FLastResponse[1] in ['0'..'9']) then
        Exit; { Continuation line, nothing to do }
    p := GetInteger(@FLastResponse[1], FStatusCode);
    if p^ = '-' then
        Exit; { Continuation line, nothing to do }

    if not ((FStatusCode = 150) or (FStatusCode = 125)) then begin
        SetErrorMessage;
        FNext := nil;
        FDataSocket.Close;
        DestroyLocalStream;
        { Reset the starting position }
        FResumeAt      := 0;
        FRequestResult := FStatusCode;
        TriggerRequestDone(FRequestResult);
        Exit;
    end;

    if FPassive then begin
        { Send the first data block }
{$IFNDEF NO_DEBUG_LOG}                                             { 2.105 }
    if CheckLogOptions(loProtSpecInfo) then
        DebugLog(loProtSpecInfo, '! Send first block');
{$ENDIF}
        FStorAnswerRcvd        := TRUE;
        FDataSocket.OnDataSent := DataSocketPutDataSent;
        DataSocketPutDataSent(FDataSocket, 0);
    end
    else begin
        { V240 FStorAnswerRcvd := TRUE; }
        FStorAnswerRcvd := TRUE;
        if FPutSessionOpened and (FStartTime = 0) then
            PostMessage(Handle, WM_FTP_SENDDATA, 0, 0);
    end;


    FNext := Next2PutAsync;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ We comes here when the FTP server has received the file we sent (STOR)    }
procedure TCustomFtpCli.Next2PutAsync;
var
    p : PChar;
begin
    DisplayLastResponse;
    if not (FLastResponse[1] in ['0'..'9']) then
        Exit; { Continuation line, nothing to do }
    p := GetInteger(@FLastResponse[1], FStatusCode);
    if p^ = '-' then
        Exit; { Continuation line, nothing to do }
    if not ((FStatusCode = 226) or (FStatusCode = 250)) then begin
        SetErrorMessage;
        DestroyLocalStream;
        FDataSocket.Close;
        TriggerDisplay('! STOR Failed');
        FRequestResult := FStatusCode;
        TriggerRequestDone(FRequestResult);
        Exit;
    end;
    FServerSaidDone := TRUE;
    Next3PutAsync;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ We comes here when the file has been sent or when the FTP server tell us  }
{ he recived the file.                                                      }
procedure TCustomFtpCli.Next3PutAsync;
begin
{$IFNDEF NO_DEBUG_LOG}                                             { 2.105 }
    if CheckLogOptions(loProtSpecDump) then
        DebugLog(loProtSpecDump, '! Next3PutAsync');
{$ENDIF}
    if (not FServerSaidDone) or (not FFileSent) then
        Exit;

    { Display statistics }
    TransfertStats;

    { Reset the starting position }
    FResumeAt      := 0;
    FRequestResult := FError;
    TriggerRequestDone(FRequestResult);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.PortAsync;
var
    Msg          : String;
    saddr        : TSockAddrIn;
    saddrlen     : Integer;
    DataPort     : DWORD;  { 10/30/99 }
    IPAddr       : TInAddr;
    StartDataPort: DWORD;
begin
    { Makes the data socket listening for data connection }
    FDataSocket.Proto              := 'tcp';
    FDataSocket.Addr               := '0.0.0.0';  { INADDR_ANY }
    FDataSocket.Port               := '0';        { IPPORT_ANY }
    FDataSocket.OnSessionAvailable := nil;
    FDataSocket.OnSessionClosed    := nil;
    FDataSocket.OnDataAvailable    := nil;

    if FPassive then
        DataPort := 0    { Not needed, makes compiler happy }
    else begin
        if (ftpFctGet in FFctSet) or (ftpFctDir in FFctSet) or  {G.B. 2002/07/12}
           (ftpFctMlsd in FFctSet) then    { V2.90 }
            FDataSocket.OnSessionAvailable := DataSocketGetSessionAvailable
        else if ftpFctPut in FFctSet then
            FDataSocket.OnSessionAvailable := DataSocketPutSessionAvailable;
        FDataSocket.LingerOnOff        := wsLingerOn;
        FDataSocket.LingerTimeout      := 10;

        if (FDataPortRangeStart = 0) and (FDataPortRangeEnd = 0) then begin
            FDataSocket.Listen;
            { Get the port number as assigned by Windows }
            saddrLen  := SizeOf(saddr);
            FDataSocket.GetSockName(saddr, saddrLen);
            DataPort  := WSocket_ntohs(saddr.sin_port);
        end
        else begin
            { We use a data port range. Check if the range is valid }
            if FDataPortRangeStart > FDataPortRangeEnd then begin
                HandleError('DataPortRangeEnd must be greater than DataPortRangeStart');
                Exit;
            end;
            if (FLastDataPort < FDataPortRangeStart) or
               (FLastDataPort > FDataPortRangeEnd) then
                FLastDataPort := FDataPortRangeStart;
            DataPort      := FLastDataPort;
            StartDataPort := DataPort;
            while TRUE do begin
                FDataSocket.Port := IntToStr(DataPort);
                try
                    FDataSocket.Listen;
                    break;                { Found a free port }
                except
                    if FDataSocket.LastError = WSAEADDRINUSE then begin
                        DataPort := DataPort + 1;
                        if DataPort > FDataPortRangeEnd then
                            DataPort := FDataPortRangeStart;
                        if DataPort = StartDataPort then begin
                            HandleError('All ports in DataPortRange are in use');
                            Exit;
                        end;
                    end
                    else begin
                        HandleError('Data connection winsock.bind failed, error #' +
                                    IntToStr(FDataSocket.LastError));
                        Exit;
                    end;
                end;
            end;
            FLastDataPort := DataPort + 1;
            if FLastDataPort > FDataPortRangeEnd then
                FLastDataPort := FDataPortRangeStart;
        end;
    end;

    { Get our IP address from our control socket }
    saddrlen := SizeOf(saddr);
    FControlSocket.GetSockName(saddr, saddrlen);
    IPAddr   := saddr.sin_addr;

    { Strange behaviour of PWS (FrontPage 97 Web Server for W95) }
    { which do not like effective address when localhost is used }
    if FPassive then
        Msg := 'PASV'
    else begin
        if FControlSocket.sin.sin_addr.s_addr = WSocket_htonl($7F000001) then
            Msg := Format('PORT 127,0,0,1,%d,%d',
                          [HiByte(DataPort),
                           LoByte(DataPort)])
        else
            Msg := Format('PORT %d,%d,%d,%d,%d,%d',
                          [ord(IPAddr.S_un_b.s_b1),
                           ord(IPAddr.S_un_b.s_b2),
                           ord(IPAddr.S_un_b.s_b3),
                           ord(IPAddr.S_un_b.s_b4),
                           HiByte(DataPort),
                           LoByte(DataPort)]);
    end;

    FByteCount := 0;
    FFctPrv    := ftpFctPort;
    ExecAsync(ftpPortAsync, Msg, [200, 227], nil);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.ControlSocketDnsLookupDone(
    Sender  : TObject;
    ErrCode : Word);
begin
    if ErrCode <> 0 then begin
        FLastResponse  := '500 ' + WSocketErrorDesc(ErrCode) +
                          ' (Winsock error #' + IntToStr(ErrCode) + ')';
        FStatusCode    := 500;
        FRequestResult :=  FStatusCode;    { 21/05/99 }
        SetErrorMessage;
        TriggerRequestDone(ErrCode);
    end
    else begin
        FDnsResult               := FControlSocket.DnsResult;
        FControlSocket.Addr      := FDnsResult;
        FControlSocket.LocalAddr := FLocalAddr; {bb}
        FControlSocket.Proto     := 'tcp';
{$IFDEF USE_SSL}
        FControlSocket.SslEnable := FALSE;
{$ENDIF}
        if (FConnectionType = ftpProxy) and (FProxyPort <> '') then
            FControlSocket.Port  := FProxyPort
        else
            FControlSocket.Port  := FPort;
{       FControlSocket.OnDisplay := FOnDisplay; } { Debugging only }
        StateChange(ftpWaitingBanner);
        try
            FControlSocket.Connect;
        except
            on E:Exception do begin
                FLastResponse := '500 ' + E.ClassName + ': ' + E.Message;
                FStatusCode   := 500;
                FRequestResult :=  FStatusCode;    { 21/05/99 }
                SetErrorMessage;
                TriggerRequestDone(FStatusCode);
            end;
        end;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.ControlSocketSessionConnected(Sender: TObject; ErrCode: Word);
begin
    { Do not trigger the client SessionConnected from here. We must wait }
    { to have received the server banner.                                }
    if ErrCode <> 0 then begin
        FLastResponse  := '500 ' + WSocketErrorDesc(ErrCode) +
                          ' (Winsock error #' + IntToStr(ErrCode) + ')';
        FStatusCode    := 500;
        FRequestResult := FStatusCode;  { Heedong Lim, 05/14/1999 }
        SetErrorMessage; { Heedong Lim, 05/14/1999 }
        FNextRequest   := nil;
        TriggerRequestDone(ErrCode);
        FControlSocket.Close;
        StateChange(ftpReady);
    end
    else
        FConnected := TRUE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.ControlSocketDataAvailable(Sender: TObject; ErrCode: Word);
var
    Len  : Integer;
    I, J : Integer;
    p    : PChar;
    Feat : String;
begin
    Len := FControlSocket.Receive(@FReceiveBuffer[FReceiveLen],
                                  SizeOf(FReceiveBuffer) - FReceiveLen - 1);

    if FRequestType = ftpRqAbort then
        Exit;

    if Len = 0 then begin
        { Remote has closed. We will soon receive FD_CLOSE (OnSessionClosed) }
        { FControlSocket.Close;                                              }
        Exit;
    end;
    if Len < 0 then
        Exit;

    FReceiveBuffer[FReceiveLen + Len] := #0;
    FReceiveLen := FReceiveLen + Len;

    while FReceiveLen > 0 do begin
        if ftpAcceptLF in FOptions then begin
            I := Pos(#10, FReceiveBuffer);
            J := I;
        end
        else begin
            I := Pos(#13#10, FReceiveBuffer);
            J := I + 1;
        end;
        if I <= 0 then
            break;
        if I > FReceiveLen then
            break;

        FLastResponse := Copy(FReceiveBuffer, 1, I - 1);
        { Remove trailing control chars }
        while (Length(FLastResponse) > 0) and
              (FLastResponse[Length(FLastResponse)] in [#10, #13]) do
             SetLength(FLastResponse, Length(FLastResponse) - 1);

        { V2.90 some FTP responses are multiline, welcome banner, FEAT  }
        { command, keep them all but do not exceed 64KB to avoid DOS    }
        if LongInt(Length(FLastMultiResponse)) < 65536 then
            FLastMultiResponse := FLastMultiResponse + FLastResponse + #13#10;

        if Assigned(FOnResponse) then
            FOnresponse(Self);

{$IFNDEF NO_DEBUG_LOG}                                             { 2.105 }
    if CheckLogOptions(loProtSpecDump) then
        DebugLog(loProtSpecDump, '>|' + FLastResponse + '|' + #13#10);
{$ENDIF}
{$IFDEF VER80}
        { Add a nul byte at the end of string for Delphi 1 }
        FLastResponse[Length(FLastResponse) + 1] := #0;
{$ENDIF}
        FReceiveLen := FReceiveLen - J;
        if FReceiveLen > 0 then
            Move(FReceiveBuffer[J], FReceiveBuffer[0], FReceiveLen + 1)
        else if FReceiveLen < 0 then
            FReceiveLen := 0;

        if FState = ftpWaitingBanner then begin
            DisplayLastResponse;
            if (FLastResponse = '') or                       { 15/02/03 }
               (not (FLastResponse[1] in ['0'..'9'])) then
                Continue;  { Continuation line, ignore }
            p := GetInteger(@FLastResponse[1], FStatusCode);
            if p^ = '-' then
                Continue;  { Continuation line, ignore }
            if FStatusCode <> 220 then begin
                SetErrorMessage;
                FRequestResult := FStatusCode;
                FControlSocket.Close;
                Exit;
            end;

            StateChange(ftpConnected);
            if Assigned(FOnSessionConnected) then
                FOnSessionConnected(Self, ErrCode);

            if Assigned(FWhenConnected) then
                FWhenConnected
            else begin
                TriggerRequestDone(0);
            end;
        end
        else if FState = ftpWaitingResponse then begin
            if FFctPrv in [ftpFctFeat] then begin       { V2.90 supported extensions }
                Feat := Trim (FLastResponse);
                if (Pos ('MDTM YYYYMMDDHHMMSS[+-TZ]', Feat) = 1) then
                        FSupportedExtensions := FSupportedExtensions + [ftpFeatMDTMYY];
                if Feat = 'MDTM' then
                        FSupportedExtensions := FSupportedExtensions + [ftpFeatMDTM];
                if Feat = 'SIZE' then
                        FSupportedExtensions := FSupportedExtensions + [ftpFeatSize];
                if Feat = 'REST STREAM' then
                        FSupportedExtensions := FSupportedExtensions + [ftpFeatRest];
                if Pos ('MLST', Feat) = 1 then begin
                    FSupportedExtensions := FSupportedExtensions + [ftpFeatMLST];
                    if Length (Feat) > 6 then FMLSTFacts := Trim (Copy (Feat, 6, 99));
                end;
                if Feat = 'MFMT' then
                        FSupportedExtensions := FSupportedExtensions + [ftpFeatMFMT]; { V2.94 same as MDTM YYYYMMDDHHMMSS }
                if Feat = 'MD5' then
                        FSupportedExtensions := FSupportedExtensions + [ftpFeatMD5];   { V2.94 }
                { AUTH, PROT by AG }
                if Pos('AUTH', Feat) = 1 then begin
                    if Pos('SSL', Feat) > 5 then
                        FSupportedExtensions := FSupportedExtensions + [ftpFeatAuthSSL];
                    if (Pos('TLS', Feat) > 5) then
                        FSupportedExtensions := FSupportedExtensions + [ftpFeatAuthTLS];
                end;
                if Pos('PROT', Feat) = 1 then begin
                    if Pos('C', Feat) > 5 then
                        FSupportedExtensions := FSupportedExtensions + [ftpFeatProtC];
                    if (Pos('P', Feat) > 5) then
                        FSupportedExtensions := FSupportedExtensions + [ftpFeatProtP];
                end;
                if Feat = 'PBSZ' then
                    FSupportedExtensions := FSupportedExtensions + [ftpFeatPbsz];    { V2.106 }
                if Feat = 'CCC' then
                    FSupportedExtensions := FSupportedExtensions + [ftpFeatCCC];
                if Pos ('MODE Z', Feat) = 1 then begin  { V1.103 currently ignoring compression options }
                    FSupportedExtensions := FSupportedExtensions + [ftpFeatModeZ];
                end;

           { Other extensions which are currently being ignored
             LANG EN*
             TVFS
             UTF8 
             SITE PSWD;EXEC;SET;INDEX;ZONE;CHMOD;MSG }
            end;
            if FFctPrv in [ftpFctMlst] then begin       { V2.90 response to MLST command }
                if (Length (FLastResponse) > 4) and (FStatusCode = 250) then begin
                    if FLastResponse[1] = ' ' then 
                        FRemFacts := Trim (FLastResponse);
                end;
            end;
            if (FLastResponse = '') or                            { 15/02/03 }
               (not (FLastResponse[1] in ['0'..'9'])) then begin  { 22/11/99 }
                DisplayLastResponse; { 02/11/01 }
                Continue;  { Continuation line, ignore }
            end;
            p := GetInteger(@FLastResponse[1], FStatusCode);
            if p^ = '-' then begin
                DisplayLastResponse; { 02/11/01 }
                Continue;  { Continuation line, ignore }
            end;
            if Assigned(FNext) then
                FNext
            else begin
                HandleError('Program error: FNext is nil');
                Exit;
            end;
        end
        else { Unexpected data received }
            DisplayLastResponse;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.ControlSocketSessionClosed(
    Sender  : TObject;
    ErrCode : Word);
begin
    if FConnected then begin
        FConnected := FALSE;
        if FState <> ftpAbort then
            StateChange(ftpNotConnected);
        if Assigned(FOnSessionClosed) then
            FOnSessionClosed(Self, ErrCode);
    end;
    if FState <> ftpAbort then
        StateChange(ftpInternalReady);
    if not (FRequestType in [ftpRqAbort]) then begin
        if ErrCode <> 0 then begin
            FLastResponse  := '500 Control connection closed. ' +
                              WSocketErrorDesc(ErrCode) +
                              ' (Winsock error #' + IntToStr(ErrCode) + ')';
            FStatusCode    := 500;
            FRequestResult :=  FStatusCode;    { 06 apr 2002 }
            SetErrorMessage;
        end;
        TriggerRequestDone(FRequestResult);
    end;    
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.TriggerStateChange;
begin
    if Assigned(FOnStateChange) then
        FOnStateChange(Self);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.TriggerRequestDone(ErrCode: Word);
begin
    if not FRequestDoneFlag then begin
        FRequestDoneFlag := TRUE;
        if (ErrCode = 0) and Assigned(FNextRequest) then begin
            if (FState <> ftpAbort)
               and (FState <> ftpPasvReady) { 19.09.2002 }
              { and     28/06/2002
               not ((ftpFctPut in FFctSet) and (FPassive = TRUE))} then
                StateChange(ftpInternalReady);
            FNextRequest;
        end
        else begin
            StateChange(ftpReady);
            if FDataSocket.State <> wsClosed then
                FDataSocket.Close;
            { Restore the lastresponse saved before quit command }
            if FHighLevelFlag and (FStatusCodeSave >= 0) then begin
                 FLastResponse := FLastResponseSave;
                 FStatusCode   := FStatusCodeSave;
            end;
            FHighLevelFlag := FALSE;
            FNextRequest   := nil;
            PostMessage(Handle, WM_FTP_REQUEST_DONE, 0, ErrCode);
            { if Assigned(FOnRequestDone) then
                FOnRequestDone(Self, FRequestType, ErrCode); }
        end;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.TriggerReadyToTransmit(var bCancel : Boolean);
begin
    if Assigned(FOnReadyToTransmit) then
        FOnReadyToTransmit(Self, bCancel);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomFtpCli.GetConnected : Boolean;
begin
    Result := FControlSocket.State <> wsClosed;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{$IFNDEF NO_DEBUG_LOG}
function TCustomFtpCli.GetIcsLogger: TIcsLogger;                    { 2.104 }
begin
    Result := FControlSocket.IcsLogger;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.SetIcsLogger(const Value: TIcsLogger);      { 2.104 }
begin
    FControlSocket.IcsLogger := Value;
    FDataSocket.IcsLogger    := Value;
end;



{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomFtpCli.CheckLogOptions(const LogOption: TLogOption): Boolean; { 2.104 }
begin
    Result := Assigned(IcsLogger) and (LogOption in IcsLogger.LogOptions);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.DebugLog(LogOption: TLogOption; const Msg: string);  { 2.104 }
begin
    if Assigned(IcsLogger) then
        IcsLogger.DoDebugLog(Self, LogOption, Msg);
end;
{$ENDIF}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomFtpCli.SetSslType(const Value: TFtpCliSslType);             { V2.106 }
begin
    FSslType := sslTypeNone;
    if Value <> sslTypeNone then
        raise FtpException.Create('SSL requires ICS-SSL version');
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{$IFDEF UseBandwidthControl}
procedure TCustomFtpCli.BandwidthTimerTimer(Sender : TObject);
begin
    if FBandwidthPaused then begin
        FBandwidthPaused := FALSE;
        Dec(FBandwidthCount, FBandwidthMaxCount);
        FDataSocket.Resume;
    end;
end;
{$ENDIF}

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{* *                                                                     * *}
{* *                              TFtpClient                             * *}
{* *                                                                     * *}
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
constructor TFtpClient.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    FTimeout := 15;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Open : Boolean;
begin
    Result := Synchronize(OpenAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.User : Boolean;
begin
    Result := Synchronize(UserAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Pass : Boolean;
begin
    Result := Synchronize(PassAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Acct : Boolean;
begin
    Result := Synchronize(AcctAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Connect : Boolean;
begin
    Result := Synchronize(ConnectASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Cwd : Boolean;
begin
    Result := Synchronize(CwdASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Pwd : Boolean;
begin
    Result := Synchronize(PwdASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.CDup : Boolean;
begin
    Result := Synchronize(CDupASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.TypeSet : Boolean;
begin
    Result := Synchronize(TypeSetASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.TypeBinary : Boolean;
begin
    Binary := TRUE;
    Result := Synchronize(TypeSetASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.TypeAscii : Boolean;
begin
    Binary := FALSE;
    Result := Synchronize(TypeSetASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Get : Boolean;
begin
    Result := Synchronize(GetASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Put : Boolean;
begin
    Result := Synchronize(PutASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ By A.Burlakov: new function for resuming uploads                          }
{ Uses REST + STOR commands instead APPEND                                  }
function TFtpClient.RestPut : Boolean;
begin
    Result := Synchronize(RestPutASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.RestartPut : Boolean;
begin
    Result := Synchronize(RestartPutASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Append : Boolean;
begin
    Result := Synchronize(AppendASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Quit : Boolean;
begin
    Result := Synchronize(QuitASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Abort : Boolean;
begin
    Result := Synchronize(AbortASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Receive : Boolean;
begin
    Result := Synchronize(ReceiveASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Transmit : Boolean;
begin
    Result := Synchronize(TransmitASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.AppendFile : Boolean;
begin
    Result := Synchronize(AppendFileASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Dir : Boolean;
begin
    Result := Synchronize(DirASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Directory : Boolean;
begin
    Result := Synchronize(DirectoryASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Ls : Boolean;
begin
    Result := Synchronize(LsASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.List : Boolean;
begin
    Result := Synchronize(ListASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Mkd : Boolean;
begin
    Result := Synchronize(MkdASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Mkdir : Boolean;
begin
    Result := Synchronize(MkdirASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Ren : Boolean;
begin
    Result := Synchronize(RenASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Rename : Boolean;
begin
    Result := Synchronize(RenameASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Dele : Boolean;
begin
    Result := Synchronize(DeleASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Delete : Boolean;
begin
    Result := Synchronize(DeleteASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Rmd : Boolean;
begin
    Result := Synchronize(RmdASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Rmdir : Boolean;
begin
    Result := Synchronize(RmdirASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Syst : Boolean;
begin
    Result := Synchronize(SystASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.System : Boolean;
begin
    Result := Synchronize(SystemASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Auth : Boolean;                                          { V2.106 }
begin
    Result := Synchronize(AuthASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Ccc : Boolean;                                           { V2.106 }
begin
    Result := Synchronize(CccASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Prot: Boolean;
begin
    Result := Synchronize(ProtASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Pbsz: Boolean;
begin
    Result := Synchronize(PbszASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.AuthenticateSsl : Boolean;
begin
    Result := Synchronize(AuthenticateSslASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Size : Boolean;
begin
    Result := Synchronize(SizeASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.FileSize : Boolean;
begin
    Result := Synchronize(FileSizeASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.AbortXfer: Boolean;
begin
    Result := Synchronize(AbortXferASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Quote : Boolean;
begin
    Result := Synchronize(QuoteASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.DoQuote : Boolean;
begin
    Result := Synchronize(DoQuoteASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.RestGet : Boolean;
begin
    Result := Synchronize(RestGetASync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.RestartGet : Boolean;
begin
    Result := Synchronize(RestartGetASync);
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Mlsd       : Boolean;    { V2.90 machine list directory }
begin
    Result := Synchronize(MlsdASync);
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Mlst       : Boolean;    { V2.90 machine list file      }
begin
    Result := Synchronize(MlstASync);
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Feat       : Boolean;    { V2.90 supported extensions   }
begin
    Result := Synchronize(FeatASync);
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Mdtm       : Boolean;    { V2.90 get file modification time }
begin
    Result := Synchronize(MdtmASync);
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Mdtmyy     : Boolean;    { V2.90 set file modification time }
begin
    Result := Synchronize(MdtmyyASync);
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function  TFtpClient.Mfmt       : Boolean;    { V2.94 modify file modification time }
begin
    Result := Synchronize(MfmtASync);
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function  TFtpClient.Md5       : Boolean;    { V2.94 get MD5 hash sum }
begin
    Result := Synchronize(Md5ASync);
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function  TFtpClient.ModeZ      : Boolean;    { V2.102 set mode z }
begin
    Result := Synchronize(ModeZASync);
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function  TFtpClient.Opts       : Boolean;    { V2.102 set mode z options }
begin
    Result := Synchronize(OptsASync);
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Progress : Boolean;
begin
    Result := inherited Progress;
    { Evaluate the timeout period again }
    if FTimeout > 0 then
        FTimeStop := LongInt(GetTickCount) + LongInt(FTimeout) * 1000;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpClient.MessagePump;
begin
{$IFDEF VER80}
    Application.ProcessMessages;
{$ELSE}
    if FMultiThreaded then begin
        if Assigned(FOnMessagePump) then
            FOnMessagePump(Self)
        else
            FControlSocket.ProcessMessages;
    end
    else
{$IFDEF NOFORMS}
        { The Forms unit (TApplication object) has not been included.           }
        { We used either an external message pump or our internal message pump. }
        { External message pump has to set Terminated property to TRUE when the }
        { application is terminated.                                            }
        if Assigned(FOnMessagePump) then
            FOnMessagePump(Self)
        else
            FControlSocket.ProcessMessages;
{$ELSE}
        Application.ProcessMessages;
{$ENDIF}
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.WaitUntilReady : Boolean;
var
    DummyHandle     : THandle;
begin
    Result    := TRUE;           { Assume success }
    FTimeStop := LongInt(GetTickCount) + LongInt(FTimeout) * 1000;
    while TRUE do begin
        if FState in [ftpReady, ftpInternalReady] then begin
            { Back to ready state, the command is finished }
            Result := (FRequestResult = 0);
            break;
        end;

        {$IFNDEF VER80}
        { Do not use 100% CPU }
        if ftpWaitUsingSleep in FOptions then
            Sleep(0)
        else begin
            DummyHandle := INVALID_HANDLE_VALUE;
            MsgWaitForMultipleObjects(0, {PChar(0)^}DummyHandle, FALSE, 1000,
                                      QS_ALLINPUT {or QS_ALLPOSTMESSAGE});
        end;

        MessagePump;
        if {$IFNDEF NOFORMS} Application.Terminated or
           {$ELSE}           Terminated or
           {$ENDIF}
           ((FTimeout > 0) and (LongInt(GetTickCount) > FTimeStop)) then begin
            { Timeout occured }
            AbortAsync;
            FErrorMessage := '426 Timeout';
            FStatusCode   := 426;
            Result        := FALSE; { Command failed }
            break;
        end;
        {$ENDIF}
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Synchronize(Proc : TFtpNextProc) : Boolean;
begin
    try
        Proc;
        Result := WaitUntilReady;
    except
        Result := FALSE;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ You must define USE_SSL so that SSL code is included in the component.    }
{ To be able to compile the component, you must have the SSL related files  }
{ which are _NOT_ freeware. See http://www.overbyte.be for details.         }
{$IFDEF USE_SSL}
    {$I FtpCliImplSsl.inc}
{$ENDIF}

end.


