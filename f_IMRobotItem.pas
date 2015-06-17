{
   File: f_IMRobotItem

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
unit f_IMRobotItem;
interface
uses Classes,SysUtils,f_IMAccount,f_IMCore,f_IMWatcher,f_IMBuffer;
type
  TIMRobotItem=Class(TCollectionItem)
   private
     fCore:TIMCore;
     fAccount:TIMAccount;
     fWatcher:TIMWatcher;
     fInputBuffer:TIMBuffer;
   public
     property    Core:TIMCore read fCore;
     procedure   AfterConstruction;override;
     destructor  Destroy;override;
     procedure   Init(vAccount:TIMAccount;vWatcher:TIMWatcher;vInputBuffer:TIMBuffer);
     procedure   Start;
     Procedure   Stop;
     property    Account:TIMAccount read fAccount;
  end;

implementation

uses f_IMCommon;

procedure TIMRobotItem.AfterConstruction;
begin
  inherited;
  fCore:=nil;
  fWatcher:=nil;
end;

destructor TIMRobotItem.Destroy;
begin
   inherited Destroy;
End;

procedure TIMRobotItem.Init(vAccount:TIMAccount;vWatcher:TIMWatcher;vInputBuffer:TIMBuffer);
begin
  fAccount:=vAccount;
  fWatcher:=vWatcher;
  fInputBuffer:=vInputBuffer;
end;

procedure  TIMRobotItem.Start;
begin
  if not Assigned(fCore) then begin
    fCore:=TIMCore.Create(fAccount,fWatcher,fInputBuffer);
  end;
end;

Procedure TIMRobotItem.Stop;
begin
  if Assigned(fCore) then begin
    fWatcher.FlushData(miAll);
    FreeAndNil(fCore);
  end;
end;
end.
