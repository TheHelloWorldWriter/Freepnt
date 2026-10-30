======================================================================

  Freepnt v1.0.0
  Free Paint 1.0, a mouse-driven paint program for VGA

  Copyright (c) 1995-2026 The Hello World Writer

======================================================================

ABOUT

  I wrote Free Paint in October 1995 in Borland Turbo Pascal 7, while
  I was learning how to use the mouse and the BGI graphics mode. It
  paints in 640x480 with the 16 VGA colors, and comes with a viewer
  for the pictures it saves.

FILES

  FREEPNT.EXE    The editor
  FREEPNTV.EXE   The viewer
  EGAVGA.BGI     Borland's graphics driver, loaded at startup
  FIREWORK.FE1   A sample picture

  Keep them together in one directory, and run the programs from it.

HOW TO RUN

  On MS-DOS or compatible, with a mouse driver loaded, run:

    FREEPNT FIREWORK      to paint over the sample picture
    FREEPNTV FIREWORK     to view it

  Any other name opens that picture, or starts a new one. The .FE1
  extension is added when you leave it out.

  On a modern system (Windows, macOS, Linux), use DOSBox Staging:

    https://www.dosbox-staging.org

  Mount the directory containing the files and run them from the DOS
  prompt.

CONTROLS

  Hold a mouse button over the picture to paint, and click the
  control bar below it:

    Color strip     Select one of the 16 colors
    Brushes 1-9     Select the brush size
    Clear Image     Fill the picture with the selected color
    Save            Save the picture
    Quit, Q         Quit, asking to save if the picture changed

  In the viewer, press Q to quit.

THINGS TO KNOW

  The brush is stamped each time the mouse is read, with nothing in
  between, so fast strokes break into separate dabs.

  Starting the editor on a new file creates it right away. Quit
  without saving, and it stays behind empty and cannot be opened.
  Delete it to use the name again.

SOURCE CODE

  Full source code is available on GitHub under the MIT License:

    https://github.com/TheHelloWorldWriter/Freepnt

LICENSE

  MIT License -- see LICENSE.TXT for the full text.

======================================================================
  The Hello World Writer
  https://www.thehelloworldwriter.com
======================================================================
