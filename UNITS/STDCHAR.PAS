{*******************************************************}
{                                                       }
{    The Hello World Writer's Turbo Pascal Library      }
{    Char-Oriented Routines Unit                        }
{                                                       }
{    Copyright (c) 1995-2026 The Hello World Writer     }
{                                                       }
{*******************************************************}

unit StdChar;

interface

type
  PXChar = ^Char;

type
  TCharSet = set of Char;

type
  PCharSet  = ^TCharSet;

{ Decimal and hexadecimal digits, indexed by value }
const
  Digits : array[0..9] of Char = '0123456789';

const
  HexDigits : array [0..$F] of Char = '0123456789ABCDEF';

{ The characters of a hexadecimal number, in either case }
const
  HexDigitsSet : set of '0'..'z' = ['0'..'9', 'A'..'F', 'a'..'f'];

implementation

end.
