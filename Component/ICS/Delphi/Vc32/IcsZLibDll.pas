{
  file   : IcsZLibDll.pas
  date   : 6 Dec 2005
  author : Xavier Le Bris
  e-mail : xavier.lebris@free.fr
  ICS version: Angus Robertson

  Subject
  -------
  A Borland Delphi unit to interface zlib.dll functions
  see also in zLib package (zlib 1.2.3) \contrib\delphi\

  Acknowledgements
  ----------------
  Thanks to Jean-loup Gailly and Mark Adler for zLib library
         and Gilles Vollant for zlibwapi.dll

  zLib library version 1.2.3
  Copyright (C) 1995-2005 Jean-loup Gailly and Mark Adler
  Informations at http://www.zlib.net (or http://www.zlib.org)

  zlibwapi.dll 18/07/2005 17:46 (73�k)
  built by Gilles Vollant

  Adaptation
  ----------
  Xavier Le Bris
  xavier.lebris@free.fr   (english or french)
  06/03/2001; 29/12/2002 for zlib.dll
  07/12/2003 for zlib1.dll
  24/01/2004 for adaptation to calling convention stdcall or cdecl
  18/10/2004 for version 1.2.2
  26/07/2005 for version 1.2.3 and some bugs fixed (Thanks to Maurizio Lotauro)

  27 Nov 2005 by Angus Robertson, Magenta Systems
  delphi@magsys.co.uk, http://www.magsys.co.uk/delphi/
  Renamed the units for use with ICS from http://www.overbyte.be


  My own work was to wrap access to dll functions in zlib.dll
  So, no copyright for this code, but don't copyright it !

  This code was tested with Borland Delphi 6. I guess it works with Delphi 2+

  This software is provided 'as-is', without any express or implied warranty.
  In no event will the author be held liable for any damages arising from the use of this software.

  This code is free under the same terms and conditions as 'zlib.'

  Note
  ----
  I use Gilles's dll because his implementation with assembler is faster than the official zlib1.dll
  So, in this implementation, the calling convention is stdcall (zlib1.dll uses cdecl)
  I rename it zlib.dll
  This unit can manage the both implementations (zlib.dll and zlib1.dll).
  See xZlib.inc for parameters.
}

unit IcsZLibDll;

{$A-} {no 32 bits alignment for records}

interface
uses Windows;

{$I IcsZlib.inc}

{xlb constants and variables}
const
   Z_DLL_NOT_FOUND               = -97;
   Z_UNKNOWN_COMPRESSION_VERSION = -98;
   Z_CHECK_PROBLEM               = -99;

var
   ZLibDllDirectory  : string;
   ZLibDllActualName : string;
   zlibDllLoaded     : boolean;
   zlibDllStartAt    : double;
   zlibProblemAlert  : boolean;
   zlibProblemString : string;
   zlibRaiseError    : boolean;
   ZLibWinapi        : boolean;

{zLib constants}
const
   ZLIB_VERSION    = '1.2.3';

   { Allowed flush values; see deflate() below for details }
   Z_NO_FLUSH      = 0;
   Z_PARTIAL_FLUSH = 1;
   Z_SYNC_FLUSH    = 2;
   Z_FULL_FLUSH    = 3;
   Z_FINISH        = 4;
   Z_BLOCK         = 5;

   Z_OK            = 0;
   Z_STREAM_END    = 1;
   Z_NEED_DICT     = 2;
   Z_ERRNO         = -1;
   Z_STREAM_ERROR  = -2;
   Z_DATA_ERROR    = -3;
   Z_MEM_ERROR     = -4;
   Z_BUF_ERROR     = -5;
   Z_VERSION_ERROR = -6;

   { compression levels }
   Z_NO_COMPRESSION         = 0;
   Z_BEST_SPEED             = 1;
   Z_BEST_COMPRESSION       = 9;
   Z_DEFAULT_COMPRESSION    = -1;

   { compression strategy; see deflateInit2() below for details }
   Z_FILTERED            = 1;
   Z_HUFFMAN_ONLY        = 2;
   Z_RLE                 = 3;
   Z_DEFAULT_STRATEGY    = 0;
   Z_MAX_STRATEGY        = 3;

   { Possible values of the data_type field }
   Z_BINARY   = 0;
   Z_ASCII    = 1;
   Z_UNKNOWN  = 2;

   { The deflate compression method (the only one supported in this version) }
   Z_DEFLATED = 8;

   Z_NULL  = nil;  { for initializing zalloc, zfree, opaque }

