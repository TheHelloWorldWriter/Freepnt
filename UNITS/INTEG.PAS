{*******************************************************}
{                                                       }
{    The Hello World Writer's Turbo Pascal Library      }
{    Integer & Real-Oriented Routines Unit              }
{                                                       }
{    Copyright (c) 1995-2026 The Hello World Writer     }
{                                                       }
{*******************************************************}

unit Integ;

interface

{ The results of WithComma, HexWord and HexLongInt }
type
  NCommaStr     = string[13];
  HexWordStr    = string[4];
  HexLongIntStr = string[8];

{ Pointer types }
type
  PShortInt = ^ShortInt;
  PInteger  = ^Integer;
  PLongint  = ^Longint;
  PByte     = ^Byte;
  PWord     = ^Word;
  PReal     = ^Real;
  PSingle   = ^Single;
  PDouble   = ^Double;
  PExtended = ^Extended;
  PComp     = ^Comp;

{ Integer types ranges, besides the built-in MaxInt and MaxLongInt;
  MinLongInt is one above the true minimum }
const
  MinShortInt = -128;
  MaxShortInt = 127;
  MinByte     = 0;
  MaxByte     = 255;
  MinWord     = 0;
  MaxWord     = 65535;
  MinInt      = -32768;
  MinLongInt  = -2147483647;

{ Fills a specified number (Count) of contiguous words with a specified
  value; only the low words of Count and Value are used }
procedure FillInt(var Dest ; const Count, Value : Longint);

{ Converts a number to hexadecimal, in upper case }
function HexWord(const W : Word) : HexWordStr;
function HexLongInt(const L : LongInt) : HexLongintStr;

{ Returns the smaller of two numbers }
function Min(const N1, N2 : Longint) : Longint;

{ Returns the smaller of two real numbers }
function MinR(const R1, R2 : Real) : Real;

{ Returns the larger of two numbers }
function Max(const N1, N2 : Longint) : Longint;

{ Returns the larger of two real numbers }
function MaxR(const R1, R2 : Real) : Real;

{ Divides X by Y with a single IDIV; the quotient must fit in an Integer }
function LongDiv(const X : Longint; const Y : Integer) : Integer;

{ Multiplies two integers into a Longint with a single IMUL }
function LongMul(const X, Y : Integer) : Longint;

{ Formats a number that is not negative with commas between groups of
  three digits }
function WithComma(N : Longint) : NCommaStr;

implementation

uses StdChar;

procedure FillInt(var Dest ; const Count, Value : Longint);
begin
  Inline($c4/$7e/<Dest/$8b/$4e/<Count/$8b/$46/<Value/$fc/$f3/$ab)
end;

function HexWord(const W : Word) : HexWordStr;
begin
  HexWord := HexDigits[Hi(w) shr 4] + HexDigits[Hi(w) and $F] +
             HexDigits[Lo(w) shr 4] + HexDigits[Lo(w) and $F]
end;

function HexLongInt(const L : LongInt) : HexLongintStr;
var
  X : array[1..2] of Word absolute L;
begin
  HexLongInt := HexWord(X[2]) + HexWord(X[1])
end;

function Min(const N1, N2 : Longint) : Longint;
begin
  if N1 <= N2 then Min := N1
              else Min := N2
end;

function MinR(const R1, R2 : Real) : Real;
begin
  if R1 <= R2 then MinR := R1
              else MinR := R2
end;

function Max(const N1, N2 : Longint) : Longint;
begin
  if N1 >= N2 then Max := N1
              else Max := N2
end;

function MaxR(const R1, R2 : Real) : Real;
begin
  if R1 >= R2 then MaxR := R1
              else MaxR := R2
end;

function LongDiv(const X : Longint; const Y : Integer) : Integer;
begin
  inline($59/$58/$5A/$F7/$F9)
end;

function LongMul(const X, Y : Integer) : Longint;
begin
  inline($5A/$58/$f7/$EA)
end;

function WithComma(N : Longint) : NCommaStr;
var
  S  : string[16];
  SS : string[4];
  I  : Byte;
begin
  S := '';
  repeat
    Str(N mod 1000 : 3, SS);
    for I := 1 to 2 do if SS[I] = ' ' then SS[I] := '0';
    SS := ',' + SS;
    S := SS + S;
    N := N div 1000;
  until N = 0;
  if (S[3] = '0') and (S[2] = '0') then I := 4
  else
    if S[2] = '0' then I := 3
    else
      I := 2;
  S := Copy(S, I, Length(S) - I + 1);
  WithComma := S
end;

end.
