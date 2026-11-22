# Fire of War — Map implementation

## Visual direction
- Godot 4, 2D, strict top-down camera.
- Pure black background outside the selected geographic coverage.
- Neutral, data-driven administrative boundaries for Ukraine and Russia.
- No neighboring countries rendered.
- Touch pan, pinch zoom, tap-to-inspect regions.

## Data and rendering
Use a versioned GeoJSON dataset for first-level administrative divisions (ADM1). Preserve source attribution and dataset version in `assets/maps/SOURCES.md`. Keep geographic source data separate from rendering code. Project longitude/latitude into a local 2D map coordinate system, simplify geometry at multiple zoom levels, and draw country outlines and internal administrative boundaries as separate visual layers.

## Mobile interaction
Use a Camera2D for pan and zoom. Support one-finger drag and two-finger pinch, clamp zoom to readable limits, and keep UI controls in a CanvasLayer. Keep all map geometry in a single map-space coordinate system.

## Data integrity
Treat disputed or changing administrative status neutrally in labels and metadata. Do not imply a political determination through styling. Verify geometry coverage, feature counts, invalid polygons, and attribution before release.

## First milestone
A runnable Godot scene that loads the checked-in GeoJSON, draws both countries and their ADM1 boundaries on black, and supports touch navigation.