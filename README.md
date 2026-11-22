# Fire of War

A mobile-first 2D project built with Godot 4. The first milestone is a neutral geographic map viewer with a strict top-down camera.

## Current map milestone

- Black background outside the selected map data.
- Ukraine and Russia ADM1 GeoJSON layers, loaded locally.
- Region outlines and subdued fills.
- One-finger map pan.
- Two-finger pinch zoom.
- Desktop mouse drag and wheel zoom for editor testing.
- Reset-view button.

## Open in Godot

1. Download or clone this repository.
2. Open Godot 4.x.
3. Choose **Import** and select this folder's `project.godot`.
4. Add the GeoJSON files described in `docs/MAP_DATA_SOURCES.md`.
5. Run the project (F6 for the map scene, or F5 for the main project).

## Map data status

The rendering code is committed, but the GeoJSON datasets are not bundled yet. See `docs/MAP_DATA_SOURCES.md` for source endpoints, data vintage, and licensing notes. The source metadata currently reports a 2017 vintage; do not interpret it as a verified present-day political boundary dataset.

## Technical notes

The map uses a Web Mercator-style projection for display. Source GeoJSON remains separate from rendering code so the dataset can be audited and replaced without changing the map controller.

Godot 4 documentation: https://docs.godotengine.org/en/4.4/tutorials/2d/custom_drawing_in_2d.html
