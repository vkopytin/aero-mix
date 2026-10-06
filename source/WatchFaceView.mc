import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Complications;
import Toybox.Time;
using Toybox.Time.Gregorian as Date;

class WatchFaceView extends WatchUi.WatchFace {
    private var sleepMode = false;
    private var frameUpdatePending = false;
    private var buffer = null as Graphics.BufferedBitmap?;
    private var partialTransform = new Graphics.AffineTransform();
    private var nextPartialTransform = new Graphics.AffineTransform();
    private var drawPartialOptions = { :transform => self.partialTransform };

    function initialize() {
        WatchFace.initialize();
        MainTimer.initialize(self);
        Complications.registerComplicationChangeCallback(method(:updateComplication));
        self.subscribeToComplications();
    }

    function onLayout(dc as Graphics.Dc) as Void {
        srv.moonPhase.initialize();
        srv.twilight.initialize();
        srv.digital.initialize();
        srv.steps.initialize();
        srv.calendar.initialize();
        srv.clock.initialize();
        srv.seconds.initialize();
        srv.weather.initialize();
        srv.heartRate.initialize();
        srv.barometer.initialize();
        srv.battery.initialize();
        srv.arcGraph.initialize();
        self.buffer = Graphics.createBufferedBitmap({
            :width => cfg.bufferWidth,
            :height => cfg.bufferHeight
        }).get();
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
        Complications.unsubscribeFromAllUpdates();
    }

    // Present a prepared frame, or render synchronously for the sleeping update.
    function onUpdate(dc as Graphics.Dc) as Void {
        if (self.frameUpdatePending) {
            self.frameUpdatePending = false;
        } else {
            self.syncData();
            if (self.sleepMode) {
                self.ultraUpdate(self.buffer.getDc());
            } else {
                return;
            }
        }
        dc.clearClip();
        lib.drawBackground(dc, 0, 0);
        dc.drawBitmap(cfg.bufferDx, cfg.bufferDy, self.buffer);
        srv.seconds.draw(dc);

        // Start partial erasure at the position actually drawn by the PID.
        srv.seconds.prepareTransform(self.partialTransform, srv.seconds.renderedAngle());
    }

    function onPartialUpdate(dc as Graphics.Dc) as Void {
        srv.seconds.prepareTransform(self.nextPartialTransform, srv.seconds.partialAngle());
        var oldClip = self.partialTransform.transformPoints(cfg.secondsClip) as Array<Graphics.Point2D>;
        var newClip = self.nextPartialTransform.transformPoints(cfg.secondsClip) as Array<Graphics.Point2D>;
        var minX = oldClip[0][0];
        var minY = oldClip[0][1];
        var maxX = minX;
        var maxY = minY;
        for (var i = 0; i < 4; i++) {
            minX = srv.min(minX, srv.min(oldClip[i][0], newClip[i][0]));
            minY = srv.min(minY, srv.min(oldClip[i][1], newClip[i][1]));
            maxX = srv.max(maxX, srv.max(oldClip[i][0], newClip[i][0]));
            maxY = srv.max(maxY, srv.max(oldClip[i][1], newClip[i][1]));
        }
        // Round outward and include a pixel for the rotated bitmap edges.
        minX = Math.floor(minX) - 1;
        minY = Math.floor(minY) - 1;
        maxX = Math.ceil(maxX) + 1;
        maxY = Math.ceil(maxY) + 1;
        dc.setClip(minX, minY, maxX - minX, maxY - minY);

        srv.seconds.prepareTransform(self.partialTransform, srv.seconds.partialAngle());
        dc.drawBitmap(cfg.bufferDx, cfg.bufferDy, self.buffer);
        srv.seconds.drawPartial(dc, self.drawPartialOptions);
        srv.seconds.advancePartial();
        dc.clearClip();
    }

    function engineTick(deltaTime) as Void {
        if (self.frameUpdatePending) {
            return;
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
        dc.setAntiAlias(true);
        dc.setClip(cfg.analogClockClip[0], cfg.analogClockClip[1],
                   cfg.analogClockClip[2], cfg.analogClockClip[3]);
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

    function syncData() as Void {
        var clockTime = System.getClockTime();
        srv.seconds.synchronize(clockTime.sec);
        srv.clock.setTime(clockTime.hour, clockTime.min, clockTime.sec);
        srv.digital.update(clockTime);
        var now = Time.now();
        var date = Date.info(now, Time.FORMAT_SHORT);
        srv.steps.update();
        srv.battery.update(System.getSystemStats());
        srv.weather.update();
        srv.moonPhase.update(now);
        srv.twilight.update(date);
        srv.digital.updateStatus(System.getDeviceSettings());
        srv.energy.update();
        srv.barometer.update();
        srv.heartRate.update();
        srv.calendar.update(date);
    }

    function subscribeToComplications() as Void {
        Complications.subscribeToUpdates(new Complications.Id(Complications.COMPLICATION_TYPE_SUNRISE));
        Complications.subscribeToUpdates(new Complications.Id(Complications.COMPLICATION_TYPE_SUNSET));
        Complications.subscribeToUpdates(new Complications.Id(Complications.COMPLICATION_TYPE_BATTERY));
    }

    function updateComplication(id as Complications.Id) as Void {
        var complication = Complications.getComplication(id);
        switch (id.getType()) {
            case Complications.COMPLICATION_TYPE_SUNRISE:
            case Complications.COMPLICATION_TYPE_SUNSET:
                srv.twilight.updateComplication(id, complication.value);
                break;
            case Complications.COMPLICATION_TYPE_BATTERY:
                srv.battery.updateComplication(complication.value);
                break;
        }
    }
}
