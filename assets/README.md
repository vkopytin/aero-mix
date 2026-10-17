# Source and reference assets

These files are preserved for editing and reference and are excluded from Garmin runtime resource paths.

- source/: original background layers and currently unused artwork.
- reference/: screenshots and previews, including the widget issue image.
- unused-fonts/: unused font descriptions and their bitmap pages.

Run tools/build-background.py after changing source/background-alt.png or source/background1.png, then tools/build-fenix6-assets.py to refresh Fenix 6 tiles.

Runtime bitmap hands and full atlases live in resources-fenix7/. The Fenix 6 generator reads those files and produces device-specific tiles/geometry in resources-fenix6/. Active fonts remain shared in resources/fonts/.