{other constants}
   Z_BUFSIZE = 16384;

   MAX_WBITS     = 15; { 32K LZ77 window }
   MAX_MEM_LEVEL = 9;
   DEF_MEM_LEVEL = 8;  { if MAX_MEM_LEVEL > 8 }

{zLib types}
type
   tZLibCompressionStrategy = (ctStandard, ctFiltered, ctHuffmanOnly, ctRle);
   tZLibFlag = (zfuInt, zfuLong, zfvoidpf, zfz_off_t, zfdebug, zfasm, zfwinapi, zfbuildfixed, zfdynamic_crc_table, zfno_gzcompress, zfno_gzip, zfpkzip_bug, zffastest);

   {for Dll calls}
   tAlloc = function (AppData : Pointer; Items, Size : longint) : pointer; cdecl;
   tFree = procedure (AppData, Block : pointer); cdecl;

   internal_state  = record end;
   pinternal_state = ^internal_state;

   z_streamp = ^z_stream;
   z_stream = record
      next_in     : pointer;           // next input byte
      avail_in    : longint;           // number of bytes available at next_in
      total_in    : longint;           // total nb of input bytes read so far

      next_out    : pointer;           // next output byte should be put there
      avail_out   : longint;           // remaining free space at next_out
      total_out   : longint;           // total nb of bytes output so far

      msg         : pChar;             // last error message, NULL if no error
      state       : pinternal_state;   // not visible by applications

      zalloc      : tAlloc;            // used to allocate the internal state
      zfree       : tFree;             // used to free the internal state
      AppData     : pointer;           // private data object passed to zalloc and zfree

      data_type   : longint;           // best guess about the data type: ascii or binary
      adler       : longword;          // adler32 value of the uncompressed data
      reserved    : longint;           // reserved for future use
   end;

   pZStreamRec = ^tZStreamRec;
   tZStreamRec = z_stream;

   gz_stream = record
      stream      : z_stream;
      z_err       : longint;           // error code for last stream operation
      z_eof       : longint;           // set if end of input file
      gzfile      : pointer;           // .gz file
      inbuf       : pointer;           // input buffer
      outbuf      : pointer;           // output buffer
      crc         : longword;          // crc32 of uncompressed data
      msg         : pChar;             // error message
      path        : pChar;             // path name for debugging only
      transparent : longint;           // 1 if input file is not a .gz file
      mode        : char;              // 'w' or 'r'
      start       : longint;           // start of compressed data in file (header skipped)
      into        : longint;           // bytes into deflate or inflate
      outof       : longint;           // bytes out of deflate or inflate
      back        : longint;           // one character push-back
      last        : longint;           // true if push-back is last character
   end;

   pGzStreamRec = ^tGzStreamRec;
   tGzStreamRec = gz_stream;
   tGzFile      = pGzStreamRec;

{zLib functions}
function zlibVersionDll                : string;
function zlibCompileFlags              : longword;
function crc32                         (crc : longword; const buf : pByte; len : longword): longword;

function deflateInit                   (var strm : TZStreamRec; level : longint): longint;
function deflateInit_                  (var strm : TZStreamRec; level : longint; version : string; stream_size : longint): longint;
function deflateInit2                  (var strm : TZStreamRec; level, method, windowBits, memLevel, strategy : longint) : longint;
function deflateInit2_                 (var strm : TZStreamRec; level, method, windowBits, memLevel, strategy : longint; version : string; stream_size : longint): longint;
function deflateParams                 (var strm : TZStreamRec; level, strategy: longint): longint;
function deflateBound                  (var strm : TZStreamRec; sourceLen : longword): longword;
function deflate                       (var strm : TZStreamRec; flush : longint) : longint;
function deflateEnd                    (var strm : TZStreamRec) : longint;

function inflateInit                   (var strm : TZStreamRec) : longint;
function inflateInit_                  (var strm : TZStreamRec; version : string; stream_size : longint) : longint;
function inflateInit2                  (var strm : TZStreamRec; windowBits : longint): longint;
function inflateInit2_                 (var strm : TZStreamRec; windowBits : longint; version : string; stream_size : longint) : longint;
function inflate                       (var strm : TZStreamRec; flush : longint) : longint;
function inflateEnd                    (var strm : TZStreamRec) : longint;
function inflateReset                  (var strm : TZStreamRec) : longint;

