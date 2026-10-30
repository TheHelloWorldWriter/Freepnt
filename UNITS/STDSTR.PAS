{*******************************************************}
{                                                       }
{    The Hello World Writer's Turbo Pascal Library      }
{    Standard String-Oriented Routines Unit             }
{                                                       }
{    Copyright (c) 1995-2026 The Hello World Writer     }
{                                                       }
{*******************************************************}

unit StdStr;

interface

{ Pointer to a string }
type
  PString = ^string;

{ Null string }
const
  NullStr = '';

{ New line string CR + LF }
const
  NewLine = #13#10;

{ Boolean strings }
const
  TrueStr  = 'True';
  FalseStr = 'False';

{ Initializes a string with random characters; calls Randomize first }
function RandomStr(const Len : Byte) : string;

{ Returns the sum of all characters in a string }
function SumStr(const S : string) :  Word;

{ Converts a character to lowercase }
function LowCase(const Ch : Char) : Char;

{ Returns an all-lowercase version of a string }
function LowStr(const S : string) : string;

{ Returns an all-uppercase version of a string }
function UpStr(const S : string) : string;

{ Returns the characters in a string in the reverse order }
function InvStr(const S : string) : string;

{ Compares two strings. The return value is less than 0 if Str1 < Str2,
  0 if Str1 = Str2, or greater than 0 if Str1 > Str2 }
function CompStr(const S1, S2 : string) : Integer;

{ Returns the smaller of two strings }
function MinStr(const S1, S2 : string) : string;

{ Returns the larger of two strings }
function MaxStr(const S1, S2 : string) : string;

{ Moves a substring from a string into another }
function MoveStr(var S : string ; const Index, Count : Byte) : string;

{ Pads a string to a specified length with a specified character }
function PadStr(S : string ; const Ch : Char ; const Len : Byte) : string;

{ Returns the last occurrence of a string in another string }
function RPos(const SS, S : string) : Byte;

{ Truncates a string to a specified length }
function TruncStr(S : string ; const Position : Byte) : string;

procedure TruncateStr(var S  : string  ; const Position  : Byte);

{ Creates a string with a specified length and fills it with a specified
  character }
function FillStr(const Len : Byte ; const Ch : Char) : string;

{ Centers a string within a certain width }
function CenterStr(S : string ; const Width : Byte) : string;

{ Left-justifies a string within a certain width }
function LeftJustStr(S : string ; const Width : Byte) : string;

{ Right-justifies a string within a certain width }
function RightJustStr(S : string ; const Width : Byte) : string;

{ Converts a number to a string }
function ToStr(const N : Longint) : string;

{ Converts a real number to a string }
function RToStr(const N : Real) : string;

implementation

uses Integ;

function RandomStr(const Len : Byte) : string;
var
  I : Byte;
  S : string;
begin
  Randomize;
  S := '';
  for I := 1 to Len do S := S + Chr(Random(255));
  RandomStr := S
end;

function SumStr(const S : string) : Word;
var
  I : Byte;
  Sum : Word;
begin
  Sum := 0;
  for I := 1 to Length(S) do Sum := Sum + Ord(S[I]);
  SumStr := Sum
end;

function LowCase(const Ch : Char) : Char;
begin
  if Ch in ['A'..'Z'] then LowCase := Chr(Ord(Ch) + 32)
                      else LowCase := Ch
end;

function LowStr(const S : string) : string;
var
  I : Byte;
begin
  LowStr[0] := S[0];
  for I := 1 to Length(S) do LowStr[I] := LowCase(S[I])
end;

function UpStr(const S : string) : string;
var
  I : Byte;
begin
  UpStr[0] := S[0];
  for I := 1 to Length(S) do UpStr[I] := UpCase(S[I])
end;

function InvStr(const S : string) : string;
var
  I : Byte;
  S2 : string;
begin
  S2 := '';
  for I := Length(S) downto 1 do S2 := S2 + S[i];
  InvStr := S2
end;

function CompStr(const S1, S2 : string) : Integer;
var
  I : Integer;
begin
  I := 0;
  repeat
    I := I + 1
  until (S1[I] <> S2[I]) or (I >= Min(Length(S1), Length(S2)));
  if (I = Min(Length(S1), Length(S2))) and (I < Max(Length(S1), Length(S2)))
  then
  begin
    I := I + 1;
    if Min(Length(S1), Length(S2)) = Length(S1) then I := -I
  end
  else
    if S1[I] = S2[I] then I := 0
    else
      if S1[I] < S2[I] then I := -I;
  CompStr := I
end;

function MinStr(const S1, S2 : string) : string;
begin
  if S1 <= S2 then MinStr := S1
              else MinStr := S2
end;

function MaxStr(const S1, S2 : string) : string;
begin
  if S1 >= S2 then MaxStr := S1
              else MaxStr := S2
end;

function MoveStr(var S : string ; const Index, Count : Byte) : string;
begin
  MoveStr := Copy(S, Index, Count);
  Delete(S, Index, Count)
end;

function PadStr(S : string ; const Ch : Char ; const Len : Byte) : string;
var
  CurrLen : Byte;
begin
  CurrLen := Min(Length(S), Len);
  S[0] := Chr(Len);
  FillChar(S[Succ(CurrLen)], Len - CurrLen, Ch);
  PadStr := S
end;

function RPos(const SS, S : string) : Byte;
var
  I : Byte;
  S2 : string;
begin
  I := Length(S) + 1;
  S2 := '';
  repeat
    I := I-1;
    S2 := Copy(S, I, Length(S)-I + 1)
  until (I <=1) or (Pos(SS,S2) > 0);
  if Pos(SS, S2) = 0 then I := 0;
  RPos := I
end;

function TruncStr(S : string ; const Position : Byte) : string;
begin
  if Length(S) > Position then
    Delete(S, Succ(Position), Length(S) - Position);
  TruncStr :=  S
end;

procedure TruncateStr(var S  : string  ; const Position  : Byte);
var
  Len  : Byte absolute S;
begin
  Len  :=  Position
end;

function FillStr(const Len : Byte ; const Ch : Char) : string;
var
  S : String;
begin
  S[0] := Chr(Len);
  FillChar(S[1], Len, Ch);
  FillStr := S
end;

function CenterStr(S : string ; const Width : Byte) : string;
begin
  S :=  LeftJustStr(LeftJustStr('', (Width - Length(S)) shr 1)  +  S, Width);
  CenterStr := S
end;

function LeftJustStr(S : string ; const Width : Byte) : string;
begin
  LeftJustStr := PadStr(S, ' ', Width)
end;

function RightJustStr(S : string ; const Width : Byte) : string;
begin
  S := TruncStr(S, Width);
  RightJustStr := LeftJustStr('', Width - Length(S))  +  S
end;

function ToStr(const N : Longint) : string;
var
  S : String[80];
begin
  Str(N, S);
  ToStr := S
end;

function RToStr(const N : Real) : string;
var
  S : String[80];
begin
  Str(N, S);
  RToStr := S
end;

end.
