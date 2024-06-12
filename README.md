# Final Fantasy 1 Minimap Emulator Script

![](https://raw.githubusercontent.com/BrianCumminger/FF1_Minimap/master/screenshot.png)

## Description
A .lua script for use with BizHawk for providing a window containing a representation of the world map and optionally a bounding box of the current player location.  Supports randomizers and romhacks that keep the map pointer table in the same rom location.

The "fog of war" map unveiling state is saved to userdata, which is stored in save states, but is also restored if the script is stopped and started again.

Also makes for a nice overworld visualization tool.

## License

Public Domain