import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.WatchUi;

import Toybox.Time;
using Toybox.Time.Gregorian as Date;

class WatchFaceView extends WatchUi.WatchFace {
    private var sleepMode = false;
    private var frameUpdatePending = false;
    private var buffer = null as Graphics.BufferedBitmap or Null;
    private var partialTransform = Gfx.createAffineTransform();
    private var transformMove = Gfx.createAffineTransform();
    private var drawPartialOptions = { :transform => self.partialTransform };

    function initialize() {
        WatchFace.initialize();
        MainTimer.initialize(self);
        Gfx.registerComplications(method(:updateComplication));
        self.subscribeToComplications();
    }

    function onLayout(dc as Graphics.Dc) as Void {
        srv.clock.initialize();
        srv.seconds.initialize();
        srv.battery.initialize();
        srv.arcGraph.initialize();
        self.buffer = Gfx.createBufferedBitmap({ :width => cfg.bufferWidth, :height => cfg.bufferHeight });
        self.frameUpdatePending = false;
    }

    function onShow() as Void {
        self.syncData();
        MainTimer.nextTick();
        if (!self.sleepMode) {
            MainTimer.start();
        }
    }

    function onHide() as Void { MainTimer.stop(); }

    function onExitSleep() as Void {
        self.sleepMode = false;
        self.subscribeToComplications();
        self.syncData();
        MainTimer.nextTick();
        MainTimer.start();
    }

    function onEnterSleep() as Void {
        self.sleepMode = true;
        MainTimer.stop();
        Gfx.unsubscribeFromComplications();
    }

    // Present a prepared frame, or render synchronously for the sleeping update.
    function onUpdate(dc as Graphics.Dc) as Void {
        if (self.frameUpdatePending) {
            self.frameUpdatePending = false;
        } else if (self.sleepMode) {
            self.syncData();
            self.ultraUpdate(self.buffer.getDc());
        } else {
            return;
        }
        dc.clearClip();
        lib.drawBackground(dc, 0, 0);
        dc.drawBitmap(cfg.bufferDx, cfg.bufferDy, self.buffer);
        srv.seconds.draw(dc);

        // Start partial erasure at the position actually drawn by the PID.
        srv.seconds.prepareTransform(self.partialTransform, srv.seconds.renderedAngle());
    }

    function onPartialUpdate(dc as Graphics.Dc) as Void {
        var angle = srv.seconds.partialAngle();

        var clip = self.transformMove.transformPoints(self.partialTransform.transformPoints(cfg.initClip))
                       as Array<Graphics.Point2D>;
        var point0 = clip[0] as Graphics.Point2D;
        var point1 = clip[1] as Graphics.Point2D;
        var point2 = clip[2] as Graphics.Point2D;
        var point3 = clip[3] as Graphics.Point2D;

        var minX = srv.min(point0[0], srv.min(point1[0], srv.min(point2[0], point3[0])));
        var minY = srv.min(point0[1], srv.min(point1[1], srv.min(point2[1], point3[1])));
        var maxX = srv.max(point0[0], srv.max(point1[0], srv.max(point2[0], point3[0])));
        var maxY = srv.max(point0[1], srv.max(point1[1], srv.max(point2[1], point3[1])));
        dc.setClip(minX, minY, maxX - minX, maxY - minY);

        self.partialTransform.initialize();
        self.partialTransform.translate(cfg.secondsX, cfg.secondsY);
        self.partialTransform.rotate(angle);

        dc.drawBitmap(cfg.bufferDx, cfg.bufferDy, self.buffer);
        srv.seconds.drawPartial(dc, self.drawPartialOptions);

        srv.seconds.advancePartial();
    }

    function engineTick(deltaTime) as Void {
        if (self.frameUpdatePending) {
            return;
        }
        // Timer frames need a fresh clock target even when no sensor refresh
        // is due. Keep this separate from the heavier syncData() path.
        var clockTime = System.getClockTime();
        if (clockTime.sec != srv.seconds.canonicalSecond) {
            self.syncClock(clockTime);
        }
        self.ultraUpdate(self.buffer.getDc());
        self.frameUpdatePending = true;
        WatchUi.requestUpdate();
    }

    // Compose everything except the seconds hand into the single back buffer.
    function ultraUpdate(dc as Graphics.Dc) as Void {
        dc.clearClip();
        dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_TRANSPARENT);
        dc.clear();
        Gfx.setAntiAlias(dc);
        dc.setClip(cfg.analogClockClip[0], cfg.analogClockClip[1], cfg.analogClockClip[2], cfg.analogClockClip[3]);
        lib.drawBackground(dc, cfg.bufferDx, cfg.bufferDy);
        dc.clearClip();

        srv.steps.drawLabel(dc);
        srv.twilight.drawArcs(dc);
        srv.barometer.drawGraph(dc);
        srv.heartRate.drawGraph(dc);
        srv.moonPhase.draw(dc);
        srv.twilight.drawTile(dc);
        srv.calendar.drawWeekDay(dc);
        srv.weather.draw(dc);
        srv.steps.draw(dc);
        srv.calendar.drawDate(dc);
        srv.digital.draw(dc);
        srv.heartRate.draw(dc);
        srv.energy.draw(dc);
        srv.barometer.draw(dc);
        srv.battery.draw(dc);
        srv.digital.drawStatus(dc);
        srv.battery.drawGauge(dc);
        srv.steps.drawGraph(dc);
        srv.clock.draw(dc);
    }

    function syncClock(clockTime as System.ClockTime) as Void {
        srv.seconds.synchronize(clockTime.sec);
        srv.clock.setTime(clockTime.hour, clockTime.min, clockTime.sec);
        srv.digital.update(clockTime);
    }

    function syncData() as Void {
        self.syncClock(System.getClockTime());
        var now = Time.now();
        var date = Date.info(now, Time.FORMAT_SHORT);
        srv.steps.update();
        srv.battery.update(System.getSystemStats());
        srv.weather.update();
        srv.moonPhase.update(now);
        Gfx.updateSunTimes();
        srv.twilight.update(date);
        srv.digital.updateStatus(System.getDeviceSettings());
        srv.energy.update();
        srv.barometer.update();
        srv.heartRate.update();
        srv.calendar.update(date);
    }

    function subscribeToComplications() as Void { Gfx.subscribeToComplications(); }
    function updateComplication(id) as Void { Gfx.handleComplication(id); }
}
