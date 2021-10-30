# oreveins
A node which produces ores for Minetest

* [Github Repo](https://github.com/Beanzilla/oreveins)

## Disclamer

This mod uses textures from other mods/games with an overlay on top of them.

![screenshot](screenshot.png)

## What's in the box

* Public [API](API.md) for registering your mod's ores so your mod's ores can have oreveins too.
* Simplistic node which uses a node timer to "generate" ores in a radius around itself.

## Usage

For optimal performance of a orevein place a block down then place the orevein,
 on top then break the block under the orevein,
 make sure there is a 3x3x3 space with the orevein in the middle of that.

![usage](usage.gif)

## Mods Supported

* MTG ([default](https://github.com/minetest/minetest_game))
* MCL2 ([mcl_core](https://git.minetest.land/MineClone2/MineClone2)) and MCL5 ([mcl_core](https://git.minetest.land/MineClone5/MineClone5))
* MTG EXTERN ([technic](https://github.com/minetest-mods/technic)) \*
* MTG EXTERN ([moreores](https://github.com/minetest-mods/moreores)) \*

\* These mods are not directly part of a game but I added support for anyway (They can be game specific, I.E. Technic only works in MTG)