{gzip functions}
function gzOpen                        (path : string; mode : string) : tGzFile;
function gzSetParams                   (gzFile : tGzFile; level, strategy : longint) : longint;
function gzRead                        (gzFile : tGzFile; out buf; len : longword): longint;
function gzWrite                       (gzFile : tGzFile; const buf; len : longword): longint;
function gzClose                       (gzFile : tGzFile) : longint;

{added functions}
function  ZLibCheck                    (Code : longint) : longint;
procedure ZLibError;
function  ZLibFlagsString              (ZLibFlag : tZLibFlag) : string;
procedure ZLibSetDeflateStateItem      (strm : TZStreamRec; Index : integer; Value : integer);
function  ZLibGetDeflateStateItem      (strm : TZStreamRec; Index : integer) : integer;

{dll functions}
procedure ZLibLoadDll                  (AZLibDllName : string);
procedure ZLibUnLoadDll;

var
    Z_DS_MaxChainLen : integer;
    Z_DS_LazyMatch   : integer;
    Z_DS_GoodMatch   : integer;
    Z_DS_NiceMatch   : integer;

{==============================================================================}
implementation

uses SysUtils;

const
   {return code messages}

   ZLibErrMsg  : array[-6..2] of pChar = (
     'incompatible version', // Z_VERSION_ERROR  (-6)
     'buffer error',         // Z_BUF_ERROR      (-5)
     'insufficient memory',  // Z_MEM_ERROR      (-4)
     'data error',           // Z_DATA_ERROR     (-3)
     'stream error',         // Z_STREAM_ERROR   (-2)
     'file error',           // Z_ERRNO          (-1)
     '',                     // Z_OK             (0)
     'stream end',           // Z_STREAM_END     (1)
     'need dictionary'       // Z_NEED_DICT      (2)
   );

   SZLibInvalid = 'Invalid ZStream operation!';

type
   EZLibCheckError = class(Exception);

var
   zlibVersionDll_stdcall   : function         : pChar; stdcall;        {for both stdcall and cdecl because no argument}
   zlibCompileFlags_stdcall : function         : longword; stdcall;

   {stdcall}
   crc32_stdcall            : function         (crc : longword; const buf : pByte; len : longword): longword; stdcall;

   deflateInit_stdcall      : function         (var strm : TZStreamRec; level : longint; version : PChar; stream_size : longint) : longint; stdcall;
   deflateInit2_stdcall     : function         (var strm : TZStreamRec; level, method, windowBits, memLevel, strategy : longint; const version : PChar; stream_size : longint): longint; stdcall;
   deflate_stdcall          : function         (var strm : TZStreamRec; flush : longint) : longint; stdcall;
   deflateEnd_stdcall       : function         (var strm : TZStreamRec) : longint; stdcall;

   inflateInit_stdcall      : function         (var strm : TZStreamRec; version : PChar; stream_size : longint) : longint; stdcall;
   inflateInit2_stdcall     : function         (var strm : TZStreamRec; windowBits : longint; const version : PChar; stream_size : longint) : longint; stdcall;
   inflate_stdcall          : function         (var strm : TZStreamRec; flush : longint) : longint; stdcall;
   inflateEnd_stdcall       : function         (var strm : TZStreamRec) : longint; stdcall;

   inflateReset_stdcall     : function         (var strm : TZStreamRec) : longint; stdcall;
   deflateParams_stdcall    : function         (var strm : TZStreamRec; level, strategy: longint): longint; stdcall;
   deflateBound_stdcall     : function         (var strm : TZStreamRec; sourceLen : longword): longword;stdcall;

   {gzip functions}
   gzOpen_stdcall           : function         (const path : pChar; const mode : pChar) : tGzFile; stdcall;
   gzSetParams_stdcall      : function         (gzFile : tGzFile; level, strategy : longint) : longint; stdcall;
   gzRead_stdcall           : function         (gzFile : tGzFile; out buf; len : longword): longint; stdcall;
   gzWrite_stdcall          : function         (gzFile : tGzFile; const buf; len : longword): longint; stdcall;
   gzClose_stdcall          : function         (gzFile : tGzFile) : longint; stdcall;

   {cdecl}
   crc32_cdecl              : function         (crc : longword; const buf : pByte; len : longword): longword; cdecl;

   deflateInit_cdecl        : function         (var strm : TZStreamRec; level : longint; version : PChar; stream_size : longint) : longint; cdecl;
   deflateInit2_cdecl       : function         (var strm : TZStreamRec; level, method, windowBits, memLevel, strategy : longint; const version : PChar; stream_size : longint): longint; cdecl;
   deflate_cdecl            : function         (var strm : TZStreamRec; flush : longint) : longint; cdecl;
   deflateEnd_cdecl         : function         (var strm : TZStreamRec) : longint; cdecl;

   inflateInit_cdecl        : function         (var strm : TZStreamRec; version : PChar; stream_size : longint) : longint; cdecl;
   inflateInit2_cdecl       : function         (var strm : TZStreamRec; windowBits : longint; const version : PChar; stream_size : longint) : longint; cdecl;
   inflate_cdecl            : function         (var strm : TZStreamRec; flush : longint) : longint; cdecl;
   inflateEnd_cdecl         : function         (var strm : TZStreamRec) : longint; cdecl;

   inflateReset_cdecl       : function         (var strm : TZStreamRec) : longint; cdecl;
   deflateParams_cdecl      : function         (var strm : TZStreamRec; level, strategy: longint): longint; cdecl;
   deflateBound_cdecl       : function         (var strm : TZStreamRec; sourceLen : longword): longword;cdecl;

   {gzip functions}
   gzOpen_cdecl             : function         (const path : pChar; const mode : pChar) : tGzFile; cdecl;
   gzSetParams_cdecl        : function         (gzFile : tGzFile; level, strategy : longint) : longint; cdecl;
   gzRead_cdecl             : function         (gzFile : tGzFile; out buf; len : longword): longint; cdecl;
   gzWrite_cdecl            : function         (gzFile : tGzFile; const buf; len : longword): longint; cdecl;
   gzClose_cdecl            : function         (gzFile : tGzFile) : longint; cdecl;

