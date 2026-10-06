# Aero Mix

Garmin Connect IQ watch face for Fenix 7 (260 x 260).

![Preview](resources/drawables/aero-mix.png)

## Structure

The project follows Class L's shared-source and device-configuration organization:

- source/WatchFaceApp.mc: application entry point.
- source/WatchFaceView.mc: Class L Fenix 7 frame scheduling, one composed back buffer, display presentation, partial restoration, and data synchronization.
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
- resources/: Aero Mix artwork, fonts, strings, and XML layout for non-text drawables.
- monkey.jungle: explicit shared source, resource, and Fenix 7 configuration paths.

Aero Mix retains its artwork, application identity, supported device, PID tuning, and module draw order. Class L's other device configurations and artwork are specific to its design and are not included.

## Build

Use the installed Connect IQ SDK's monkeyc command with a local developer key:

    monkeyc -f monkey.jungle -d fenix7 -y <developer-key.der> -o bin/aero-mix.prg

Validated with Connect IQ SDK 9.2.0 for fenix7_sim. Simulator rendering has not been verified.

Text modules own strings and dynamic colors and render through dc.drawText. Fonts are cached during initialization. Text declarations have been removed from the runtime layout; cfg is now the source of text placement and styling. Existing custom fonts, draw order, and hidden energy-label visibility are retained.

The Fenix 7 rendering path follows Class L: engineTick composes a single off-screen bitmap and marks a frame pending; onUpdate presents that bitmap and draws the PID seconds hand separately. Timer ticks skip composition while a frame is pending. Sleeping updates compose synchronously. Partial updates restore the union of the old and new seconds-hand bounds from the composed bitmap, draw the next hand position, and wrap the partial second modulo 60. The background is present in the bitmap across the configured analog-clock clip so partial restoration erases the hand completely.
