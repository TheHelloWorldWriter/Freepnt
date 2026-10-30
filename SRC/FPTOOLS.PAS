{*******************************************************}
{                                                       }
{    Freepnt Version 1.0.0                              }
{    Shared Paint and Picture File Unit                 }
{                                                       }
{    Copyright (c) 1995-2026 The Hello World Writer     }
{                                                       }
{*******************************************************}

unit FPTools;
{ The screen layout, brushes and picture file routines shared by the
  editor and the viewer }

interface

{ A point, in pixels }
type
  TSize = record
    X, Y : Integer;
  end;

{ A screen rectangle, edges included }
type
  TRange = record
    X1, Y1, X2, Y2 : Integer;
  end;

{ The right edge of the picture frame and the last picture line }
const
  StdPictSize : TSize = ( X : 638 ; Y : 412 );

{ The click areas of the control bar }
const
  ColBar : TRange = ( X1 : 6 ; Y1 : 450 ; X2 : 322 ; Y2 : 475 );

const
  BrushBar : TRange = ( X1 : 446 ; Y1 : 460 ; X2 : 622 ; Y2 : 475 );

const
  MenuClear : TRange = ( X1 : 415 ; Y1 : 427 ; X2 : 515 ; Y2 : 440 );
  MenuSave : TRange = ( X1 : 525 ; Y1 : 427 ; X2 : 570 ; Y2 : 440 );
  MenuQuit : TRange = ( X1 : 580 ; Y1 : 427 ; X2 : 625 ; Y2 : 440 );

{ The current color and brush size }
const
  SelectedCol : Byte = 15;

const
  SelectedBrush : Byte = 1;

{ Set by RetrivePicture when the file is too short }
const
  RetriveError : Boolean = False;

{ True once the picture is painted or cleared, until it is saved }
const
  IsChanged : Boolean = False;

{ The picture size in use, set to StdPictSize }
var
  PictSize : TSize;

{ Where a click paints with the current brush, so the brush stays inside
  the frame }
var
  SelR : TRange;

{ Scratch for SavePicture and RetrivePicture }
var
  BitMapSize : Word;

{ The picture file; each program assigns it before calling the save and
  load routines }
var
  F : file;

var
  PP : Pointer;

{ Prints S and exits, for errors before graphics mode starts }
procedure Abort(const S : string);

{ Leaves graphics mode, prints S and exits }
procedure GrAbort(const S : string);

{ Starts the graphics mode the BGI detects, loading its driver from the
  current directory; exits if that fails }
procedure InitGraphics;

{ Returns True if X, Y is inside R }
function  IsIn(const X, Y : Integer ; const R : TRange) : Boolean;

{ Makes I the current color and shows it in the Selected box; On is
  not used }
procedure SelectCol(const I : Byte ; const On : Boolean);

{ Selects the color under column X of the color strip }
procedure BarColSelect(const X : Integer);

{ Makes I the current brush, shows its number and sets SelR to match }
procedure SelectBrush(const I : Byte);

{ Selects the brush under column X of the brush strip }
procedure BarBrushSelect(const X : Integer);

{ Stamps the current brush, a square that grows up and left from X, Y;
  brush 1 lands one pixel up and left of X, Y }
procedure DrawPixel(const X, Y : Integer);

{ Fills the picture with the current color }
procedure ClearPicture;

{ Writes the picture to F as nine GetImage strips: eight of 51 lines,
  then one of 5 lines that overlaps the eighth by 3 }
procedure SavePicture;

{ Reads a picture that SavePicture wrote from F }
procedure RetrivePicture;

implementation

uses Graph, StdStr;

procedure Abort(const S : string);
begin
  WriteLn(S);
  Halt
end;

procedure GrAbort(const S : string);
begin
  CloseGraph;
  WriteLn(S);
  Halt
end;

procedure InitGraphics;
var
  grDriver, grMode, ErrCode : Integer;
begin
  grDriver := Detect;
  InitGraph(grDriver, grMode,'');
  ErrCode := GraphResult;
  if ErrCode <> grOk then
  begin
    Writeln('Graphics error: ', GraphErrorMsg(ErrCode));
    Halt
  end
end;

function IsIn(const X, Y : Integer ; const R : TRange) : Boolean;
begin
  IsIn := (X >= R.X1) and (X <= R.X2) and (Y >= R.Y1) and (Y <= R.Y2)
end;

procedure SelectCol(const I : Byte ; const On : Boolean);
begin
  SelectedCol := I;
  SetFillStyle(1, I);
  Bar(336, 466, 384, 474);
end;

procedure BarColSelect(const X : Integer);
var
  I : Byte;
  Cod : Boolean;
