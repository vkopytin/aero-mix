# Aero Mix

Garmin Connect IQ watch face for Fenix 6 and Fenix 7 (260 x 260).

![Preview](cover.png)

# Description

This watch face is inspired by retro poster graphics, digital instruments and mechanical gadget panels. Information is arranged into small gauges, sectors and display blocks, turning the round watch screen into a miniature instrument console.
It combines analog and digital time in one layout. A compact analog clock displays hour, minute and second hands, while the main digital display provides quick time reading. A partially visible rotating seconds disc adds a mechanical-instrument feel to the interface.
The surrounding dashboard brings useful information together without losing the character of the design:

- Weather and temperature
- Date and weekday
- Barometric pressure
- Heart rate
- Steps
- Battery level
- Moon phase
- Day/night indication
- Analog and digital time
  The visual language uses large pixels, strong geometry, compact graphs and contrasting accents, inspired by retro digital displays and technical control panels. Instead of trying to hide information behind a minimal interface, the watch face celebrates it: every metric becomes another little instrument on the dial.
  Designed primarily around the 260 × 260 round Garmin display, with an emphasis on readability, efficient rendering and the distinctive character of a tiny wearable dashboard.

## Structure

The project follows Class L's shared-source and device-configuration organization:

- source/WatchFaceApp.mc: application entry point.
- source/WatchFaceView.mc: Class L Fenix 7 frame scheduling, one composed back buffer, display presentation, partial restoration, and data synchronization; no runtime layout or retained background drawable.
- source/MainTimer.mc: shared animation timer; stopped when hidden or asleep.
- source/PartialDelegate.mc: partial-update power budget delegate.
- source/PidController.mc: seconds-hand motion controller.
- source/srv.clock.mc: analog clock module with cached hand bitmaps and transforms; center, resources, and pivot offsets are configured in cfg.
- source/srv.seconds.mc: seconds-hand module, PID state, canonical/partial seconds, and direct bitmap rendering; geometry is configured in cfg.
- source/srv.weather.mc: weather module with cached conditions, sprite rendering, and direct temperature text rendering; placement and color are configured in cfg.
- source/srv.mc: shared math and sensor-history graph helpers.
- source/srv.arcGraph.mc: shared arc graph and indicator rendering for pressure and heart rate.
- source/srv.heartRate.mc: heart-rate label, history data, and rendering (srv.heartRate module).
- source/srv.barometer.mc: pressure history, label, and arc rendering (srv.barometer module).
- source/srv.battery.mc: battery complication state, percentage, textured gauge, and solar charging indicator.
- source/srv.digital.mc: digital time and Bluetooth/alarm/vibration state, formatting, and direct text rendering.
- source/srv.steps.mc: step count, static label, and history graph.
- source/srv.energy.mc: Body Battery text and visibility.
- source/srv.calendar.mc: weekday, month, and date labels, font setup, Sunday coloring, and rendering.
- source/srv.moonPhase.mc: moon-phase calculation, tile selection, artwork, and rendering (srv.moonPhase module).
- source/srv.twilight.mc: sunrise/sunset state, day/night phase selection, arc rendering, and phase artwork.
- source-fenix7-260x260/cfg.mc: device geometry and text positions, colors, justification, visibility, and initial values migrated from the original XML labels.
- resources/: shared launcher/battery artwork, active fonts, and strings.
- resources-fenix7/: Fenix 7 background, bitmap hands, indicator, and weather/moon/day-night atlases.
- resources-fenix6/: Fenix 6 background/sprite tiles and polygon geometry.
- assets/source/: original background layers and unused artwork, excluded from runtime resources.
- assets/unused-fonts/: unused fonts and their image pages, preserved outside runtime resources.
- assets/reference/: previews and diagnostic screenshots.
- source-fenix7-260x260/lib.mc: direct background rendering with on-demand resource loading, matching Class L Fenix 7.
- tools/build-background.py: rebuilds the background from the original layers and verifies identical pixels (requires Pillow).
- monkey.jungle: explicit shared source, resource, and Fenix 7 configuration paths.

Aero Mix retains its artwork, application identity, supported device, PID tuning, and module draw order. Class L's other device configurations and artwork are specific to its design and are not included.

## Build

Use the installed Connect IQ SDK's monkeyc command with a local developer key:

    monkeyc -f monkey.jungle -d fenix7 -y <developer-key.der> -o bin/aero-mix.prg

Validated with Connect IQ SDK 9.2.0 for fenix7_sim. Simulator rendering has not been verified.

