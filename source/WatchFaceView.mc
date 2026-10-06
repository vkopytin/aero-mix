import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Weather;
import Toybox.Time;
import Toybox.Application;
import Toybox.Graphics;
using Toybox.Time.Gregorian as Date;

class WatchFaceView extends WatchUi.WatchFace {
    private const ONE_RAD = Math.PI * 2.0 / 60.0;

    private var sleepMode = false;
    private const initBufferOptions = {
        :width => cfg.bufferWidth,
        :height => cfg.bufferHeight,
    };
    private var width = cfg.bufferWidth;
    private var height = cfg.bufferHeight;
    private var seconds = 0;
    private var minutes = -1;
    private var quota = 1010;


    private var backLayout = [] as Array<Toybox.WatchUi.Drawable>;

    private var hand = null as WatchUi.BitmapResource;
    private var handDisk = null as WatchUi.BitmapResource;
    private var drawBuffer = [null as Graphics.BufferedBitmap, null as Graphics.BufferedBitmap];
    private var currentDrawBuffer = 0;
    private var buffer = null as Graphics.BufferedBitmap;
    private var buffer2 = null as Graphics.BufferedBitmap;
    private var backBuffer = null as Graphics.BufferedBitmap;
    private var infoBuffer = null as Graphics.BufferedBitmap;
    private var frontBuffer = null as Graphics.BufferedBitmap;

    private const transform = new Graphics.AffineTransform();
    private const transform2 = new Graphics.AffineTransform();
    private const transformMove = new Graphics.AffineTransform();
    private const transformMoonPhase = new Graphics.AffineTransform();

    private const drawBitmapOptions = { :transform => self.transform };
    private const drawBitmapOptions2 = { :transform => self.transform2 };
    private const initBufferOptions1 = {
        :width => 8,
        :height => 143,
    };
    private const initBufferOptions2 = {
        :width => cfg.bufferWidth,
        :height => cfg.bufferHeight,
    };
    private const clearRange = [156, 183, 25, 20];
    private const emptyOpts = {};
    private var lastTime1 = 0;
    private var clockTime = null as System.ClockTime ? ;

    private var background = null as Toybox.WatchUi.Drawable    ? ;
    private var foreground = null as Toybox.WatchUi.Drawable    ? ;

    private var renderPhase = false;

    function initialize() {
        Complications.registerComplicationChangeCallback(method(:updateComplication));
        self.subscribeToComplications();

        WatchFace.initialize();
        MainTimer.initialize(self);
        self.transformMove.translate(cfg.analogClockX, cfg.analogClockY);
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        self.width = dc.getWidth();
        self.height = dc.getHeight();
        self.initBufferOptions[:width] = self.width;
        self.initBufferOptions[:height] = self.height;
        dc.setAntiAlias(true);
        self.backLayout = Rez.Layouts.main(dc);
        setLayout(self.backLayout);

        srv.moonPhase.initialize();
        srv.twilight.initialize();
        self.background = View.findDrawableById("background");
        self.foreground = View.findDrawableById("foreground") as Toybox.WatchUi.Drawable;
        srv.digital.initialize();
        srv.steps.initialize();
        srv.calendar.initialize();
        srv.clock.initialize();
        srv.seconds.initialize();
        srv.weather.initialize();
        srv.heartRate.initialize();
        srv.barometer.initialize();
        srv.battery.initialize();
        self.hand = WatchUi.loadResource(@Rez.Drawables.SecondsHand);
        srv.arcGraph.initialize();

        self.drawBuffer = [
            Graphics.createBufferedBitmap(self.initBufferOptions).get(),
            Graphics.createBufferedBitmap(self.initBufferOptions).get()
        ];
        self.buffer = Graphics.createBufferedBitmap(self.initBufferOptions1).get();
        self.backBuffer = Graphics.createBufferedBitmap(self.initBufferOptions).get();
        self.frontBuffer = Graphics.createBufferedBitmap(self.initBufferOptions).get();
        self.infoBuffer = Graphics.createBufferedBitmap(self.initBufferOptions).get();


    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        srv.seconds.setSeconds(100);
        self.syncData();
        MainTimer.nextTick();
        if (self.sleepMode == false) {
            MainTimer.start();
        }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void { MainTimer.stop(); }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
        self.sleepMode = false;
        srv.seconds.setSeconds(100);
        self.syncData();
        self.minutes = -1;
        MainTimer.nextTick();
        MainTimer.start();
        self.subscribeToComplications();
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
        self.sleepMode = true;
        MainTimer.stop();
        Complications.unsubscribeFromAllUpdates();
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        if (self.renderPhase) {
            self.renderPhase = false;
        } else {
            self.syncData();
        }
        dc.clearClip();
        if (self.sleepMode) {
            self.syncData();
            self.engineTick(1000);
            self.currentDrawBuffer = self.currentDrawBuffer ^ 1;
        }

        var buffer = self.drawBuffer[self.currentDrawBuffer];
        dc.drawBitmap2(0, 0, buffer, self.emptyOpts);

        srv.seconds.drawSecondsHand(dc, buffer, buffer);
    }

