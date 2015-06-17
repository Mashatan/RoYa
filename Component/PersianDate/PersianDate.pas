{
   File: PersianDate

   Date:     2008-09-07
   Author:   Ali Hadidian

   License:
     GNU Public License ( GPL3 ) [http://www.gnu.org/licenses/gpl-3.0.txt]
     Copyrigth (c) Vazesh 2008

   Contact Details:
     If you use PersianDate I would like to hear from you: please email me
     your comments - good and bad.
     E-mail:  ali.hadidian@gmail.com
     website: http://www.vazesh.com

   Change History:
   Date         Author       Description
}
unit PersianDate;
interface

uses Controls;

    function  GetSolarDate(MyDate: TDateTime): String;
    function  GetSolarDate2(MyDate: TDateTime): String;
    procedure DecodeToSolar(Gregorian: TDateTime;var SolarYear,SolarMonth,SolarDay: Word);
    function  EncodeToGregorian(var SolarYear,SolarMonth,SolarDay: Word): TDate;
    function  EncodeToGregorian2(SolarDate: String): TDate;

    procedure jd_to_persian(var jd: Extended;var y,m,d: Word);
    procedure jd_to_gregorian(var jd: Extended;var year,month,day: Word);
    function  persian_to_jd(year, month, day: Word): Extended;
    function  gregorian_to_jd(year, month, day: Word): Extended;


    function  leap_gregorian(year: Word): Boolean;
    function  leap_persian(year: Word): Boolean;
implementation

uses Math, DateUtils, SysUtils, Variants;

function leap_gregorian(year: Word): Boolean;
begin
    Result := ((year mod 4)=0) and
               (not(((year mod 100)=0) and ((year mod 400) <> 0)));
   {return ((year % 4) == 0) &&
            (!(((year % 100) == 0) && ((year % 400) != 0)));}
end;
function leap_persian(year: Word): Boolean;
begin
    result := ((((((year - (    IfThen((year > 0) , 474 , 473)    )) mod 2820) + 474) + 38) * 682) mod 2816) < 682;
    //return ((((((year - ((year > 0) ? 474 : 473)) % 2820) + 474) + 38) * 682) % 2816) < 682;
end;

function gregorian_to_jd(year, month, day: Word): Extended;
const
    GREGORIAN_EPOCH = 1721425.5;
var
    E1: Extended;
begin
    if (month <= 2) then begin
        E1 := 0;
    end else begin
        if leap_gregorian(year) then E1 := -1
        else E1 := -2;
    end;
    Result :=
           (GREGORIAN_EPOCH - 1) +
           (365 * (year - 1)) +
           Floor((year - 1) / 4) +
           (-Math.floor((year - 1) / 100)) +
           Math.floor((year - 1) / 400) +
           Math.floor((((367 * month) - 362) / 12) +
           E1
           +
           day);
{           ((month <= 2) ? 0 : (leap_gregorian(year) ? -1 : -2)
           ) +
           day);}
end;

procedure jd_to_gregorian(var jd: Extended;var year,month,day: Word);
const GREGORIAN_EPOCH = 1721425.5;
var
    wjd,depoch,dqc,dcent,dquad,yearday,leapadj: Extended;
    quadricent,cent,quad,yindex: Integer;
    E1: Extended;
begin
    wjd := floor(jd - 0.5) + 0.5;
    depoch := wjd - GREGORIAN_EPOCH;
    quadricent := floor(depoch / 146097);
    dqc := trunc(depoch) mod 146097;
    cent := floor(dqc / 36524);
    dcent := trunc(dqc) mod 36524;
    quad := floor(dcent / 1461);
    dquad := trunc(dcent) mod 1461;
    yindex := floor(dquad / 365);
    year := (quadricent * 400) + (cent * 100) + (quad * 4) + yindex;
    if (not((cent = 4) or (yindex = 4))) then
        Inc(year);
    yearday := wjd - gregorian_to_jd(year, 1, 1);
    E1 := IfThen(leap_gregorian(year),1,2);
    leapadj := IfThen((wjd < gregorian_to_jd(year, 3, 1)),0,E1);
    {leapadj := ((wjd < gregorian_to_jd(year, 3, 1)) ? 0
                                                  :
                  (leap_gregorian(year) ? 1 : 2)
              );}
    month := floor((((yearday + leapadj) * 12) + 373) / 367);
    day := Trunc(wjd - gregorian_to_jd(year, month, 1)) + 1;
end;

function persian_to_jd(year, month, day: Word): Extended;
const PERSIAN_EPOCH = 1948320.5;
{const PERSIAN_WEEKDAYS = new Array("Yekshanbeh", "Doshanbeh",
                                 "Seshhanbeh", "Chaharshanbeh",
                                 "Panjshanbeh", "Jomeh", "Shanbeh");}
var epbase, epyear: Integer;
    i: Integer;