Text modules own strings and dynamic colors and render through dc.drawText. Fonts are cached during initialization. Text declarations have been removed from the runtime layout; cfg is now the source of text placement and styling. Existing custom fonts, draw order, and hidden energy-label visibility are retained.

The Fenix 7 rendering path follows Class L: engineTick composes a single off-screen bitmap and marks a frame pending; onUpdate presents that bitmap and draws the PID seconds hand separately. Timer ticks skip composition while a frame is pending. Sleeping updates compose synchronously. Partial updates restore the union of the old and new seconds-hand bounds from the composed bitmap, draw the next hand position, and wrap the partial second modulo 60. The background is present in the bitmap across the configured analog-clock clip so partial restoration erases the hand completely.

Background rendering uses one precomposed 260 x 260 RGB bitmap in place of the two scaled background drawable layers. The unused foreground drawable is no longer included. lib.drawBackground loads the resource at draw time without a persistent bitmap reference, both for display presentation and clipped restoration in the composed buffer. Rebuild the asset with python tools/build-background.py after changing either original background layer. Runtime peak memory has not been measured in the simulator.

## Rebuilding the Fenix 7 background

Run this after editing either source image:

- assets/source/background-alt.png: bottom layer.
- assets/source/background1.png: top layer, composited using its alpha channel.

Both inputs must be 260 x 260 pixels. Their combined image must be fully opaque. The script preserves the inputs and overwrites resources-fenix7/background.png with a lossless RGB PNG.

From the repository root, use Python 3 with Pillow installed:

    python -m pip install Pillow
    python tools/build-background.py

Install Pillow only once for the Python environment you use. If your Windows installation uses the Python launcher, replace python with py in both commands.

In a Codex environment with the bundled dependencies, Pillow is already available. The current PowerShell command is:

    & 'C:/Users/volod/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tools/build-background.py

The bundled runtime path can change; ask Codex to locate its workspace dependencies if that path no longer exists. The script resolves input/output paths relative to its own location, so it can also be invoked by absolute path from another directory.

On success, it prints:

    Verified 260 x 260 background matches the original two-layer composition pixel for pixel.

It checks input dimensions, output opacity, and exact pixel equality after saving and reopening the generated image. Run Python normally, without the -O flag, so these assertions remain enabled.

If it fails:

- ModuleNotFoundError for PIL: install Pillow using the same Python executable that runs the script.
- FileNotFoundError: confirm both source PNGs exist at the paths above.
- AssertionError: check the input dimensions and combined opacity; a failure in the final check means the saved output differs from the expected composition.

After a successful run, rebuild the watch face using the command in the Build section and inspect it in the Fenix 7 simulator. Keep both edited source images and the generated background.png in the same change. The normal Monkey C build consumes the generated image and does not run this script automatically.

resources-fenix7/drawables.xml declares the generated image as Rez.Drawables.background. source-fenix7-260x260/lib.mc draws it for full-frame presentation and clipped restoration. Edit the source layers and regenerate rather than editing the generated background directly.

## Fenix 6 support

monkey.jungle selects source-fenix6-260x260 and resources-fenix6 for Fenix 6. Fenix 7 keeps its own source/resource helpers. The manifest includes both products and uses minimum API 3.2.0 for the older device.

The Fenix 6 path follows Class L's compatibility architecture:

- Gfx implements the software affine transform and older BufferedBitmap constructor.
- The composed buffer is 250 x 250, placed at (5, 5). Configuration and shared geometry account for that offset; the display seconds hand remains in screen coordinates.
- lib draws the background as sixteen 65 x 65 tiles loaded on demand.
- Hands and indicator artwork render as transformed polygon strips derived from the original images. The Fenix 6 assets use its 64-color palette and an alpha threshold of 128; Fenix 7 retains native transformed bitmaps.
- Weather, moon, and twilight artwork use individual cropped tiles, avoiding retained sprite atlases and unavailable bitmap-region APIs.
- Battery level comes from System.Stats. Sun times come from Weather using its observation location. Fenix 7 retains complication subscriptions.
- The battery gauge uses a clipped bitmap on Fenix 6 and the existing texture fill on Fenix 7.

After changing source artwork or sprite coordinates, regenerate assets in this order (Python 3 and Pillow):

    python tools/build-background.py
    python tools/build-fenix6-assets.py

