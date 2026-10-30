{*******************************************************}
{                                                       }
{    The Hello World Writer's Turbo Pascal Library      }
{    File-Handling Routines Unit                        }
{                                                       }
{    Copyright (c) 1995-2026 The Hello World Writer     }
{                                                       }
{*******************************************************}

unit FilLib;

interface

uses Dos;

type
  String6 = string[6];

{ The DOS or I/O error from the last CanSetFAttr or DirEntries }
const
  IntError: Integer = 0;

{ Returns True if Name matches the DOS wildcard Card, where * matches up
  to the next dot and ? any one character; case-sensitive }
function WildCardMatch(const Name, Card: PathStr): Boolean;

{ Returns the attributes as the letters ARSHDV, with a dot for each one
  not set }
function FormatAttr(const Attr: Word): String6;

{ Returns True if a file matches Fil and Attr, with the match in F }
function FindFile(const Fil: PathStr; const Attr: Word; var F: SearchRec)
                                                               : Boolean;

{ Returns True if a file matches Fil and Attr }
function FileExists(const Fil: PathStr; const Attr: Word): Boolean;

{ Open Fil as an untyped or a text file and close it again; return the
  IOResult, 0 when it opened }
function StdReset(const Fil: PathStr): Integer;
function TextReset(const Fil: PathStr): Integer;

{ Create Fil as an untyped or a text file, emptying it if it exists, and
  close it again; return the IOResult, 0 when it was created }
function StdRewrite(const Fil: PathStr): Integer;
function TextRewrite(const Fil: PathStr): Integer;

{ Sets the attributes of Fil to Attr and returns the DosError; Result is
  True if they changed or already were Attr, and CheckOnly restores the
  old ones; exits with IntError set if the attributes cannot be read }
function CanSetFAttr(const Fil: PathStr; const Attr: Word; const CheckOnly
                                  :Boolean; var Result: Boolean): Integer;

{ Erases Fil and returns the IOResult, 0 when it was erased }
function CanErase(const Fil: PathStr): Integer;

{ Return the directory, name and extension of Fil, as FSplit splits it;
  the extension includes its dot }
function Dir(const Fil: PathStr): DirStr;
function Name(const Fil: PathStr): NameStr;
function Ext(const Fil: PathStr): ExtStr;

{ Returns True for the extensions .EXE, .COM and .BAT, in upper case }
function IsExecutable(const Fil: PathStr): Boolean;

{ Changes to Path and returns the IOResult, 0 when it exists; CheckOnly
  changes back }
function PathExists(const Path: DirStr; const CheckOnly: Boolean): Integer;

{ Returns the number of entries in Path, not counting . and ..; exits with
  IntError set if Path cannot be entered }
function DirEntries(const Path: DirStr): Word;

{ Returns True if Dir holds no entries other than . and .. }
function EmptyDir(const Dir : DirStr) : Boolean;

implementation

function WildCardMatch(const Name, Card: PathStr): Boolean;
var
  I, J: Byte;
begin
  WildCardMatch := False;
  J := 1;
  I := 1;
  while J <= Length(Card) do
    case Card[J] of
      '*': begin
              while (J <= Length(Card)) and (Card[J] <> '.') do Inc(J);
              while (I <= Length(Name)) and (Name[I] <> '.') do Inc(I)
            end;
      '?': begin
              Inc(J);
              Inc(I)
            end;
      '.': begin
              if I <= Length(Name) then
                if Name[I] <> '.' then Exit
                                  else Inc(I);
              Inc(J)
            end;
    else
      if (I > Length(Name)) or (Card[J] <> Name[I]) then Exit;
      Inc(I);
      Inc(J)
    end;
  WildCardMatch := (I > Length(Name)) and (J > Length(Card))
end;

function FormatAttr(const Attr: Word): String6;
var
  S: String6;
begin
  S := '......';
  if Attr and Archive = Archive then S[1] := 'A';
  if Attr and ReadOnly = ReadOnly then S[2] := 'R';
  if Attr and SysFile = SysFile then S[3] := 'S';
  if Attr and Hidden = Hidden then S[4] := 'H';
  if Attr and Directory = Directory then S[5] := 'D';
  if Attr and VolumeID = VolumeID then S[6] := 'V';
  FormatAttr := S
end;

function FindFile(const Fil: PathStr; const Attr: Word; var F: SearchRec)
                                                               : Boolean;
begin
  FindFirst(Fil, Attr, F);
  FindFile := DosError = 0
end;

function FileExists(const Fil: PathStr; const Attr: Word): Boolean;
var
  F : SearchRec;
begin
  FindFirst(Fil, Attr, F);
  FileExists := DosError = 0
end;

function StdReset(const Fil: PathStr): Integer;
var
  F: file;
  Temp: Integer;
begin
  Assign(F, Fil);
  {$I-}
  Reset(F);
  {$I+}
  Temp := IOResult;
  StdReset := Temp;
  if Temp = 0 then Close(F)
end;

function TextReset(const Fil: PathStr): Integer;
var
  F: Text;
  Temp: Integer;
begin
  Assign(F, Fil);
  {$I-}
  Reset(F);
  {$I+}
  Temp := IOResult;
  TextReset := Temp;
  if Temp = 0 then Close(F)
end;

function StdRewrite(const Fil: PathStr): Integer;
var
  F: file;
  Temp: Integer;
begin
  Assign(F, Fil);
  {$I-}
  Rewrite(F);
  {$I+}
  Temp := IOResult;
  StdRewrite := Temp;
  if Temp = 0 then Close(F)
end;

function TextRewrite(const Fil: PathStr): Integer;
var
  F: Text;
  Temp: Integer;
begin
  Assign(F, Fil);
  {$I-}
  Rewrite(F);
  {$I+}
  Temp := IOResult;
  TextRewrite := Temp;
  if Temp = 0 then Close(F)
end;

function CanSetFAttr(const Fil: PathStr; const Attr: Word; const CheckOnly
                                 : Boolean; var Result: Boolean): Integer;
var
  F: file;
  Temp: Integer;
  Attr1, Attr2: Word;
begin
  IntError := 0;
  Assign(F, Fil);
  GetFAttr(F, Attr1);
  IntError := DosError;
  if IntError <> 0 then Exit;
  SetFAttr(F, Attr);
  Temp := DosError;
  CanSetFAttr := Temp;
  GetFAttr(F, Attr2);
  IntError := DosError;
  if IntError <> 0 then Exit;
  Result := (Attr1 <> Attr2) or ((Attr1 = Attr2 ) and (Attr = Attr1));
  if ((Temp = 0) or (Result = True )) and (CheckOnly = True) then
    SetFAttr(F, Attr1)
end;

function CanErase(const Fil: PathStr): Integer;
var
  F: file;
begin
  Assign(F, Fil);
  {$I-}
  Erase(F);
  {$I+}
  CanErase := IOResult
end;

function Dir(const Fil: PathStr): DirStr;
var
  D: DirStr;
  N: NameStr;
  E: ExtStr;
begin
  FSplit(Fil, D, N, E);
  Dir := D
end;

function Name(const Fil: PathStr): NameStr;
var
  D: DirStr;
  N: NameStr;
  E: ExtStr;
begin
  FSplit(Fil, D, N, E);
  Name := N
end;

function Ext(const Fil: PathStr): ExtStr;
var
  D: DirStr;
  N: NameStr;
  E: ExtStr;
begin
  FSplit(Fil, D, N, E);
  Ext := E
end;

function IsExecutable(const Fil: PathStr): Boolean;
begin
  IsExecutable := (Ext(Fil) = '.EXE') or (Ext(Fil) = '.COM')
                   or (Ext(Fil) = '.BAT')
end;

function PathExists(const Path: DirStr; const CheckOnly: Boolean): Integer;
var
  D: DirStr;
  Temp: Integer;
begin
  GetDir(0, D);
  {$I-}
  ChDir(Path);
  {$I+}
  Temp := IOResult;
  PathExists := Temp;
  if (Temp = 0) and (CheckOnly = True) then ChDir(D)
end;

function DirEntries(const Path: DirStr): Word;
var
  Count: Word;
  F: SearchRec;
  Dir: DirStr;
begin
  Count := 0;
  IntError := 0;
  GetDir(0, Dir);
  {$I-}
  ChDir(Path);
  {$I+}
  IntError := IOResult;
  if IntError <> 0 then Exit;
  FindFirst('*.*', AnyFile, F);
  while DosError = 0 do
  begin
    if (F.Name <> '.') and (F.Name <> '..') then
      Count := Count + 1;
    FindNext(F)
  end;
  DirEntries := Count;
  ChDir(Dir)
end;

function EmptyDir(const Dir : DirStr) : Boolean;
var
  Empty  : Boolean;
  CurDir : DirStr;
  D      : SearchRec;
begin
  GetDir(0, CurDir);
  ChDir(Dir);
  Empty := True;
  FindFirst('*.*', AnyFile, D);
  while (DosError = 0) and Empty do
  begin
    if (D.Name <> '.') and (D.Name <> '..') then
      Empty := False;
    FindNext(D)
  end;
  EmptyDir := Empty;
  ChDir(CurDir)
end;

end.
