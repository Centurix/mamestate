mamestate
=========

This LUA script is used in MAME to detect various game states on a select number of games
supported by MAME. Currently, the script recognised the following state changes:

* One credit
* More than one credit
* Game in play
* Game over
* Hi score beaten

Usage
=====

When starting MAME, use the -autoboot_script parameter:

mame -autoboot_script /path/to/attract.lua pacman

Notes
=====

There are 'drivers' for each game in the states directory. These are LUA classes that export
various functions which detect these states in the game. States are scanned once a second so
as not to tie up the emulator with long operations.

Currently there is a short list of common 8 bit games supported, such as Pacman, Dig Dug, Galaga etc.
but finding these states in the games isn't too hard with a bit of basic knowledge in how these older
systems ran. Knowledge in z80/6800/6502/8080 isn't necessary, but an idea of how paged memory banks work
is a plus.

Current versions of MAME contain a fairly robust debugger and memory inspection tool. This can be used
to peek at current memory locations to find things that change under certain circumstances. This script
basically just reads critical memory addresses to find state data, including hi score and current player
score. Most 8 bit systems use varieties of Binary Coded Decimal (BCD) to score numbers, so some of the
'drivers' have BCD to decimal converters.

Some memory locations, such as hi scores and the number of lives can be found in the hiscore plugin and
also the cheat database plugin. Things like the number of credits in the system will have to be found
by scanning memory while inserting credits.

This project is in early stages and is basically used to talk to another of my repositories which runs
on an Arduino Mega 2560 to control LEDs, a NeoPixel 32x8 panel and a solenoid which rings a bell
when the hiscore is beaten in a game.

This script also has a small Python script called chatter.py which transmits a PNG based marquee image
across the serial port to the Arduino, which then displays the image on the NeoPixel panel.

In the future, I'll probably split out the state changes into different types of output drivers. Dunno.

Have fun!