begin
  I := 0;
  Cod := False;
  repeat
    if (X >= I * 20 + 6) and (X <= I * 20 + 22) then Cod := True;
    I := I + 1
  until (Cod = True) or (I > 15);
  if Cod = True then
  begin
    SelectCol(SelectedCol, False);
    SelectCol(I - 1, True)
  end;
end;

procedure SelectBrush(const I : Byte);
begin
  SelectedBrush := I;
  SelR.X1 := 3 + I;
  SelR.Y1 := 3 + I;
  SelR.X2 := PictSize.X - 4;
  SelR.Y2 := PictSize.Y;
  OutTextXY(445, 450, 'Selected Brush:');
  SetColor(15);
  OutTextXY(575, 450, 'Û');
  SetColor(0);
  OutTextXY(575, 450, ToStr(I))
end;

procedure BarBrushSelect(const X : Integer);
var
  I : Byte;
  Cod : Boolean;
begin
  I := 0;
  Cod := False;
  repeat
    if (X >= I * 20 + 426) and (X <= I * 20 + 442) then Cod := True;
    I := I + 1
  until (Cod = True) or (I > 9);
  if Cod = True then SelectBrush(I - 1)
end;

procedure DrawPixel(const X, Y : Integer);
var
  I, J : Byte;
begin
  IsChanged := True;
  case SelectedBrush of
    1 : begin
          PutPixel(X - 1, Y - 1, SelectedCol);
        end;
    2 : begin
          for I := 0 to 1 do
            for J := 0 to 1 do
              PutPixel(X - I, Y - J, SelectedCol);
        end;
    3 : begin
          for I := 0 to 2 do
            for J := 0 to 2 do
              PutPixel(X - I, Y - J, SelectedCol);
        end;
    4 : begin
          for I := 0 to 3 do
            for J := 0 to 3 do
              PutPixel(X - I, Y - J, SelectedCol);
        end;
    5 : begin
          for I := 0 to 4 do
            for J := 0 to 4 do
              PutPixel(X - I, Y - J, SelectedCol);
        end;
    6 : begin
          for I := 0 to 5 do
            for J := 0 to 5 do
              PutPixel(X - I, Y - J, SelectedCol);
        end;
    7 : begin
          for I := 0 to 6 do
            for J := 0 to 6 do
              PutPixel(X - I, Y - J, SelectedCol);
        end;
    8 : begin
          for I := 0 to 7 do
            for J := 0 to 7 do
              PutPixel(X - I, Y - J, SelectedCol);
        end;
    9 : begin
          for I := 0 to 8 do
            for J := 0 to 8 do
              PutPixel(X - I, Y - J, SelectedCol);
        end;
  end;
end;

procedure ClearPicture;
begin
  IsChanged := True;
  SetFillStyle(1, SelectedCol);
  Bar(3, 3, PictSize.X-3, 412);
end;

procedure SavePicture;
var
  I : Byte;
begin
 Rewrite(F, 1);
 for I := 0 to 7 do
 begin
   BitMapSize := ImageSize(3, 3 + 50 * I + I, PictSize.X - 4, 50 * I + 50 + 3 + I);
   GetMem(PP, BitMapSize);
   GetImage(3, 3 + 50 * I + I, PictSize.X - 4, 50 * I + 50 + 3 + I, PP^);
   BlockWrite(F, PP^, BitMapSize);
   FreeMem(PP, BitMapSize);
 end;
 BitMapSize := ImageSize(3, 408, PictSize.X - 4, 412);
 GetMem(PP, BitMapSize);
 GetImage(3, 408, PictSize.X - 4, 412, PP^);
 BlockWrite(F, PP^, BitMapSize);
 FreeMem(PP, BitMapSize);
 Close(F);
 IsChanged := False
end;

procedure RetrivePicture;
var
  I : Byte;
begin
 Reset(F, 1);
 for I := 0 to 7 do
 begin
   BitMapSize := ImageSize(3, 3 + 50 * I + I, PictSize.X - 4, 50 * I + 50 + 3 + I);
   GetMem(PP, BitMapSize);
   {$I-}
   BlockRead(F, PP^, BitMapSize);
   {$I+}
   if IOResult <> 0 then
     RetriveError := True;
   PutImage(3, 3 + 50 * I + I, PP^, NormalPut);
   FreeMem(PP, BitMapSize);
 end;
 BitMapSize := ImageSize(3, 408, PictSize.X - 4, 412);
 GetMem(PP, BitMapSize);
 {$I-}
 BlockRead(F, PP^, BitMapSize);
 {$I+}
 if IOResult <> 0 then
   RetriveError := True;
 PutImage(3, 408, PP^, NormalPut);
 FreeMem(PP, BitMapSize);
 Close(F);
end;

begin
  PictSize := StdPictSize
end.
