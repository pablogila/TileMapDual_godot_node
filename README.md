# TileMapDual Godot Node

Introducing TileMapDual, a custom TileMapLayer node
which provides a real-time, in-editor and in-game dual-grid tileset system for Godot.
This dual-grid system [proposed by Oskar Stålberg](https://x.com/OskSta/status/1448248658865049605) reduces the number of tiles required from 47 to just 15 (yes, fifteen!!), rocketing your dev journey!  

![](Docs/reference_dual.jpeg)

## Advantages

Using a dual-grid system has the following advantages:  
- Only [15](https://user-images.githubusercontent.com/47016402/87044518-ee28fa80-c1f6-11ea-86f5-de53e86fcbb6.png) tiles are required for autotiling, instead of [47](https://user-images.githubusercontent.com/47016402/87044533-f5e89f00-c1f6-11ea-9178-67b2e357ee8a.png)
- The tiles can have perfectly rounded corners
- The tiles align to the world grid

## Installation and usage

Just copy the `TileMapDual.gd` script to your project to start using the new custom node.  

You have to create a regular `TileMapLayer` with your own 2x2 tileset, following the [standard godot tileset](https://user-images.githubusercontent.com/47016402/87044518-ee28fa80-c1f6-11ea-86f5-de53e86fcbb6.png).
You just need to quickly sketch your level with the fully-filled tile, indicated here:

![](Docs/reference_tileset_standard.png)

Then, create a `TileMapDual` node and assign the `TileMapLayer` to it. Just click the `Update in Editor` checkbox, and the dual grid will be automatically configured and generated in real-time.
Any change in the `TileMapLayer` will be updated by simply clicking the checkbox again!  

You can also freeze the tileset by activating the `Freeze` checkbox, to avoid accidental updates, both in-editor and in-game.

![](Docs/demo.gif)

You can modify the dual tileset in-game by calling the following methods. An example is included in the custom `CursorDual` node, based on Jess's implementation.

- `fill_tile(world_cell)`: Fill the corresponding world tile and update the corresponding dual tiles.
- `erase_tile(world_cell)`: Erase the corresponding world tile and update the corresponding dual tiles.

Two more public methods are available if needed:

- `update_tile(world_cell)`: Update the displayed tiles around `world_tile`. This is the fastest method to upgrade specific cells.  
- `update_tileset()`: Update the entire tileset, offsetting itself by half a grid, and updating all tiles at once. This is what happens when you click the `Update in Editor` button.  

To achieve the best performance, only the fully-filled tile used for sketching in the World grid is used for autotiling in the `TileMapDual`. This approach allows the World tileset to be used for other purposes, such as having an extended tileset with rocks, etc.  

## Why?

Previous implementations of a dual-grid tileset system in Godot
by [GlitchedInOrbit](https://github.com/GlitchedinOrbit/dual-grid-tilemap-system-godot-gdscript)
and [jess:codes](https://github.com/jess-hammer/dual-grid-tilemap-system-godot)
used an inverted version of the official 16-tile template (although Jess's tileset is provided as an example in this repo).
This is a potential source of headaches, and this release corrects said inversion.  

This release also implements modern TileMapLayers instead of the deprecated TileMap node.  

Finally, and most importantly, this release simplifies the process by introducing the dual-grid system as a simple custom node that runs within the editor, making it easy to integrate into your own projects.  

## To-do

- Implement isometric support (ongoing)

## References

- [Dual grid Twitter post by Oskar Stålberg](https://x.com/OskSta/status/1448248658865049605)
- ['Programming Terrain Generation' video by ThinMatrix](https://www.youtube.com/watch?v=buKQjkad2I0)
- ['Drawing Fewer Tiles' video by jess:codes](https://www.youtube.com/watch?v=jEWFSv3ivTg)
- [jess:codes implementation in C#](https://github.com/jess-hammer/dual-grid-tilemap-system-godot)
- [GlitchedInOrbit implementation in GDScript](https://github.com/GlitchedinOrbit/dual-grid-tilemap-system-godot-gdscript)

## Feedback

Please feel free to contact me to provide feedback, suggestions, or improvements to this project.  
- [Twitter (@GilaPixel)](https://x.com/gilapixel)
- [Instagram (@GilaPixel)](https://www.instagram.com/gilapixel/)
- [Reddit (/u/pgilah)](https://www.reddit.com/u/pgilah/)