    private const initClip = cfg.initClip;
    // Handle the partial update event
    function onPartialUpdate(dc as Dc) {
        self.lastTime1 = System.getTimer();
        var angle = self.seconds * self.ONE_RAD;

        // self.transform2.initialize();
        // self.transform2.rotate(-angle);
        // self.transform2.translate(-130.0, -130.0);
        // dc.setClip(self.clearRange[0], self.clearRange[1], self.clearRange[2], self.clearRange[3]);
        // dc.setColor(0x55AAAA, Graphics.COLOR_BLACK);
        // dc.drawText(168, 177, Graphics.FONT_TINY, self.seconds.format("%02d"), Graphics.TEXT_JUSTIFY_CENTER);

        if (self.quota < 999) {
            // self.seconds++;
            self.quota += 2 - (System.getTimer() - self.lastTime1);
            // return;
        }

        var clip = self.transformMove.transformPoints(self.transform.transformPoints(self.initClip));
        // dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        // var minX = clip[0][0] < clip[1][0] ? clip[0][0] : clip[2][0] < clip[1][0] ? clip[2][0] : clip[1][0];
        var minX = srv.min(clip[0][0], srv.min(clip[1][0], srv.min(clip[2][0], clip[3][0])));
        var minY = srv.min(clip[0][1], srv.min(clip[1][1], srv.min(clip[2][1], clip[3][1])));
        var maxX = srv.max(clip[0][0], srv.max(clip[1][0], srv.max(clip[2][0], clip[3][0])));
        var maxY = srv.max(clip[0][1], srv.max(clip[1][1], srv.max(clip[2][1], clip[3][1])));
        dc.setClip(minX, minY, maxX - minX, maxY - minY);
        // dc.clearClip();

        // if (seconds < 16) {
        //     dc.setClip(clip[0][0], clip[1][1], clip[2][0] - clip[0][0], clip[3][1] - clip[1][1]);
        // } else if (seconds < 31) {
        //     dc.setClip(clip[3][0], clip[0][1], clip[1][0] - clip[3][0], clip[2][1] - clip[0][1]);
        // } else if (seconds < 46) {
        //     dc.setClip(clip[2][0], clip[3][1], clip[0][0] - clip[2][0], clip[1][1] - clip[3][1]);
        // } else {
        //     dc.setClip(clip[1][0], clip[2][1], clip[3][0] - clip[1][0], clip[0][1] - clip[2][1]);
        // }

        self.transform.initialize();
        self.transform.rotate(angle);
        self.transform.translate(-3.5, -110.0);
        dc.drawBitmap2(0, 0, self.drawBuffer[self.currentDrawBuffer], self.emptyOpts);
        // dc.fillPolygon(clip);
        // dc.drawRectangle(minX, minY, maxX - minX, maxY - minY);
        dc.drawBitmap2(cfg.analogClockX, cfg.analogClockY, self.buffer, self.drawBitmapOptions);

        self.seconds++;
        self.quota += 1 - (System.getTimer() - self.lastTime1);
    }