begin
    epbase := year - IfThen((year >= 0),474,473);
    epyear := 474 + (epbase mod 2820);
    result := day +
            IfThen((month <= 7),((month - 1) * 31),(((month - 1) * 30) + 6))
            +
            Math.floor(((epyear * 682) - 110) / 2816) +
            (epyear - 1) * 365 +
            Math.floor(epbase / 2820) * 1029983 +
            (PERSIAN_EPOCH - 1);
end;

procedure jd_to_persian(var jd: Extended;var y,m,d: Word);
var month, day, cyear,
    aux2: integer;
    depoch,yday: Extended;
    year,ycycle,aux1,cycle: Extended;
    i: integer;
begin
    jd := Math.floor(jd) + 0.5;
    depoch := jd - persian_to_jd(475, 1, 1);
    cycle := Math.floor(depoch / 1029983);
    cyear := (trunc(depoch) mod 1029983);
    if (cyear = 1029982) then
        ycycle := 2820
    else begin
        aux1 := Math.floor(cyear / 366);
        aux2 := cyear mod 366;
        ycycle := Math.floor(((2134 * aux1) + (2816 * aux2) + 2815) / 1028522) +
                    aux1 + 1;
    end;
    year := ycycle + (2820 * cycle) + 474;
    if (year <= 0) then
        year:=year-1;
    yday := (jd - persian_to_jd(Trunc(year), 1, 1)) + 1;
    month := Trunc(IfThen((yday <= 186),Ceil(yday / 31),Ceil((yday - 6) / 30)));
    day := trunc((jd - persian_to_jd(Trunc(year), month, 1)) + 1);
    y := Trunc(year);
    d := day;
    m := month;
end;{}

function GetSolarDate(MyDate: TDateTime): String;
var
    y,m,d:Word;
    E1: Extended;
    yy,mm,dd: String;
begin
    DecodeDate(MyDate,y,m,d);
    E1 := gregorian_to_jd(y,m,d);
    jd_to_persian(E1,y,m,d);

    yy := IntToStr(y);
    mm := IntToStr(m);
    dd := IntToStr(d);
    if Length(mm) = 1 then mm := '0'+mm;
    if length(dd) = 1 then dd := '0'+dd;
    Result := yy+'/'+mm+'/'+dd;
end;

function GetSolarDate2(MyDate: TDateTime): String;
const Days:Array[1..7]of string=('í˜ÔäÈå','ÏæÔäÈå','Óå ÔäÈå','åÇÑÔäÈå','äÌ ÔäÈå','ÌãÚå','ÔäÈå');
const Month:Array[1..12]of string=('ÝÑæÑÏíä','ÇÑÏíÈåÔÊ','ÎÑÏÇÏ','ÊíÑ','ãÑÏÇÏ','ÔåÑíæÑ','ãåÑ','ÂÈÇä','ÂÐÑ','Ïí','Èåãä','ÇÓÝäÏ');
var
    y,m,d:Word;
    E1: Extended;
begin
    DecodeDate(MyDate,y,m,d);
    E1 := gregorian_to_jd(y,m,d);
    jd_to_persian(E1,y,m,d);

    Result := Days[DayOfWeek(MyDate)]+' '+IntToStr(d)+' '+Month[m]+' '+IntToStr(y);
end;

procedure DecodeToSolar(Gregorian: TDateTime;var SolarYear,SolarMonth,SolarDay: Word);
var
    yy,mm,dd:Word;
    E1: Extended;
begin
    DecodeDate(Gregorian,yy,mm,dd);
    E1 := gregorian_to_jd(yy,mm,dd);
    jd_to_persian(E1,SolarYear,SolarMonth,SolarDay);
end;

function EncodeToGregorian(var SolarYear,SolarMonth,SolarDay: Word): TDate;
var
    yy,mm,dd:Word;
    E1: Extended;
begin
    E1 := persian_to_jd(SolarYear,SolarMonth,SolarDay);
    jd_to_gregorian(E1,yy,mm,dd);
    Result := EncodeDate(yy,mm,dd);
end;

function EncodeToGregorian2(SolarDate: String): TDate;
var
    Ny,Nm,Nd: Word;
    S: String;
begin
    if length(SolarDate) > 7 then
    begin
        try
            S := SolarDate;
            Ny := StrToInt(copy(S,1,pos('/',S)-1));
            S := copy(S,pos('/',S)+1,10);
            Nm := StrToInt(copy(S,1,pos('/',S)-1));
            S := copy(S,pos('/',S)+1,10);
            Nd := StrToInt(copy(S,1,2));
        except
            DecodeToSolar(Date,Ny,Nm,Nd);
        end;
    end else
    begin
        DecodeToSolar(Date,Ny,Nm,Nd);
    end;
    Result := EncodeToGregorian(Ny,Nm,Nd);
end;
end.

