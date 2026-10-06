# Aero Mix

Garmin Connect IQ watch face for Fenix 7 (260 x 260).

![Preview](resources/drawables/aero-mix.png)

## Structure

The project follows Class L's shared-source and device-configuration organization:

- source/WatchFaceApp.mc: application entry point.
- source/WatchFaceView.mc: lifecycle, layout binding, buffered rendering, and data synchronization.
- source/MainTimer.mc: shared animation timer; stopped when hidden or asleep.
- source/PartialDelegate.mc: partial-update power budget delegate.
- source/PidController.mc: seconds-hand motion controller.
- source/srv.clock.mc, srv.seconds.mc, srv.weather.mc: Aero Mix drawable implementations. Class names are retained for XML layout bindings.
- source/srv.mc: shared math and sensor-history graph helpers.
- source/srv.arcGraph.mc: shared arc graph and indicator rendering for pressure and heart rate.
- source/src.heartRate.mc: heart-rate label, history data, and rendering (srv.heartRate module).
- source/src.barometer.mc: pressure history, label, and arc rendering (srv.barometer module).
- source/srv.battery.mc: battery complication state, percentage, textured gauge, and solar charging indicator.
- source/srv.digital.mc: digital hour/minute labels, font setup, formatting, and rendering.
- source/srv.calendar.mc: weekday, month, and date labels, font setup, Sunday coloring, and rendering.
- source/src.moonPhase.mc: moon-phase calculation, tile selection, artwork, and rendering (srv.moonPhase module).
- source/srv.twilight.mc: sunrise/sunset state, day/night phase selection, arc rendering, and phase artwork.
- source-fenix7-260x260/cfg.mc: device buffer dimensions, clock center, and partial-update clip.
- resources/: Aero Mix artwork, fonts, strings, and XML layout.
- monkey.jungle: explicit shared source, resource, and Fenix 7 configuration paths.

Aero Mix retains its artwork, application identity, supported device, PID tuning, and layered renderer. Class L's other device configurations and artwork are specific to its design and are not included.

## Build

Use the installed Connect IQ SDK's monkeyc command with a local developer key:

    monkeyc -f monkey.jungle -d fenix7 -y <developer-key.der> -o bin/aero-mix.prg

Validated with Connect IQ SDK 9.2.0 for fenix7_sim. Simulator rendering has not been verified.
