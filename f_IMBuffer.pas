{
   File: f_IMBuffer

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
unit f_IMBuffer;
interface
uses Contnrs,windows,SysUtils,f_IMTransmitPacket;
type
  TIMBuffer = class (TObjectQueue)
   private
      hMutex: THandle;
   public
     constructor Create;
     function Push(AObject: TIMTransmitPacket): TIMTransmitPacket;
     function POP: TIMTransmitPacket;
  end;

implementation

constructor TIMBuffer.Create;
begin
  inherited Create;
end;

function TIMBuffer.Push(AObject: TIMTransmitPacket): TIMTransmitPacket;
begin
    result:= TIMTransmitPacket(inherited push(AObject));
end;

function TIMBuffer.POP: TIMTransmitPacket;
begin
    result:= TIMTransmitPacket(inherited pop());
end;
end.