    function engineTick(deltaTime) as Void {
        self.clockTime = System.getClockTime();
        self.seconds = self.clockTime.sec;
        // self.secondsDisk.setSeconds(clockTime.sec);
        srv.clock.setTime(self.clockTime.hour, self.clockTime.min, self.clockTime.sec);
        var currentDrawBuffer = self.currentDrawBuffer;
        self.currentDrawBuffer = self.currentDrawBuffer ^ 1;
        var buffer = self.drawBuffer[currentDrawBuffer];

        var dc = buffer.getDc();
        dc.setAntiAlias(true);

        try {
            self.quota = 1030;

            var refresh = self.minutes != self.clockTime.min;
            self.updateBackBuffer(dc, refresh);
            self.updateFrontBuffer(dc, refresh);
            self.updateInfoBuffer(dc);
            self.minutes = self.clockTime.min;

            dc.drawBitmap(0, 0, self.backBuffer);
            dc.drawBitmap(0, 0, self.infoBuffer);
            dc.drawBitmap(0, 0, self.frontBuffer);

            var bufferdc = self.buffer.getDc();
            bufferdc.drawBitmap(0, 0, self.hand);
        } catch (ex) {
            var message = ex.getErrorMessage();
            System.println(message);
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(10, 120, Graphics.FONT_TINY, message,
                        Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        self.renderPhase = true;
        if (!self.sleepMode) {
            WatchUi.requestUpdate();
        }
    }

    function subscribeToComplications() as Void {
        Complications.subscribeToUpdates(new Complications.Id(Complications.COMPLICATION_TYPE_SUNRISE));
        Complications.subscribeToUpdates(new Complications.Id(Complications.COMPLICATION_TYPE_SUNSET));
        Complications.subscribeToUpdates(new Complications.Id(Complications.COMPLICATION_TYPE_BATTERY));
    }

    function updateComplication(complicationId as Toybox.Complications.Id) as Void {
        var complication = Complications.getComplication(complicationId);
        switch (complicationId.getType()) {
            case Complications.COMPLICATION_TYPE_SUNRISE:
            case Complications.COMPLICATION_TYPE_SUNSET:
                srv.twilight.updateComplication(complicationId, complication.value);
                break;
            case Complications.COMPLICATION_TYPE_BATTERY:
                srv.battery.updateComplication(complication.value);
                break;
        }
    }

    function updateBackBuffer(dc as Dc, refresh as Boolean) as Void {
        var backBufferdc = null as Graphics.Dc ? ;

        if (self.backBuffer != null && !refresh) {
            return;
        }

        backBufferdc = self.backBuffer.getDc();
        backBufferdc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        backBufferdc.clear();

        self.background.draw(backBufferdc);

        srv.steps.drawLabel(backBufferdc);

        srv.twilight.drawArcs(backBufferdc);

        srv.barometer.drawGraph(backBufferdc);

        srv.heartRate.drawGraph(backBufferdc);

        srv.moonPhase.draw(backBufferdc);

        srv.twilight.drawTile(backBufferdc);

        backBufferdc = null;
    }

    function updateFrontBuffer(dc as Dc, refresh as Boolean) as Void {
        var frontBufferdc = null as Graphics.Dc ? ;

        if (self.frontBuffer != null && !refresh) {
            return;
        }

        frontBufferdc = self.frontBuffer.getDc();
        frontBufferdc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_TRANSPARENT);
        frontBufferdc.clear();

        frontBufferdc.setAntiAlias(true);

        srv.clock.draw(frontBufferdc);
        srv.seconds.draw(frontBufferdc);
        frontBufferdc = null;
    }

    function updateInfoBuffer(dc as Dc) as Void {
        var infoBufferdc = null as Graphics.Dc ? ;

        infoBufferdc = self.infoBuffer.getDc();
        infoBufferdc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_TRANSPARENT);
        infoBufferdc.clear();

        infoBufferdc.setAntiAlias(true);

        srv.calendar.drawWeekDay(infoBufferdc);
        srv.weather.draw(infoBufferdc);
        srv.steps.draw(infoBufferdc);
        srv.calendar.drawDate(infoBufferdc);
        srv.digital.draw(infoBufferdc);
        srv.heartRate.draw(infoBufferdc);
        srv.energy.draw(infoBufferdc);
        srv.barometer.draw(infoBufferdc);
        srv.battery.draw(infoBufferdc);
        srv.digital.drawStatus(infoBufferdc);

        srv.battery.drawGauge(infoBufferdc);

        srv.steps.drawGraph(infoBufferdc);

        infoBufferdc = null;
    }

    function syncData() as Void {
        try {
            srv.steps.update();

            var now = Time.now();
            var date = Date.info(now, Time.FORMAT_SHORT);

            var stats = System.getSystemStats();
            srv.battery.update(stats);
            srv.weather.update();

            srv.moonPhase.update(now);

            srv.twilight.update(date);

            srv.digital.updateStatus(System.getDeviceSettings());
            srv.energy.update();
            srv.barometer.update();
            srv.heartRate.update();


            self.clockTime = System.getClockTime();
            self.seconds = self.clockTime.sec;

            srv.digital.update(self.clockTime);
            srv.calendar.update(date);

            srv.seconds.setSeconds(clockTime.sec);

        } catch (ex) {
        }
    }

}
