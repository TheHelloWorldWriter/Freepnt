{*******************************************************}
{                                                       }
{    Freepnt Version 1.0.0                              }
{    Main Program Source Code                           }
{                                                       }
{    Copyright (c) 1995-2026 The Hello World Writer     }
{                                                       }
{*******************************************************}

program Freepnt;
{ Paints with the mouse in 640x480 VGA with 16 colors, and keeps the
  picture in a .FE1 file }

uses Graph, Mouse, Crt, FPTools, StdStr, Fillib, Dos, CrtKeyb;

var
  M, X, Y : Word;
  Code : Boolean;
  FileName : string;
  C, Ch : Char;

{ Draws the picture frame and the control bar below it }
procedure DoScreen;
var
  I : Byte;
begin

  { Draws picture border }

  SetColor(15);
  Rectangle(0, 0, PictSize.X, 415);

  { Draws bar }

  SetFillStyle(1, 15);
  Bar(0, 421, GetMaxX, GetMaxY);
  SetColor(0);
  Rectangle(1, 422, GetMaxX - 1, GetMaxY - 1);

  Rectangle(6, 427, 150, 440);
  OutTextXY(14, 430, 'Free Paint 1.0');

  Rectangle(170, 427, 385, 440);
  OutTextXY(178, 430, 'The Hello World Writer');

  Rectangle(415, 427, 515, 440);
  OutTextXY(420, 430, 'Clear Image');

  Rectangle(525, 427, 570, 440);
  OutTextXY(530, 430, 'Save');

  Rectangle(580, 427, 625, 440);
  OutTextXY(585, 430, 'Quit');

  { Draws colors bar }

  for I := 0 to 15 do
  begin
    Rectangle(I * 20 + 6, 450, I * 20 + 22, 475);
    SetFillStyle(1, I);
    Bar(I * 20 + 7, 451, I * 20 + 21, 474);
  end;
  Rectangle(335, 465, 385, 475);
  OutTextXY(330, 453, 'Selected');
  SelectCol(SelectedCol, True);

  { Draws brushes bar }

  { I is undefined after the loop above; Turbo Pascal leaves it at 15,
    white }
  SetFillStyle(1, I);
  for I := 1 to 9 do
  begin
    Rectangle(I * 20 + 426, 460, I * 20 + 442, 475);
    Bar(I * 20 + 427, 461, I * 20 + 441, 474);
    OutTextXY(I * 20 + 430, 465, ToStr(I));
  end;
  SelectBrush(SelectedBrush);
end;

{ Prints the DOS help screen and exits }
procedure HelpScreen;
begin
  WriteLn('Free Paint 1.0.  Author: The Hello World Writer. Oct 20 1995');
  WriteLn;
  WriteLn('Creates, saves and handles brush oriented graphic pictures.');
  WriteLn('Uses a special file format.');
  WriteLn('Requires a mouse input.');
  WriteLn;
  WriteLn('Usage is FREEPNT <graphic file>');
  WriteLn;
  WriteLn('A Free Paint 1.0 graphic file is a file with extension .FE1');
  Halt
end;

{ Replaces the control bar with a Y/N question and saves on Y }
procedure AskForSave;
begin
  SetFillStyle(1, 15);
  Bar(0, 421, GetMaxX, GetMaxY);
  SetColor(0);
  Rectangle(1, 422, GetMaxX - 1, GetMaxY - 1);

  Rectangle(6, 427, 150, 440);
  OutTextXY(14, 430, 'Free Paint 1.0');

  Rectangle(170, 427, 385, 440);
  OutTextXY(178, 430, 'The Hello World Writer');

  OutTextXY(6, 460, 'Save changes to file (Y/N)?');
  if UpCase(KeyInRange(YesNoKeys)) = 'Y' then SavePicture;
end;

{ Creates the graphic environment }
procedure InitPro;
begin
  CheckBreak := False;
  InitGraphics;
  ShowMouse;
  DoScreen;
  MouseTo(10, GetMaxY - 20)
end;

begin

  { If mouse is not found then aborts }

  if MouseDrvInstalled = False then Abort('Mouse not installed');

  { Displays the help screen }

  if (ParamCount = 0) or (ParamStr(1) = '/?') then HelpScreen;

  { Analyses the graphic file parameter }

  FileName := ParamStr(1);
  if (Ext(FileName) = '') then FileName := FileName + '.FE1';
  if (Ext(FileName) <> '.FE1') then Abort('Invalid graphic file extension');
  Assign(F, FileName);

  { If file exists then loads it }

  if FileExists(FileName, AnyFile) = True
  then
    if StdReset(FileName) <> 0 then GrAbort('Unable to open picture file')
    else
    begin
      InitPro;
      RetrivePicture;
      if RetriveError = True then GrAbort('Error reading picture file')
    end
  else
  begin
    if StdRewrite(FileName) <> 0 then GrAbort('Unable to create the new file');
    InitPro
  end;

  { Runs program }

  Code := False;
  repeat
    M := MouseState(X, Y);
    if M <> 0 then
    begin
      if IsIn(X, Y, SelR) then DrawPixel(X, Y);
      if IsIn(X, Y, ColBar) then BarColSelect(X);
      if IsIn(X, Y, BrushBar) then BarBrushSelect(X);
      if IsIn(X, Y, MenuQuit) then Code := True;
      if IsIn(X, Y, MenuClear) then ClearPicture;
      if IsIn(X, Y, MenuSave) then SavePicture
    end;
    if KeyPressed then ReadAKey(C, Ch)
  until (Code = True) or (UpCase(C) = 'Q');

  { Disposes the graphic environment }

  HideMouse;
  if IsChanged then AskForSave;
  CloseGraph
end.