(*
   function adler32                       (adler: uLong; const buf: pBytef; len: uInt): uLong;
   function deflateCopy                   (dest, source: z_streamp): int;
   function deflateReset                  (strm: z_streamp): int;
   function deflateSetDictionary          (strm: z_streamp; const dictionary: pBytef; dictLength: uInt): int;
   function inflateSetDictionary          (strm: z_streamp; const dictionary: pBytef; dictLength: uInt): int;
   function inflateSync                   (strm: z_streamp): int;
*)

{==============================================================================}

function ZLibCheck(Code : longint) : longint;
begin
     Result := Code;
     if (Code < 0) and (length(zlibProblemString) = 0) then
     begin
          zlibProblemAlert := true;
          if (Code < Z_VERSION_ERROR) then
          begin
               case Code of
                  Z_DLL_NOT_FOUND               : zlibProblemString := 'Dll not found';
                  Z_UNKNOWN_COMPRESSION_VERSION : zlibProblemString := 'Unknwon compression stream version';
                  Z_CHECK_PROBLEM               : zlibProblemString := 'Check problem';
                                           else   zlibProblemString := 'Error n�' + inttostr(-Code);
               end;
          end else
               zlibProblemString := ZLibErrMsg[Code];

          if zlibRaiseError then raise EZLibCheckError.Create(zlibProblemString);
     end;
end;
{==============================================================================}

procedure ZLibError;
begin
     if (length(zlibProblemString) = 0) then
     begin
          zlibProblemAlert := true;
          zlibProblemString := SZLibInvalid;
          if zlibRaiseError then raise EZLibCheckError.Create(SZLibInvalid);
     end;
end;
{==============================================================================}

function zlibVersionDll : string;
begin
     if Assigned(@zlibVersionDll_stdcall) then Result := zlibVersionDll_stdcall else Result := '';
end;
{������������������������������������������������������������������������������}

function zlibCompileFlags : longword;
begin
     if Assigned(@zlibCompileFlags_stdcall) then Result := zlibCompileFlags_stdcall else Result := 0;
end;
{������������������������������������������������������������������������������}

{ Adaptative call to stdcall or cdecl }

function crc32(crc : longword; const buf : pByte; len : longword): longword;
begin
     if ZLibWinapi then Result := crc32_stdcall(crc, buf, len)
                   else Result := crc32_cdecl  (crc, buf, len);
end;
{������������������������������������������������������������������������������}

function deflateInit_(var strm : TZStreamRec; level : longint; version : string; stream_size : longint): longint;
begin
     if ZLibWinapi then Result := deflateInit_stdcall(strm, level, pChar(version), stream_size)
                   else Result := deflateInit_cdecl  (strm, level, pChar(version), stream_size);
