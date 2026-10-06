# Aero Mix

Garmin Connect IQ watch face for Fenix 7 (260 x 260).

![Preview](resources/drawables/aero-mix.png)

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
- resources/: shared artwork, fonts, strings, and original background layers retained as build inputs.
- resources-fenix7/: single opaque background bitmap and its resource declaration.
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

- resources/drawables/background-alt.png: bottom layer.
- resources/drawables/background1.png: top layer, composited using its alpha channel.

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
