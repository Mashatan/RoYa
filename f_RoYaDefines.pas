{
   File: f_RoYaDefines

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
unit f_RoYaDefines;
interface
  uses Windows,Classes;
{
  <Font face="namefont">  </Font>
  <FADE #ff0000,#00ff00,#0000ff> </FADE>

  Mode      Enabled     Disable

  Bold      #27[1m      #27[x1m 
  Italic    #27[2m      #27[x2m
  ?         #27[3m      #27[x3m
  Underline #27[4m      #27[x4m
================================
  Color     Code

  Black     #27[30m
  Blue      #27[31m
  Olive     #27[32m
  Silver    #27[33m
  Green     #27[34m
  Pink      #27[35m   
  Maroon    #27[36m
  Orange    #27[37m
  Red       #27[38m
  Green     #27[39m
}
Const
  Aviabale=         '#ava';   // Aviable
  BeRightBack=      '#brb';   // Be Right Back
  Busy=             '#bsy';   // Busy
  NotAtHome=        '#nah';   // Not at Home
  NotMyDesk=        '#nmd';   // Not My Desk
  NotInTheOffice=   '#nio';   // Not in the Office
  OnThePhone=       '#otp';   // On the Phone
  OnVacation=       '#ova';   // On Vacation
  OutToLunch=       '#otl';   // Out to Lunch
  SteppedOut=       '#sto';   // Stepped Out
  Invisable=        '#inv';   // Invisable
  Idle=             '#idl';   // Idle
  IdleWithMessage = '[idle]';   // Idle with message
  BusyWithMessage = '[busy]';   // Busy with message

  CodeESC=#$1B;
  ESC_Black=CodeESC+'[30m';
  ESC_Blue=CodeESC+'[31m';
  ESC_Olive=CodeESC+'[32m';
  ESC_Silver=CodeESC+'[33m';
  ESC_GreenLight=CodeESC+'[34m';
  ESC_Pink=CodeESC+'[35m';
  ESC_Maroon=CodeESC+'[36m';
  ESC_Orange=CodeESC+'[37m';
  ESC_Red=CodeESC+'[38m';
  ESC_Green=CodeESC+'[39m';
  ESC_BoldE=CodeESC+'[1m';
  ESC_ItalicE=CodeESC+'[2m';
  ESC_UnderlineE=CodeESC+'[4m';
  ESC_BoldD=CodeESC+'[1m'; // Disable
  ESC_ItalicD=CodeESC+'[2m'; //Disable
  ESC_UnderlineD=CodeESC+'[4m'; //Disable
  Attr_FadeOpen='<FADE %s,%s,%s>';
  Attr_FadeClose='</FADE>';
  Attr_FontOpen='<Font face=%s>';
  Attr_FontClose='</Font>';
Type
  TProvider=(
    prYahoo=1,
    prJabber=2,
    prGTalk=3,
    prMSN=4,
    prLive=5,
    prAOL=6,
    prICQ=7);
  TRoYaState=set of (
    rsOwner=1,
    rsNewContact=2,
    rsTimer=4);
  TIntroduce=(
    teNormal=1,
    teNewer=2,
    teNewSession=3);  
  TRoYaVariables=class (TObject)
    public
      In_UserID:String;
      In_HWNDApp:HWND;
      In_ListParam:TStringList;
      In_RobotID:String;
      In_RAWInstantMessage:String;
      In_InstantMessage:String;
      In_Introduce:TIntroduce;
      In_Owner:String;
      In_Provider:TProvider;
      In_RoYaState:TRoYaState;
      Out_Timer:Integer;
      Out_StatusMessage:String;
      Out_InstantMessage:TStringList;
      Out_DoNotSend:Boolean;
      Out_IsAlice:Boolean;
  end;
implementation

end.