end;
{������������������������������������������������������������������������������}

function deflateInit2_(var strm : TZStreamRec; level, method, windowBits, memLevel, strategy : longint; version : string; stream_size : longint): longint;
begin
     if ZLibWinapi then Result := deflateInit2_stdcall(strm, level, method, windowBits, memLevel, strategy, pChar(version), stream_size)
                   else Result := deflateInit2_cdecl  (strm, level, method, windowBits, memLevel, strategy, pChar(version), stream_size);
end;
{������������������������������������������������������������������������������}

function deflate(var strm : TZStreamRec; flush : longint): longint;
begin
     if ZLibWinapi then Result := deflate_stdcall(strm, flush)
                   else Result := deflate_cdecl  (strm, flush);
end;
{������������������������������������������������������������������������������}

function deflateEnd(var strm : TZStreamRec): longint;
begin
     if ZLibWinapi then Result := deflateEnd_stdcall(strm)
                   else Result := deflateEnd_cdecl  (strm);
end;
{������������������������������������������������������������������������������}

function inflateInit_(var strm : TZStreamRec; version : string; stream_size : longint): longint;
begin
     if ZLibWinapi then Result := inflateInit_stdcall(strm, pChar(version), stream_size)
                   else Result := inflateInit_cdecl  (strm, pChar(version), stream_size);
end;
{������������������������������������������������������������������������������}

function inflateInit2_(var strm : TZStreamRec; windowBits : longint; version : string; stream_size : longint): longint;
begin
     if ZLibWinapi then Result := inflateInit2_stdcall(strm, windowBits, pChar(version), stream_size)
                   else Result := inflateInit2_cdecl  (strm, windowBits, pChar(version), stream_size);
end;
{������������������������������������������������������������������������������}

function inflate(var strm : TZStreamRec; flush : longint): longint;
begin
     if ZLibWinapi then Result := inflate_stdcall(strm, flush)
                   else Result := inflate_cdecl  (strm, flush);
end;
{������������������������������������������������������������������������������}

function inflateEnd(var strm : TZStreamRec): longint;
begin
     if ZLibWinapi then Result := inflateEnd_stdcall(strm)
                   else Result := inflateEnd_cdecl  (strm);
end;
{������������������������������������������������������������������������������}

function inflateReset(var strm : TZStreamRec): longint;
begin
     if ZLibWinapi then Result := inflateReset_stdcall(strm)
                   else Result := inflateReset_cdecl  (strm);
end;
{������������������������������������������������������������������������������}

function deflateParams(var strm : TZStreamRec; level, strategy : longint) : longint;
begin
     if ZLibWinapi then Result := deflateParams_stdcall(strm, level, strategy)
                   else Result := deflateParams_cdecl  (strm, level, strategy);
end;
{������������������������������������������������������������������������������}

function deflateBound(var strm : TZStreamRec; sourceLen : longword): longword;
begin
     if ZLibWinapi then
     begin
          if Assigned(@deflateBound_stdcall) then Result := deflateBound_stdcall(strm, sourceLen)
                                             else Result := sourceLen + (sourceLen div 10) + 12 + 255;  {versions <= 1.1.4}
     end else
          Result := deflateBound_cdecl  (strm, sourceLen);
end;
{==============================================================================}

function deflateInit(var strm : TZStreamRec; level : longint) : longint;
begin
     Result := deflateInit_(strm, level, ZLIB_VERSION, sizeof(z_stream));
end;
{������������������������������������������������������������������������������}

function deflateInit2(var strm : TZStreamRec; level, method, windowBits, memLevel, strategy : longint) : longint;
begin
     Result := deflateInit2_(strm, level, method, windowBits, memLevel, strategy, ZLIB_VERSION, sizeof(z_stream));
end;
{������������������������������������������������������������������������������}

function inflateInit(var strm : TZStreamRec) : longint;
begin
     Result := inflateInit_(strm, ZLIB_VERSION, sizeof(z_stream));
end;
{������������������������������������������������������������������������������}

function inflateInit2(var strm : TZStreamRec; windowBits : longint): longint;
begin
     Result := inflateInit2_(strm, windowBits, ZLIB_VERSION, sizeof(z_stream));
end;
{==============================================================================}

function gzOpen (path : string; mode : string) : tGzFile;
begin
     if ZLibWinapi then Result := gzOpen_stdcall(pChar(path), pChar(mode))
                   else Result := gzOpen_cdecl(pChar(path), pChar(mode));
