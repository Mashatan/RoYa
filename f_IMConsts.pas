{
   File: f_IMConsts

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
unit f_IMConsts;

interface
uses Forms,SysUtils,Classes,f_RoYaDefines;
Const
  coSizeShareMemory=1024;
  coRoYa='RoYa';
  coRoYaIniFile=coRoYa+'.ini';
  coRoYaDB=coRoYa+'DB';
  coRoYaDBFile=coRoYaDB+'.db';
  coTableUsersDB='Users';
  coTableAccountsDB='Accounts';
  coTableConfigurationsDB='Configurations';
  coPathDatabase='data\';
  coPathAIStartupXml='startup.xml';
  coPathLogs='Logs\';
  coSQLiteDLL='SQLite3.dll';

  coRoYaService='RoYaService';

  coSwitchService='service';
  coImagePath='ImagePath';

  coKeyCrypto         = '85EDBD25-9462-4C31-B682-0B01529F95FB';
  coSingleExec        = '2B4BDE72-5D66-4886-86E5-EE36E4F56AAC';
  coKeyShare          = 'C3850C3D-8114-48F2-94FC-577B06E914F1';

  coKeyRegService='SYSTEM\CurrentControlSet\Services\';

  coWatcherGUID       = 'F157D073-E043-4218-AF44-5289B64DD844';

  coFirstSession=        'firstsession';//FirstSession
  coLastSession=         'lastsession'; //LastSession
  coFirstEnter=          'firstenter'; //FirstEnter
  coLastDuration=        'lastduration'; //LastDuration

  coTotalBlockMessageNo= 'totalblockmessageno'; //TotalBlockMessageNo
  coTotalMessageNo=      'totalmessageno'; //TotalMessageNo
  coLastMessageNo=       'lastmessageno'; //LastMessageNo
  coTotalDuration=       'totalduration'; //TotalDuration
  coProviderType=        'providertype';
  coProvider=            'provider';
  coAliceInfo=           'aliceinfo'; //AliceInfo
  coRoYaInfo=            'royainfo'; //RoYaInfo

  coAccountID=            'accountid'; //AccountID
  coRobotID=              'Robotid'; //RobotID
  coPassword=             'password';
  coStatus=               'status';
  coHost=                 'host';
  coPort=                 'port';
  coOwner=                'owner';
  coInvisiable=           'invisiable';
  coHTTPProxy=            'httpproxy'; //HTTPProxy
  coHTTPProxyHost=        'httpproxyhost'; //HTTPProxyHost
  coHTTPProxyPort=        'httpproxyport'; //HTTPProxyPort
  coRank=                 'rank';
  coUsername=             'username';
  coLevel=                'level';
  coValue=                'value';
  coName=                 'name';

  coUserTimerInterval=      'UserTimerInterval';
  coTimeoutIdle=            'TimeoutIdle';
  coTimeoutConnection=      'TimeoutConnection';
  coTimeoutFlush=           'TimeoutFlush';
  coDelayMsg=               'DelayMsg';
  coDelayCpu=               'DelayCpu';
  coLimitCPU=               'LimitCPU';
  coLimitMsg=               'LimitMsg';
  coRestrictionMsg=         'RestrictionMsg';
  coAIntervalRecMsg=        'AIntervalRecMsg';
  coMIntervalRecMsg=        'MIntervalRecMsg';
  coRunMode=                'RunMode';

  coCollectionSQLSelect:String='Select'+
    ' Accounts.AccountID,'+
    ' Accounts.Active,'+
    ' Accounts.RobotID,'+
    ' Accounts.Password,'+
    ' Accounts.Owner,'+
    ' Accounts.Status,'+
    ' Accounts.TotalBlockMessageNo,'+
    ' Accounts.TotalMessageNo,'+
    ' Accounts.TotalDuration,'+
    ' Accounts.Invisiable,'+
//    ' Providers.ProviderID,'+
    ' Providers.Name,'+
    ' Providers.ProviderType,'+
    ' Providers.Host,'+
    ' Providers.Port,'+
    ' Providers.HttpProxy,'+
    ' Providers.HttpProxyHost,'+
    ' Providers.HttpProxyPort,'+
    ' Providers.SocksProxy,'+
    ' Providers.SocksProxyHost,'+
    ' Providers.SocksProxyPort,'+
    ' Providers.SocksProxyVer,'+
    ' Providers.SocksProxyAuth,'+
    ' Providers.SocksProxyUsername,'+
    ' Providers.SocksProxyPassword'+
    ' from '+coTableAccountsDB+' INNER JOIN Providers ON Accounts.ProviderID = Providers.ProviderID'+
    ' where Active=''true''';
  coStoreRetrieveInfoSQLUpdate:String='update '+coTableAccountsDB+' SET TotalBlockMessageNo=:totalblockmessageno,TotalMessageNo=:totalmessageno,TotalDuration=:totalduration'+
    ' Where AccountID=:accountid';

  coGeneralInfoSQLSelect:String='Select * from '+coTableConfigurationsDB+' where name=:name';
  coGeneralInfoSQLInsert:String='insert into '+coTableConfigurationsDB+' (Name,Value) Values(:name , :value )';
  coGeneralInfoSQLUpdate:String='Update '+coTableConfigurationsDB+' Set Value=:value where name=:name';

  coBroadCastSQLSelect:String='select * from '+coTableUsersDB;
  coWatcherSQLSelect:String='select * from '+coTableUsersDB+' where username=:username and provider = :provider';
  coWatcherSQLUpdate:String='update '+coTableUsersDB+' SET Level=:level,FirstSession=:firstsession,LastSession=:lastsession,TotalDuration=:totalduration,'+
        ' LastDuration=:lastduration ,TotalBlockMessageNo=:totalblockmessageno ,TotalMessageNo=:totalmessageno , LastMessageNo=:lastmessageno ,AliceInfo=:aliceinfo,RoYaInfo=:royainfo,Rank=:rank'+
        ' Where username=:username AND  provider=:provider';
  coWatcherSQLInsert:String='insert into '+coTableUsersDB+' (username,Level,Provider,FirstEnter,FirstSession,LastSession,TotalDuration,LastDuration,TotalBlockMessageNo,TotalMessageNo , LastMessageNo,AliceInfo,RoYaInfo,Rank)'+
       ' VALUES (:username, :level, :provider, :firstenter, :firstsession, :lastsession, :totalduration, :lastduration,:totalblockmessageno, :totalmessageno , :lastmessageno,  :aliceinfo , :royainfo, :rank)';
  coWhenStartForOwner='RoYa Started';


  MILLSECOND=1000;
  SHARESTARTPOINT=10;

  CMD_ABOUT='/about';
  CMD_UPTIME='/uptime';
  CMD_BROADCAST='/broadcast';
  CMD_SUSPEND='/suspend';
  CMD_RESUME='/resume';
  CMD_RESTART='/restart';
  CMD_SEND='/send';
  CMD_STATUS='/status';
  CMD_DATE='/date';
  CMD_TIME='/time';
  CMD_WEBSERVICE='/service';
  CMD_SOLAR_GREGORIAN='sg';
  CMD_GREGORIAN_SOLAR='gs';
  CMD_PLUGIN='/plugin';
  CMD_PLUGIN_INIT='init';
  CMD_PLUGIN_FINAL='final';
  MSG_OWNER='<OWNER RoYa> ';


  ROYA_STATUS=          $1000;
  ROYA_NONE=            ROYA_STATUS+1;
  ROYA_START=           ROYA_STATUS+2;
  ROYA_STOP=            ROYA_STATUS+3;
  ROYA_CONNECT=         ROYA_STATUS+4;
  ROYA_DISCONNECT=      ROYA_STATUS+5;
  ROYA_VERIFIED=        ROYA_STATUS+6;
  ROYA_AUTHENTICATION=  ROYA_STATUS+7;
  ROYA_WELCOM=          ROYA_STATUS+8;
  ROYA_NEWCONTACT=      ROYA_STATUS+9;
  ROYA_IDLE=            ROYA_STATUS+10;
  ROYA_Flush=           ROYA_STATUS+11;
  ROYA_PING=            ROYA_STATUS+12;
  ROYA_ERROR=           ROYA_STATUS+13;

  YAHOO_STATUS_AVAILABLE    = 0;
  YAHOO_STATUS_BRB          = 5;
  YAHOO_STATUS_BUSY         = 5;
  YAHOO_STATUS_NOTATHOME    = 5;
  YAHOO_STATUS_NOTATDESK    = 5;
  YAHOO_STATUS_NOTINOFFICE  = 5;
  YAHOO_STATUS_ONPHONE      = 9;
  YAHOO_STATUS_ONVACATION   = 9;
  YAHOO_STATUS_OUTTOLUNCH   = 9;
  YAHOO_STATUS_STEPPEDOUT   = 9;
  YAHOO_STATUS_INVISIBLE    = 12;
  YAHOO_STATUS_CUSTOM       = 99;
  YAHOO_STATUS_IDLE         = 999;
  YAHOO_STATUS_OFFLINE      = $5a55aa56;
  YAHOO_STATUS_TYPING       = $16;

  YAHOO_SERVICE_LOGON            = $01;
  YAHOO_SERVICE_LOGOFF           = $02;
  YAHOO_SERVICE_ISAWAY           = $03;
  YAHOO_SERVICE_ISBACK           = $04;
  YAHOO_SERVICE_IDLE             = $05;
  YAHOO_SERVICE_MESSAGE          = $06;
  YAHOO_SERVICE_IDACT            = $07;
  YAHOO_SERVICE_IDDEACT          = $08;
  YAHOO_SERVICE_MAILSTAT         = $09;
  YAHOO_SERVICE_USERSTAT         = $0a;
  YAHOO_SERVICE_NEWMAIL          = $0b;
  YAHOO_SERVICE_CHATINVITE       = $0c;
  YAHOO_SERVICE_CALENDAR         = $0d;
  YAHOO_SERVICE_NEWPERSONALMAIL  = $0e;
  YAHOO_SERVICE_NEWCONTACT       = $0f;
  YAHOO_SERVICE_ADDIDENT         = $10;
  YAHOO_SERVICE_ADDIGNORE        = $11;
  YAHOO_SERVICE_PING             = $12;
  YAHOO_SERVICE_GROUPRENAME      = $13;
  YAHOO_SERVICE_SYSMESSAGE       = $14;
  YAHOO_SERVICE_PASSTHROUGH2     = $16;
  YAHOO_SERVICE_CONFINVITE       = $18;
  YAHOO_SERVICE_CONFLOGON        = $19;
  YAHOO_SERVICE_CONFDECLINE      = $1a;
  YAHOO_SERVICE_CONFLOGOFF       = $1b;
  YAHOO_SERVICE_CONFADDINVITE    = $1c;
  YAHOO_SERVICE_CONFMSG          = $1d;
  YAHOO_SERVICE_CHATLOGON        = $1e;
  YAHOO_SERVICE_CHATLOGOFF       = $1f;
  YAHOO_SERVICE_CHATMSG          = $20;
  YAHOO_SERVICE_GAMELOGON        = $28;
  YAHOO_SERVICE_GAMELOGOFF       = $29;
  YAHOO_SERVICE_GAMEMSG          = $2a;
  YAHOO_SERVICE_FILETRANSFER     = $46;
  YAHOO_SERVICE_VOICECHAT        = $4a;
  YAHOO_SERVICE_NOTIFY           = $4b;
  YAHOO_SERVICE_P2PFILEXFER      = $4d;
  YAHOO_SERVICE_PEERTOPEER       = $4f;
  YAHOO_SERVICE_AUTHRESP         = $54;
  YAHOO_SERVICE_LIST             = $55;
  YAHOO_SERVICE_AUTH             = $57;
  YAHOO_SERVICE_ADDBUDDY         = $83;
  YAHOO_SERVICE_REMBUDDY         = $84;
  YAHOO_SERVICE_IGNORECONTACT    = $85;
  YAHOO_SERVICE_REJECTCONTACT    = $86;
  YAHOO_SERVICE_VERIFY           = $4c;
  YAHOO_SERVICE_CHECKUSER        = $C0;
  YAHOO_SERVICE_NEWFRIENDALERT     = $D6;

  YAHOO_CO80S=  #$c0+#$80;

  YAHOO_MINIMUMPACKETSIZE =18;
  YAHOO_STARTPACKET=1;
  YAHOO_SIGNATURE ='YMSG';
  YAHOO_VERSION = $000F;
  CrLf=  #$0d+#$0a;
type

  TYahooPacketHeader=record
    case boolean of
      True : (
      YMSG:array[1..4] of Char;
      Version:WORD;
      Reserve :array[1..2] of Char;
      Length : Word;
      Serivce:Word;
      Status:array[1..4] of Char;
      SessionID:array[1..4] of Char;);
      false: (
        data:array[1..20] of char;
      );
  end;

  TModeKind = (mkApplication=1, mkService=2);
  TDateKind = (dkSolar, dkGregorian);
  TVerSOCKSKind=(Ver4,Ver5);
  TRestrictionKind=(irNone=0,irAutomatic=1,irManual=2);
  TTransportKind = (trInner,trOuter);
  TStageKind=(saReady,saLogout,saVerify,saLoggingIn,saAuthentication);

  TPluginStatus=(psReady,psNotReady);
  TChangeStatus=(csIdle,csBusy);
  TLogStatus=(lsInformation,lsError,lsDebug,lsWarning);
  TAccountStatus=(asNone=0, asConnected=1,asConnecting=2,asVerifed=3, asAuthuntication=4,asLogin=5 ,asSuspend=6,asDisconnected=7);

  TCustomMonitorLogEvent = procedure(Sender: TObject; Msg: String;Status:Word) of object;
var
  CureentApp,CurrentPath:String;
implementation


initialization
  CurrentPath:=ExtractFilePath(Application.ExeName);
  CureentApp:=Application.ExeName;
end.
