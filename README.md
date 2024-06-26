# YieArDS V0.1.6

This has now been superseded by <https://github.com/FluBBaOfWard/K80DS>.

This is a Yie Ar Kung-Fu - Arcade emulator for the NDS.

## How to use

1. Create a "acDS" directory either in the root of your card or in the data
directory (eg h:\data\acds). This is where settings and save files end up.
2. Now put yiear.zip/yiear2.zip into a folder where you have (arcade) roms.
3. Depending on your flashcart you might have to DLDI patch the emulator.

When the emulator starts, you can either press L+R or tap on the screen to open
up the menu (the emulator tries to load "Yie Ar Kung-Fu" automagically on startup).
Now you can use the cross or touchscreen to navigate the menus, A or double tap
to select an option, B or the top of the screen to go back a step.

To select between the tabs use R & L or the touchscreen.

## Menu

### File

* Load Game: Select a game to load.
* Load State: Load a previously saved state for the currently running game.
* Save State: Save a state for the current game.
* Save Settings: Save the current settings.
* Reset Game: Reset the currently running game.

### Options

* Controller:
  * Autofire: Select if you want autofire.
  * Controller: 2P start a 2 player game.
  * Swap A/B: Swap which NDS button is mapped to which arcade button.
* Display:
  * Display: Here you can select if you want scaled or unscaled screenmode.
   Unscaled mode:  L & R buttons scroll the screen up and down.
  * Scaling: Here you can select if you want flicker or barebones lineskip.
  * Gamma: Lets you change the gamma ("brightness").
* Settings:
  * Speed: Switch between speed modes.
    * Normal: Game runs at it's normal speed.
    * 200%: Game runs at double speed.
    * Max: Game runs at 4 times normal speed (might change this in the future).
    * 50%: Game runs at half speed.
  * Autoload State: Toggle Savestate autoloading.
   Automagically load the savestate associated with the selected game.
  * Autosave Settings: This will save settings when leaving menu if any changes are made.
  * Autopause Game: Toggle if the game should pause when opening the menu.
  * Powersave 2nd Screen: If graphics/light should be turned off for the
   GUI screen when menu is not active.
  * Emulator on Bottom: Select if top or bottom screen should be used for
   emulator, when menu is active emulator screen is allways on top.
  * Autosleep: Doesn't work.
* Debug:
  * Debug Output: Show an FPS meter for now.
  * Disable Background: Turn on/off background rendering.
  * Disable Sprites: Turn on/off sprite rendering.
  * Step Frame: Emulate one frame.
* Dipswitches: Lot of settings for the actual arcade game, difficulty/lives etc.

### About

Some dumb info about the game and emulator...

## Credits

```text
Huge thanks to Loopy for the incredible PocketNES, without it this emu would
probably never have been made.
Thanks to:
Dwedit for help and inspiration with a lot of things.
Nicola Salmoria, for the MAME driver.
More MAME people + Maxim for the SN76496 info.
```

Fredrik Ahlström

X/Twitter @TheRealFluBBa

<https://www.github.com/FluBBaOfWard>
