{*******************************************************}
{                                                       }
{    Freepnt Version 1.0.0                              }
{    Viewer Program Source Code                         }
{                                                       }
{    Copyright (c) 1995-2026 The Hello World Writer     }
{                                                       }
{*******************************************************}

program FreepntViewer;
{ Shows a .FE1 picture until Q is pressed }

uses Graph, CrtKeyb, FPTools, StdStr, Fillib, Dos;

var
  FileName : string;

{ Draws the picture frame and the viewer's bar below it }
procedure DoScreen;
begin

  { Draws picture border }

  SetColor(15);
  Rectangle(0, 0, PictSize.X, 415);

  { Draws bar }

  SetFillStyle(1, 15);
  Bar(0, 451, GetMaxX, GetMaxY - 3);
  SetColor(0);
  Rectangle(1, 452, GetMaxX - 1, GetMaxY - 4);

  Rectangle(6, 457, 300, 470);
  OutTextXY(14, 460, 'Free Paint 1.0 Graphic Files Viewer');

  Rectangle(320, 457, 520, 470);
  OutTextXY(330, 460, 'The Hello World Writer');

  Rectangle(535, 457, 600, 470);
  OutTextXY(545, 460, 'Q Quit');
end;

{ Prints the DOS help screen and exits }
procedure HelpScreen;
begin
  WriteLn('Free Paint 1.0 Graphic Files Viewer.');
  WriteLn('Author: The Hello World Writer. Oct 20 1995');
  WriteLn;
  WriteLn('Displays graphic pictures created with Free Paint 1.0.');
  WriteLn;
  WriteLn('Usage is FREEPNTV <graphic file>');
  WriteLn;
  WriteLn('A Free Paint 1.0 graphic file is a file with extension .FE1');
  Halt
end;

begin
  { Displays the help screen }

  if (ParamCount = 0) or (ParamStr(1) = '/?') then HelpScreen;

  { Analyses the graphic file parameter }

  FileName := ParamStr(1);
  if (Ext(FileName) = '') then FileName := FileName + '.FE1';
  if (Ext(FileName) <> '.FE1') then Abort('Invalid graphic file extension');
  Assign(F, FileName);
  if FileExists(FileName, AnyFile) = True
  then
    if StdReset(FileName) <> 0 then GrAbort('Unable to open picture file')
    else
    begin

     { Creates the viewer graphic environment }

      InitGraphics;
      DoScreen;
      RetrivePicture;
      if RetriveError = True then GrAbort('Error reading picture file')
    end
  else
    Abort('File not found');

  KeyInRange(['Q','q']);

  { Disposes the graphic environment }

  CloseGraph
end.
