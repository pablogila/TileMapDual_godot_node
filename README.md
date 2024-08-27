# TileMapDual Node

Introducing TileMapDual, a custom TileMapLayer node
which provides a real-time, in-editor dual-grid tileset system for Godot.
This reduces the number of tilesets required from 47 to just 15,
which greatly speeds up your dev journey.

## Why?
Previous implementations of a dual-grid tileset system in Godot
(by [GlitchedInOrbit]((https://github.com/GlitchedinOrbit/dual-grid-tilemap-system-godot-gdscript)
and [jess-hammer]((https://github.com/jess-hammer/dual-grid-tilemap-system-godot))
used an inverted version of the official 16-tile template.
This is a potential source of headaches, and this release corrects that inversion.
This version also implements modern TileMapLayers instead of the deprecated TileMap node.
Finally, and most importantly, this release introduces the dual-grid system as a custom node
that runs within the editor, making it easy to integrate into your own projects.

## TO-DO
- STILL IN DEVELOPMENT
- Isometric support

## References
- [Dual grid Twitter post by Oskar Stålberg](https://x.com/OskSta/status/1448248658865049605)
- ['Programming Terrain Generation' video by ThinMatrix](https://www.youtube.com/watch?v=buKQjkad2I0)
- ['Drawing Fewer Tiles' video by jess:codes](https://www.youtube.com/watch?v=jEWFSv3ivTg)
