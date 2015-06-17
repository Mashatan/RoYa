{
   File: f_IMNode

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
unit f_IMNode;

interface
uses classes,f_IMConsts,f_RoYaDefines;
Type
  TIMNode=class (TObject)
     private
       fAliceInfo:TStringList;
       fRoYaInfo:TStringList;
     public
       Username:String;
       Level:Integer;
       Provider:TProvider;
       FirstEnter:TDatetime;
       FirstSession:TDatetime;
       LastSession:TDatetime;
       LastDuration:Cardinal; // Second
       TotalDuration:Cardinal; // Second
       TotalBlockMessageNo:Cardinal;
       LastMessageNo:Cardinal;
       TotalMessageNo:Cardinal;
       IsNewUser,IsNewSession,ban:boolean;
       RestrictionVal:Integer;
       Rank:real;
       constructor Create;
       destructor  Destroy;override;
       property AliceInfo:TStringList read fAliceInfo;
       property RoYaInfo:TStringList read fRoYaInfo;
  end;

implementation
{ TIMNode }

constructor TIMNode.Create;
begin
  fAliceInfo:=TStringList.Create;
  fRoYaInfo:=TStringList.Create;
end;

destructor TIMNode.Destroy;
begin
  fAliceInfo.Clear;
  fRoYaInfo.Clear;
  fAliceInfo.Free;
  fRoYaInfo.Free;
  inherited;
end;

end.