The second script verifies that background tiles reconstruct the merged image exactly and that polygon strips match each hand's opaque, palette-reduced source pixels. It generates resources-fenix6/drawables.xml, geometry.xml, PNG tiles, and source-fenix6-260x260/lib.mc. Keep generated assets with their source changes; do not edit the generated lib.mc by hand.

Build each target in a separate output directory to avoid Connect IQ's generated-resource cache mixing device definitions:

    monkeyc -f monkey.jungle -d fenix6 -y <developer-key.der> -o bin/fenix6/aero-mix.prg
    monkeyc -f monkey.jungle -d fenix7 -y <developer-key.der> -o bin/fenix7/aero-mix.prg

Both simulator targets compile with SDK 9.2.0. Simulator visuals, partial-update power budget, and peak runtime memory still need device-level verification.

## Resource ownership

Both devices include resources/ plus their own device resource folder. Active custom fonts, strings, the launcher icon, and the battery artwork are shared. Bitmap hands and full sprite atlases are declared only for Fenix 7; Fenix 6 declares generated cropped tiles and polygon geometry instead.

The background generator reads assets/source/background-alt.png and background1.png and writes resources-fenix7/background.png. The Fenix 6 generator reads that merged background and the hand/atlas images in resources-fenix7/. Regenerate both asset sets when their inputs change. Fenix 7 images are build inputs for the Fenix 6 generator, but are not included in the Fenix 6 runtime resource path.

Original images, reference screenshots, and unused fonts remain under assets/ for future editing. They are outside every resourcePath in monkey.jungle, so the compiler does not package them.

### Fenix 6 memory strategy

The Fenix 6 compositor uses one 236 x 236 buffer with the default device palette.
Its origin is (12, 12), matching the previous background composition clip; the
static outer background is drawn directly to the display. Removing unused buffer
margins saves 6,804 bytes of pixel storage at eight bits per pixel.
No reduced palette is imposed on bitmap resources or the buffer, so the shared
antialiased status font remains enabled.

Text components load fonts during rendering and retain no font resources between
frames. A local font may serve multiple draw/measurement calls within one render
function. Mutable graph and phase arrays are initialized from resources/json.xml,
following Class L; updates reuse their points rather than replacing arrays.
Calendar lookup data is loaded from JSON only when updating the calendar.
Fenix 6 sprite selection uses numeric switch cases rather than a permanently
allocated dictionary with ninety string keys. Awake updates wait for a prepared
timer frame instead of redundantly refreshing all sensor data.

Hand geometry stores five integers per rectangle instead of nested point arrays.
The renderer loads a four-point JSON template and reuses it across strips, loading
only the current hand. The generator validates the geometry against the original
opaque, device-color source mask and writes readable, multiline XML.

Heart-rate and pressure graphs fold the newest 60 valid samples directly from
the sensor iterator, without a temporary sample array. Their recent range covers
this bounded window rather than the entire sensor archive. Unused graph conversion helpers have been removed.

Fenix 6 seconds rendering keeps Class L's cached JSON geometry and previous-position
clear-clip strategy, using two three-pixel yellow lines instead of a polygon.
Four pivot-relative endpoints restore the original needle (-110 to -8) and
counterweight (10 to 31), leaving the center clear. The clear clip includes stroke
width and the next clockwise six-degree step at the restored length.

The 1 Hz callback retains Class L's four-point bounds, buffer restoration,
transform update, draw, and modulo-60 advance without a new-position union,
rounding, or a final clearClip call. The secondsX/secondsY pivot is in screen
coordinates, while analogClockX/analogClockY refer to the offset composition
buffer.

The partial-update clip is transformed only once. The former transformMove was
always identity, so its second transform pass and its temporary point arrays
were removed without changing the clip coordinates or erase coverage.

Fenix 7 and FR255 use Class L's previous-position clip sequence, with the
bitmap-local hand offset applied after rotation. The widened initClip contains
both the old bitmap and its next clockwise six-degree step, plus edge padding.
This removes the second transform, per-frame old/new bounds loop, rounding,
and final clearClip. All devices use the same callback; their lib.mc seconds
renderers provide the device-specific drawing behavior.

Seconds rendering now follows Class L's device-specific lib.drawSecondsHand
interface. One shared onPartialUpdate restores the previous clip, updates the
pivot transform, draws through srv.seconds, and advances the tick. Fenix 6 lib
draws the two lines; Fenix 7/FR255 lib applies the bitmap offset and draws the
cached bitmap. The post-draw transform retains that offset for the next erase
clip. Full updates also seed the erase transform with the same offset.
The separate callback annotations and jungle exclusions are no longer needed.
