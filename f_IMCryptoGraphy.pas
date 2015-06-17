{
   File: f_IMCryptography

   Project:  RoYa
   Status:   Version 4.0
   Date:     2008-10-01
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
unit f_IMCryptography;

interface
uses f_IMConsts,DCPcrypt2, DCPblockciphers, DCPblowfish, DCPSHA1,DCPmd5, DCPcast128;
Type

  TCryptoGraphy=Class
    private
      fCrypt: TDCP_cast128;
      procedure Init;
    public
     constructor Create();
     destructor  Destroy();override;
     Function  Encrypt(pText:String):String;
     Function  Decrypt(pText:String):String;
  end;

implementation

{ TCryptoGraphy }

constructor TCryptoGraphy.Create;
begin
  fCrypt:=TDCP_cast128.Create(nil);
end;

destructor TCryptoGraphy.Destroy;
begin
  fCrypt.free
end;

procedure TCryptoGraphy.Init;
begin
  fCrypt.InitStr(coKeyCrypto,TDCP_sha1);
end;

function TCryptoGraphy.Decrypt(pText: String): String;
begin
  Init;
  result:=fCrypt.DecryptString(pText);
  fCrypt.Burn;
end;


function TCryptoGraphy.Encrypt(pText: String): String;
begin
  Init;
  result:=fCrypt.EncryptString(pText);
end;


end.