end;
{������������������������������������������������������������������������������}

function gzSetParams (gzFile : tGzFile; level, strategy : longint) : longint;
begin
     if ZLibWinapi then Result := gzSetParams_stdcall(gzFile, level, strategy)
                   else Result := gzSetParams_cdecl(gzFile, level, strategy);
end;
{������������������������������������������������������������������������������}

function gzRead (gzFile : tGzFile; out buf; len : longword): longint;
begin
     if ZLibWinapi then Result := gzRead_stdcall(gzFile, buf, len)
                   else Result := gzRead_cdecl(gzFile, buf, len);
end;
{������������������������������������������������������������������������������}

function gzWrite (gzFile : tGzFile; const buf; len : longword): longint;
begin
     if ZLibWinapi then Result := gzWrite_stdcall(gzFile, buf, len)
                   else Result := gzWrite_cdecl(gzFile, buf, len);
end;
{������������������������������������������������������������������������������}

function gzClose (gzFile : tGzFile) : longint;
begin
     if ZLibWinapi then Result := gzClose_stdcall(gzFile)
                   else Result := gzClose_cdecl(gzFile);
end;
{==============================================================================}

function ZLibFlagsString(ZLibFlag : tZLibFlag) : string;
var  Flags : longword;

     function FlagSize(L : longword) : string;
     var  N : longword;
     begin
          N := (Flags shr L) and $0003;
          case N of
             0 : Result := '16';            {uInt}
             1 : Result := '32';            {uLong}
             2 : Result := '64';            {voidpf}
             3 : Result := '0';             {z_off_t}
          end;
     end;

     function FlagBit(L : longword) : boolean;
     begin
          Result := (((Flags shr L) and $0001) = 1);
     end;
begin
     Result := '';
     if not ZLibDllLoaded or not Assigned(@zlibCompileFlags_stdcall) then exit;
     Flags := zlibCompileFlags;
     case  ZLibFlag of
        zfuInt               : Result := 'uInt : ' + FlagSize(0);
        zfuLong              : Result := 'uLong : ' + FlagSize(2);
        zfvoidpf             : Result := 'voidpf : ' + FlagSize(4);
        zfz_off_t            : Result := 'z_off_t : ' + FlagSize(6);
        zfdebug              : if FlagBit(8)  then Result := 'debug';
        zfasm                : if FlagBit(9)  then Result := 'asm' else Result := 'noasm';
        zfwinapi             : if FlagBit(10) then Result := 'stdcall' else Result := 'cdecl';
        zfbuildfixed         : if FlagBit(12) then Result := 'buildfixed';
        zfdynamic_crc_table  : if FlagBit(13) then Result := 'dynamic_crc_table';
        zfno_gzcompress      : if FlagBit(16) then Result := 'no_gzcompress';
        zfno_gzip            : if FlagBit(17) then Result := 'no_gzip';
        zfpkzip_bug          : if FlagBit(20) then Result := 'pkzip_bug';
        zffastest            : if FlagBit(21) then Result := 'fastest';
     end;
end;
{==============================================================================}
{ for XLB purposes only : access to internal zlib variables : only for versions 1.1.4 and 1.2.x; must be updated in future versions }

const
     Z_DS_MaxItemsMax = 34;
var
     Z_DS_MaxItems    : integer;

type pDeflateState = ^tDeflateState;
     tDeflateState = array[0..Z_DS_MaxItemsMax] of longint;
{������������������������������������������������������������������������������}
(*   dans match.s
     WSize 36 WMask 44 Window 48 Prev 56 MatchLen 88 PrevMatch 92 StrStart 100 MatchStart 104 Lookahead 108 PrevLen 112
     MaxChainLen 116 GoodMatch 132 NiceMatch 136 *)

procedure ZLibDeflateStateInit;
var  V : string;
begin
     Z_DS_MaxItems    := 0;
     Z_DS_MaxChainLen := 0;
     Z_DS_LazyMatch   := 0;
     Z_DS_GoodMatch   := 0;
     Z_DS_NiceMatch   := 0;

     if ZLibDllLoaded then V := zlibVersionDll else exit;
     if (V = '1.1.4') or (copy(V,1,3) = '1.2') then
     begin
          Z_DS_MaxItems    := Z_DS_MaxItemsMax;  {34}
          Z_DS_MaxChainLen := 29; {116 / 4}
          Z_DS_LazyMatch   := 30;
          Z_DS_GoodMatch   := 33; {132 / 4}
          Z_DS_NiceMatch   := 34; {136 / 4}
     end;
