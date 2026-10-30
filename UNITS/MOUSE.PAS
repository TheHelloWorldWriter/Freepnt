{*******************************************************}
{                                                       }
{    The Hello World Writer's Turbo Pascal Library      }
{    Mouse Routines Unit                                }
{                                                       }
{    Copyright (c) 1995-2026 The Hello World Writer     }
{                                                       }
{*******************************************************}

unit Mouse;
{ The mouse driver's INT 33h functions; positions are in the driver's
  virtual coordinates, which match the pixels in 640x480 VGA }

interface

{ A hardware reset, or a software reset that skips the hardware }
type
   TWare = (Software, Hardware);

const
  Int33 = $33;

{ The languages for SetMessageLang }
const
  English   = $00;
  French    = $01;
  Dutch     = $02;
  German    = $03;
  Swedish   = $04;
  Finish    = $05;
  Spanish   = $06;
  Portugese = $07;
  Italian   = $08;

{ True when a mouse driver answered the reset at startup }
var
  MouseDrvInstalled : Boolean;

{ The button count from the last ResetMouse }
var
  ButtonCount : Byte;

{ Resets the driver and returns $FFFF if one is installed, or 0 }
function  ResetMouse(const ResetType : TWare) : Word;

{ Shows or hides the mouse cursor; the driver counts the calls, so each
  HideMouse needs a ShowMouse to show it again }
procedure ShowMouse;
procedure HideMouse;

{ Returns the buttons held down, bit 0 left, bit 1 right and bit 2
  middle, and the position in X and Y }
function  MouseState(var X, Y : Word) : Word;

{ Moves the mouse cursor to X, Y }
procedure MouseTo(const X, Y : Word);

{ Return the buttons held down, and for Button, 0 left, 1 right and
  2 middle, how often it was pressed or released since the last call in
  No and where that last happened in X and Y }
function  MousePressed(const Button : Word ; var No, X, Y : Word) : Word;
function  MouseReleased(const Button : Word ; var No, X, Y : Word) : Word;

{ Limit the mouse cursor to columns or rows Min to Max }
procedure MouseXRange(const Min, Max : Word);
procedure MouseYRange(const Min, Max : Word);

{ Returns how far the mouse moved since the last call, in mickeys }
procedure MouseMotion(var X, Y : Integer);

{ Turns light pen emulation on or off }
procedure LightPen(const Option : Boolean);

{ Set and return the mickeys per 8 pixels for X and Y, and the speed in
  mickeys per second above which the cursor moves twice as fast }
procedure SetMouseSensitivity(const X, Y, DoubleSpeed : Word);
function  MouseSensitivity(var X, Y : Word) : Word;

{ Returns the driver version, major in the high byte and minor in the
  low byte, and in Info the mouse type in the high byte and its IRQ in
  the low byte }
function  MouseDrvVersion(var Info : Word) : Word;

{ Set and return the video page the mouse cursor is shown on }
procedure SetMousePage(const Page : Byte);
function  MousePage : Byte;

{ Hides the mouse cursor while it is inside the rectangle, until the next
  ShowMouse }
procedure HideMouseIn(const X1, Y1, X2, Y2 : Word);

{ Set and return the language of the driver's messages }
procedure SetMessageLang(const Language : Byte);
function  MessageLang : Byte;

{ Returns the smallest and largest virtual coordinates; YMax is never set,
  since XMax is assigned twice }
procedure VirtualCoord(var XMin, YMin, XMax, YMax : Word);

implementation

uses WinDos;

var
  Reg : TRegisters;

function ResetMouse(const ResetType : TWare) : Word;
begin
  case ResetType of
    Hardware : Reg. AX := $0000; { function 0000H }
    Software : Reg. AX := $0021  { function 0021H }
  end;
  Intr(Int33, Reg);
  ResetMouse := Reg.AX;
  ButtonCount := Reg.BX
end;

procedure ShowMouse;
{ function 0001H }
begin
  Reg. AX := $0001;
  Intr(Int33, Reg)
end;

procedure HideMouse;
{ function 0002H }
begin
  Reg. AX := $0002;
  Intr(Int33, Reg)
end;

function MouseState(var X, Y : Word) : Word;
{ function 0003H }
begin
  Reg. AX := $0003;
  Intr(Int33, Reg);
  MouseState := Reg. BX;
  X := Reg. CX;
  Y := Reg. DX
end;

procedure MouseTo(const X, Y : Word);
{ function 0004H }
begin
  Reg. AX := $0004;
  Reg. CX := X;
  Reg. DX := Y;
  Intr(Int33, Reg)
end;

function MousePressed(const Button : Word ; var No, X, Y : Word) : Word;
{ function 0005H }
begin
  Reg. AX := $0005;
  Reg. BX := Button;
  Intr(Int33, Reg);
  MousePressed := Reg. AX;
  No := Reg. BX;
  X := Reg. CX;
  Y := Reg. DX
end;

function MouseReleased(const Button : Word ; var No, X, Y : Word) : Word;
{ function 0006H }
begin
  Reg. AX := $0006;
  Reg. BX := Button;
  Intr(Int33, Reg);
  MouseReleased := Reg. AX;
  No := Reg. BX;
  X := Reg. CX;
  Y := Reg. DX
end;

procedure MouseXRange(const Min, Max : Word);
{ function 0007H }
begin
  Reg. AX := $0007;
  Reg. CX := Min;
  Reg. DX := Max;
  Intr(Int33, Reg)
end;

procedure MouseYRange(const Min, Max : Word);
{ function 0008H }
begin
  Reg. AX := $0008;
  Reg. CX := Min;
  Reg. DX := Max;
  Intr(Int33, Reg)
end;

procedure MouseMotion(var X, Y : Integer);
{ function 000BH }
begin
  Reg. AX := $000B;
  Intr(Int33, Reg);
  X := Reg. CX;
  Y := Reg. DX
end;

procedure LightPen(const Option : Boolean);
begin
  case Option of
    True : Reg. AX := $000D;{ function 000DH }
    False: Reg. AX := $000E { function 000EH }
  end;
  Intr(Int33, Reg)
end;

procedure SetMouseSensitivity(const X, Y, DoubleSpeed : Word);
{ function 001AH }
begin
  Reg. AX := $001A;
  Reg. BX := X;
  Reg. CX := Y;
  Reg. DX := DoubleSpeed;
  Intr(Int33, Reg)
end;

function MouseSensitivity(var X, Y : Word) : Word;
{ function 001BH }
begin
  Reg. AX := $001B;
  Intr(Int33, Reg);
  X := Reg. BX;
  Y := Reg. CX;
  MouseSensitivity := Reg. DX;
end;

function MouseDrvVersion(var Info : Word) : Word;
{ function 0024H }
begin
  Reg. AX := $0024;
  Intr(Int33, Reg);
  MouseDrvVersion := Reg. BX;
  Info := Reg. CX
end;

procedure SetMousePage(const Page : Byte);
{ function 001DH }
begin
  Reg. AX := $001D;
  Reg. BX := Page;
  Intr(Int33, Reg)
end;

function MousePage : Byte;
{ function 001EH }
begin
  Reg. AX := $001E;
  Intr(Int33, Reg);
  MousePage := Reg. BX
end;

procedure HideMouseIn(const X1, Y1, X2, Y2 : Word);
{ function 0010H }
begin
  Reg. AX := $0010;
  Reg. CX := X1;
  Reg. DX := Y1;
  Reg. SI := X2;
  Reg. DI := Y2;
  Intr(Int33, Reg)
end;

procedure SetMessageLang(const Language : Byte);
{ function 0022H }
begin
  Reg. AX := $0022;
  Reg. BX := Language;
  Intr(Int33, Reg)
end;

function MessageLang : Byte;
{ function 0023H }
begin
  Reg. AX := $0023;
  Intr(Int33, Reg);
  MessageLang := Reg. BX
end;

procedure VirtualCoord(var XMin, YMin, XMax, YMax : Word);
begin
  Reg. AX := $0031;
  Intr(Int33, Reg);
  XMin := Reg. AX;
  YMin := Reg. BX;
  XMax := Reg. CX;
  XMax := Reg. DX
end;

begin
  case ResetMouse(Hardware) of
    $0000 : MouseDrvInstalled := False;
    $FFFF : MouseDrvInstalled := True
  end;
end.
