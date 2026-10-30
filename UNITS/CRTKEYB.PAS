{*******************************************************}
{                                                       }
{    The Hello World Writer's Turbo Pascal Library      }
{    Keyboard Crt-Oriented Routines Unit                }
{                                                       }
{    Copyright (c) 1995-2026 The Hello World Writer     }
{                                                       }
{*******************************************************}

unit CRTKeyb;

interface

uses StdChar;

{ A key as two bytes, for client code, since no routine here uses it;
  for an extended key Code is 0 and ExtCode is its scan code }
type
  KeyRec = record
    Code, ExtCode : Byte
  end;

{ Keys that answer a yes/no question }
const
  YesNoKeys = [ 'y', 'Y', 'n', 'N' ];

{ Accepts any key in KeyInRange and ExtKeyInRange }
const
  AnyKey = [];

{ The last key read by ReadAKey, as its C and Ch }
var
  LastKey, LastExtKey : Char;

{ Waits for a key; for an extended key C is #0 and Ch is its scan code,
  otherwise Ch keeps its value }
procedure ReadAKey(var C, Ch : Char);

{ Discards any keys waiting in the keyboard buffer }
procedure ClrKbd;

{ Waits for a key in K and returns it; AnyKey accepts any key that is
  not an extended key }
function  KeyInRange(const K : TCharSet) : Char;

{ Waits for an extended key whose scan code is in K and returns the scan
  code; AnyKey accepts any extended key }
function  ExtKeyInRange(const K : TCharSet) : Char;

{ Returns True if a key is waiting and it is Key; the key is removed
  even when it does not match }
function  IsKey(const Key : Char) : Boolean;

{ Returns True if a key is waiting and it is the extended key with scan
  code Key; the key is removed even when it does not match }
function  IsExtKey(const Key : Char) : Boolean;

implementation

uses Crt;

procedure ReadAKey(var C, Ch : Char);
begin
  C := ReadKey;
  if C = #0 then Ch := ReadKey;
  LastKey := C;
  LastExtKey := Ch
end;

procedure ClrKbd;
var
  C, Ch : Char;
begin
  while KeyPressed do ReadAKey(C, Ch)
end;

function KeyInRange(const K : TCharSet) : Char;
var
  C, Ch: Char;
begin
  repeat
    ReadAKey(C, Ch)
  until (C in K) or ((K = AnyKey) and (C <> #0));
  KeyInRange := C
end;

function ExtKeyInRange(const K : TCharSet) : Char;
var
  C, Ch: Char;
begin
  repeat
    ReadAKey(C, Ch)
  until (Ch in K) or ((K = AnyKey) and (C = #0));
  ExtKeyInRange := Ch
end;

function IsKey(const Key : Char) : Boolean;
var
  C, Ch : Char;
begin
  IsKey := False;
  if KeyPressed then
  begin
    ReadAKey(C, Ch);
    if C = Key then IsKey := True
  end;
end;

function IsExtKey(const Key : Char) : Boolean;
var
  C, Ch : Char;
begin
  IsExtKey := False;
  if KeyPressed then
  begin
    ReadAKey(C, Ch);
    if (Ch = Key) and (C = #0) then IsExtKey := True
  end;
end;

end.