end;
{������������������������������������������������������������������������������}

procedure ZLibSetDeflateStateItem(strm : TZStreamRec; Index : integer; Value : integer);
var  PtrDS : pDeflateState;
     V : string;
begin
     if ZLibDllLoaded then V := zlibVersionDll else exit;
     if (Z_DS_MaxItems > 0) and (V = '1.1.4') or (copy(V,1,3) = '1.2') then
     begin
          PtrDS := pDeflateState(strm.state);
          if (PtrDS <> nil) and (Index in [0..Z_DS_MaxItems]) then PtrDS^[Index] := Value;
     end;
end;
{������������������������������������������������������������������������������}

function ZLibGetDeflateStateItem(strm : TZStreamRec; Index : integer) : integer;
var  PtrDS : pDeflateState;
     V : string;
begin
     Result := 0;
     if ZLibDllLoaded then V := zlibVersionDll else exit;
     if (Z_DS_MaxItems > 0) and (V = '1.1.4') or (copy(V,1,3) = '1.2') then
     begin
          PtrDS := pDeflateState(strm.state);
          if (PtrDS <> nil) and (Index in [0..Z_DS_MaxItems]) then Result := PtrDS^[Index];
     end;
end;
{==============================================================================}
{ Interface of the dll : this code comes from zlib.pas with minor adaptations  }
{==============================================================================}

type
    TBuffer = array[0..511] of char;

var ZLibDLLHandle : HModule;

{������������������������������������������������������������������������������}

procedure ZLibUnLoadDll;
begin
     FreeLibrary(ZLibDLLHandle);
     ZLibDLLHandle := 0;
     ZLibDllLoaded := false;
     zlibVersionDll_stdcall := nil;
     ZLibDllDirectory := '';
     ZLibWinapi := false;
     ZLibDeflateStateInit;
end;
{������������������������������������������������������������������������������}

procedure ZLibLoadDll(AZLibDllName : string);
var  Buffer : TBuffer;
begin
     if (ZLibDLLHandle > 0) then ZLibUnLoadDll;

     ZLibDllActualName := AZLibDllName;
     SetErrorMode($8000 {SEM_NoOpenFileErrorBox});

     ZLibDLLHandle := LoadLibrary(pChar(ZLibDllActualName));
     if (ZLibDLLHandle = 0) then
     begin
          ZLibDLLHandle := LoadLibrary(pChar(ZLibDllNameBis));
          if (ZLibDLLHandle > 0) then ZLibDllActualName := ZLibDllNameBis;
     end;
     if (ZLibDLLHandle = 0) then
     begin
          ZLibDLLHandle := LoadLibrary(pChar(ZLibDllNameTer));
          if (ZLibDLLHandle > 0) then ZLibDllActualName := ZLibDllNameTer;
     end;

     if (ZLibDLLHandle > 0) then
     begin
          @zlibVersionDll_stdcall          := GetProcAddress(ZLibDLLHandle,'zlibVersion');
          ZLibDllLoaded                    := Assigned(@zlibVersionDll_stdcall);
          if not ZLibDllLoaded then exit;

          @zlibCompileFlags_stdcall        := GetProcAddress(ZLibDLLHandle,'zlibCompileFlags');   {for 1.2.1 and more}
          if Assigned(@zlibCompileFlags_stdcall) then ZLibWinapi := (ZLibFlagsString(zfwinapi) = 'stdcall')
                                                 else ZLibWinapi := true;                         {before 1.2.1}

          if ZLibWinapi then
          begin
             @crc32_stdcall                := GetProcAddress(ZLibDLLHandle,'crc32');
             @deflateParams_stdcall        := GetProcAddress(ZLibDLLHandle,'deflateParams');
             @deflateBound_stdcall         := GetProcAddress(ZLibDLLHandle,'deflateBound');
             @deflateInit_stdcall          := GetProcAddress(ZLibDLLHandle,'deflateInit_');
             @deflateInit2_stdcall         := GetProcAddress(ZLibDLLHandle,'deflateInit2_');
             @deflate_stdcall              := GetProcAddress(ZLibDLLHandle,'deflate');
             @deflateEnd_stdcall           := GetProcAddress(ZLibDLLHandle,'deflateEnd');

             @inflateReset_stdcall         := GetProcAddress(ZLibDLLHandle,'inflateReset');
             @inflateInit_stdcall          := GetProcAddress(ZLibDLLHandle,'inflateInit_');
             @inflateInit2_stdcall         := GetProcAddress(ZLibDLLHandle,'inflateInit2_');
             @inflate_stdcall              := GetProcAddress(ZLibDLLHandle,'inflate');
             @inflateEnd_stdcall           := GetProcAddress(ZLibDLLHandle,'inflateEnd');

             @gzOpen_stdcall               := GetProcAddress(ZLibDLLHandle,'gzopen');
             @gzRead_stdcall               := GetProcAddress(ZLibDLLHandle,'gzread');
             @gzWrite_stdcall              := GetProcAddress(ZLibDLLHandle,'gzwrite');
             @gzClose_stdcall              := GetProcAddress(ZLibDLLHandle,'gzclose');
          end else
          begin
             @crc32_cdecl                  := GetProcAddress(ZLibDLLHandle,'crc32');
             @deflateParams_cdecl          := GetProcAddress(ZLibDLLHandle,'deflateParams');
             @deflateBound_cdecl           := GetProcAddress(ZLibDLLHandle,'deflateBound');
             @deflateInit_cdecl            := GetProcAddress(ZLibDLLHandle,'deflateInit_');
             @deflateInit2_cdecl           := GetProcAddress(ZLibDLLHandle,'deflateInit2_');
             @deflate_cdecl                := GetProcAddress(ZLibDLLHandle,'deflate');
             @deflateEnd_cdecl             := GetProcAddress(ZLibDLLHandle,'deflateEnd');

             @inflateReset_cdecl           := GetProcAddress(ZLibDLLHandle,'inflateReset');
             @inflateInit_cdecl            := GetProcAddress(ZLibDLLHandle,'inflateInit_');
             @inflateInit2_cdecl           := GetProcAddress(ZLibDLLHandle,'inflateInit2_');
             @inflate_cdecl                := GetProcAddress(ZLibDLLHandle,'inflate');
             @inflateEnd_cdecl             := GetProcAddress(ZLibDLLHandle,'inflateEnd');

             @gzOpen_cdecl                 := GetProcAddress(ZLibDLLHandle,'gzopen');
             @gzRead_cdecl                 := GetProcAddress(ZLibDLLHandle,'gzread');
             @gzWrite_cdecl                := GetProcAddress(ZLibDLLHandle,'gzwrite');
             @gzClose_cdecl                := GetProcAddress(ZLibDLLHandle,'gzclose');
          end;
(*
             @deflateSetDictionary := GetProcAddress(ZLibDLLHandle,'deflateSetDictionary');
             @deflateCopy          := GetProcAddress(ZLibDLLHandle,'deflateCopy');
             @deflateReset         := GetProcAddress(ZLibDLLHandle,'deflateReset');

             @inflateSetDictionary := GetProcAddress(ZLibDLLHandle,'inflateSetDictionary');
             @inflateSync          := GetProcAddress(ZLibDLLHandle,'inflateSync');

             @compress             := GetProcAddress(ZLibDLLHandle,'compress');
             @uncompress           := GetProcAddress(ZLibDLLHandle,'uncompress');

             @gzdopen              := GetProcAddress(ZLibDLLHandle,'gzdopen');
             @gzerror              := GetProcAddress(ZLibDLLHandle,'gzerror');

             @adler32              := GetProcAddress(ZLibDLLHandle, 'adler32');
*)
             zlibDllStartAt := Now;

             GetModuleFileName(ZLibDLLHandle, Buffer, SizeOf(Buffer));
             ZLibDllDirectory := ExtractFilePath(string(Buffer));
     end else
     begin
          ZLibDllLoaded := false;
          ZLibWinapi := false;
          ZLibDllDirectory := '';
     end;
     ZLibDeflateStateInit;
end;
{==============================================================================}

initialization
   ZLibDllDirectory := '';
   ZLibDllActualName := '';
   zlibDllLoaded := false;
   zlibDllStartAt := 0;
   zlibProblemAlert := false;
   zlibProblemString := '';
   zlibRaiseError := true;
   ZLibDLLHandle := 0;
   ZLibWinapi := false;
   ZLibDeflateStateInit;
   ZLibLoadDll(ZLibDllName);

finalization
   ZLibUnLoadDll;
{==============================================================================}
end.
