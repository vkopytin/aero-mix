import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Weather;
import Toybox.Time;
import Toybox.Application;
import Toybox.Graphics;
using Toybox.Time.Gregorian as Date;

const WEEK_DAYS = ["", "SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
const MONTHS = {
    Date.MONTH_JANUARY => "JAN",
    Date.MONTH_FEBRUARY => "FEB",
    Date.MONTH_MARCH => "MAR",
    Date.MONTH_APRIL => "APR",
    Date.MONTH_MAY => "MAY",
    Date.MONTH_JUNE => "JUN",
    Date.MONTH_JULY => "JUL",
    Date.MONTH_AUGUST => "AUG",
    Date.MONTH_SEPTEMBER => "SEP",
    Date.MONTH_OCTOBER => "OCT",
    Date.MONTH_NOVEMBER => "NOV",
    Date.MONTH_DECEMBER => "DEC"
};
const EPOCH = 2440587.5;
const SYNODIC_MONTH = 29.53058770576;


class WatchFaceView extends WatchUi.WatchFace {
    private const ONE_RAD = Math.PI * 2.0 / 60.0;
    private const timer = MainTimer.create(self);
    private var sleepMode = false;
    private const initBufferOptions = {
        :width => 260,
        :height => 260,
    };
    private var width = 260;
    private var height = 260;
    private var seconds = 0;
    private var minutes = -1;
    private var quota = 1010;

    private var sunriseTime = 0;
    private var sunsetTime = 0;
    private var batteryLevel = 0;
    private var barometerLevel = 0;

    private var backLayout = [] as Array<Toybox.WatchUi.Drawable>;
    private var analogClock = null as AnalogClockView;

    private var hand = null as WatchUi.BitmapResource;
    private var handDisk = null as WatchUi.BitmapResource;
    private var moonPhaseTiles = null as WatchUi.BitmapResource;
    private var batteryLevelBitmap = null as WatchUi.BitmapResource;
    private var indicatorArrowBitmap = null as WatchUi.BitmapResource;
    private var batteryLevelTexture = null as Graphics.BitmapTexture;
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
    private const transformDayNight = new Graphics.AffineTransform();
    private const transformMoonPhase = new Graphics.AffineTransform();
    private const transformIndicatorArrow = new Graphics.AffineTransform();

    private const drawBitmapOptions = {
        :transform => self.transform
    };
    private const drawBitmapOptions2 = {
        :transform => self.transform2
    };
    private const initBufferOptions1 = {
        :width => 8,
        :height => 143,
    };
    private const initBufferOptions2 = {
        :width => 260,
        :height => 260,
    };
    private const drawDayNightOptions = {
        :transform => self.transformDayNight
    };
    private const drawIndicatorArrowOptions = {
        :transform => self.transformIndicatorArrow
    };
    private const clearRange = [156, 183, 25, 20];
    private const emptyOpts = {};
    private var lastTime = 0;
    private var clockTime = null as System.ClockTime?;

    private var currentHour = null as Toybox.WatchUi.Text?;
    private var currentMinute = null as Toybox.WatchUi.Text?;
    private var weekDay = null as Toybox.WatchUi.Text?;
    private var month = null as Toybox.WatchUi.Text?;
    private var date = null as Toybox.WatchUi.Text?;
    private var stepsCount = null as Toybox.WatchUi.Text?;
    private var stepsLabel = null as Toybox.WatchUi.Text?;
    private var solarCharging = null as Toybox.WatchUi.Text?;
    private var bluetooth = null as Toybox.WatchUi.Text?;
    private var alarm = null as Toybox.WatchUi.Text?;
    private var vibrate = null as Toybox.WatchUi.Text?;
    private var background = null as Toybox.WatchUi.Drawable?;
    private var foreground = null as Toybox.WatchUi.Drawable?;
    private var dayNightPhases = null as WatchUi.BitmapResource?;
    private var secondsClock = null as SecondsClockView?;
    private var infoWeather = null as InfoWeather?;
    private var heartRate = null as Toybox.WatchUi.Text?;
    private var energyLevel = null as Toybox.WatchUi.Text?;
    private var barometer = null as Toybox.WatchUi.Text?;
    private var battery = null as Toybox.WatchUi.Text?;
    private var stepsData = new [28] as Array<Graphics.Point2D>;
    private var moonPhaseTile = [15, 15] as [Number, Number];
    private var dayNighPhaseTile = [21, 73] as [Number, Number];
    private var pressureSteps = [0.5, 0.25, 0.75] as [Lang.Float, Lang.Float];
    private var heartRateSteps = [0.5, 0.25, 0.75] as [Lang.Float, Lang.Float];

    private var renderPhase = false;

    function initialize() {
        Complications.registerComplicationChangeCallback(method(:updateComplication));
        self.subscribeToComplications();

        WatchFace.initialize();
        self.transformMove.translate(130.0, 130.0);
        for (var i = 0; i < 28; i++) {
            self.stepsData[i] = [0, 0];
        }
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

        self.moonPhaseTiles = WatchUi.loadResource(@Rez.Drawables.moonPhaseTiles);
        self.dayNightPhases = WatchUi.loadResource(Rez.Drawables.dayNightPhases);
        self.batteryLevelBitmap = WatchUi.loadResource(Rez.Drawables.batteryLevel);
        self.background = View.findDrawableById("background");
        self.foreground = View.findDrawableById("foreground") as Toybox.WatchUi.Drawable;
        self.currentHour = View.findDrawableById("currentHour") as Toybox.WatchUi.Text;
        self.currentMinute = View.findDrawableById("currentMinute") as Toybox.WatchUi.Text;
        self.weekDay = View.findDrawableById("weekDay") as Toybox.WatchUi.Text;
        self.stepsCount = View.findDrawableById("stepsCount") as Toybox.WatchUi.Text;
        self.stepsLabel = View.findDrawableById("stepsLabel") as Toybox.WatchUi.Text;
        self.month = View.findDrawableById("month") as Toybox.WatchUi.Text;
        self.date = View.findDrawableById("date") as Toybox.WatchUi.Text;
        self.analogClock = View.findDrawableById("analogClock") as AnalogClockView;
        self.secondsClock = View.findDrawableById("secondsClock") as SecondsClockView;
        self.infoWeather = View.findDrawableById("infoWeather") as InfoWeather;
        self.heartRate = View.findDrawableById("heartRate") as Toybox.WatchUi.Text;
        self.energyLevel = View.findDrawableById("energyLevel");
        self.barometer = View.findDrawableById("barometer") as Toybox.WatchUi.Text;
        self.battery = View.findDrawableById("battery") as Toybox.WatchUi.Text;
        self.solarCharging = View.findDrawableById("solarCharging") as Toybox.WatchUi.Text;
        self.bluetooth = View.findDrawableById("bluetooth") as Toybox.WatchUi.Text;
        self.alarm = View.findDrawableById("alarm") as Toybox.WatchUi.Text;
        self.vibrate = View.findDrawableById("vibrate") as Toybox.WatchUi.Text;
        self.hand = WatchUi.loadResource(@Rez.Drawables.SecondsHand);
        self.indicatorArrowBitmap = WatchUi.loadResource(@Rez.Drawables.indicatorArrow);

        //self.currentTime.setFont(Graphics.getVectorFont({:face => "BionicBold", :size => 50}));
        self.drawBuffer = [
            Graphics.createBufferedBitmap(self.initBufferOptions).get(),
            Graphics.createBufferedBitmap(self.initBufferOptions).get()
        ];
        self.buffer = Graphics.createBufferedBitmap(self.initBufferOptions1).get();
        self.backBuffer = Graphics.createBufferedBitmap(self.initBufferOptions).get();
        self.frontBuffer = Graphics.createBufferedBitmap(self.initBufferOptions).get();
        self.infoBuffer = Graphics.createBufferedBitmap(self.initBufferOptions).get();

        self.batteryLevelTexture = new Graphics.BitmapTexture({
            :bitmap => self.batteryLevelBitmap
        });

        self.solarCharging.setFont(WatchUi.loadResource(Rez.Fonts.system12));
        self.bluetooth.setFont(WatchUi.loadResource(Rez.Fonts.system12));
        self.alarm.setFont(WatchUi.loadResource(Rez.Fonts.system12));
        self.vibrate.setFont(WatchUi.loadResource(Rez.Fonts.system12));
        //self.battery.setFont(WatchUi.loadResource(Rez.Fonts.lcdDisplay9));
        self.stepsCount.setFont(WatchUi.loadResource(Rez.Fonts.font8x16));
        self.stepsLabel.setFont(WatchUi.loadResource(Rez.Fonts.font8x16));
        self.currentHour.setFont(WatchUi.loadResource(Rez.Fonts.font14x22));
        self.currentMinute.setFont(WatchUi.loadResource(Rez.Fonts.font14x22));
        self.battery.setFont(WatchUi.loadResource(Rez.Fonts.font16x16));
        self.barometer.setFont(WatchUi.loadResource(Rez.Fonts.font16x16));
        self.heartRate.setFont(WatchUi.loadResource(Rez.Fonts.font18x18));
        self.date.setFont(WatchUi.loadResource(Rez.Fonts.font18x18));
        self.weekDay.setFont(WatchUi.loadResource(Rez.Fonts.font6x12));
        self.month.setFont(WatchUi.loadResource(Rez.Fonts.font6x12));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        self.secondsClock.setSeconds(100);
        self.syncData();
        self.timer.nextTick();
        if (self.sleepMode == false) {
            self.timer.start();
        }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
        self.timer.stop();
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
        self.sleepMode = false;
        self.secondsClock.setSeconds(100);
        self.syncData();
        self.minutes = -1;
        self.timer.nextTick();
        self.timer.start();
        self.subscribeToComplications();
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
        self.sleepMode = true;
        self.timer.stop();
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

        self.secondsClock.drawSecondsHand(dc, buffer, buffer);
    }

    private const initClip = [[1.0, 141.0], [1.0, 0.0], [18.0, 0.0], [18.0, 141.0]];
    // Handle the partial update event
    function onPartialUpdate( dc as Dc ) {
        self.lastTime = System.getTimer();
        var angle = self.seconds * self.ONE_RAD;

        //self.transform2.initialize();
        //self.transform2.rotate(-angle);
        //self.transform2.translate(-130.0, -130.0);
        //dc.setClip(self.clearRange[0], self.clearRange[1], self.clearRange[2], self.clearRange[3]);
        //dc.setColor(0x55AAAA, Graphics.COLOR_BLACK);
        //dc.drawText(168, 177, Graphics.FONT_TINY, self.seconds.format("%02d"), Graphics.TEXT_JUSTIFY_CENTER);

        if (self.quota < 999) {
            //self.seconds++;
            self.quota += 2 - (System.getTimer() - self.lastTime);
            //return;
        }

        var clip = self.transformMove.transformPoints(
            self.transform.transformPoints(self.initClip)
        );
        //dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        //var minX = clip[0][0] < clip[1][0] ? clip[0][0] : clip[2][0] < clip[1][0] ? clip[2][0] : clip[1][0];
        var minX = self.min(clip[0][0], self.min(clip[1][0], self.min(clip[2][0], clip[3][0])));
        var minY = self.min(clip[0][1], self.min(clip[1][1], self.min(clip[2][1], clip[3][1])));
        var maxX = self.max(clip[0][0], self.max(clip[1][0], self.max(clip[2][0], clip[3][0])));
        var maxY = self.max(clip[0][1], self.max(clip[1][1], self.max(clip[2][1], clip[3][1])));
        dc.setClip(minX, minY, maxX - minX, maxY - minY);
        //dc.clearClip();

        //if (seconds < 16) {
        //    dc.setClip(clip[0][0], clip[1][1], clip[2][0] - clip[0][0], clip[3][1] - clip[1][1]);
        //} else if (seconds < 31) {
        //    dc.setClip(clip[3][0], clip[0][1], clip[1][0] - clip[3][0], clip[2][1] - clip[0][1]);
        //} else if (seconds < 46) {
        //    dc.setClip(clip[2][0], clip[3][1], clip[0][0] - clip[2][0], clip[1][1] - clip[3][1]);
        //} else {
        //    dc.setClip(clip[1][0], clip[2][1], clip[3][0] - clip[1][0], clip[0][1] - clip[2][1]);
        //}

        self.transform.initialize();
        self.transform.rotate(angle);
        self.transform.translate(-3.5, -110.0);
        dc.drawBitmap2(0, 0, self.drawBuffer[self.currentDrawBuffer], self.emptyOpts);
        //dc.fillPolygon(clip);
        //dc.drawRectangle(minX, minY, maxX - minX, maxY - minY);
        dc.drawBitmap2(130, 130, self.buffer, self.drawBitmapOptions);

        self.seconds++;
        self.quota += 1 - (System.getTimer() - self.lastTime);
    }

    function engineTick(deltaTime) as Void {
        self.clockTime = System.getClockTime();
        self.seconds = self.clockTime.sec;
        // self.secondsDisk.setSeconds(clockTime.sec);
        self.analogClock.setTime(self.clockTime.hour, self.clockTime.min, self.clockTime.sec);
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
            dc.drawText(10, 120, Graphics.FONT_TINY, message, Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
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
                var sunriseTime = complication.value;
                if (sunriseTime != null) {
                    self.sunriseTime = sunriseTime;
                }
                break;
            case Complications.COMPLICATION_TYPE_SUNSET:
                var sunsetTime = complication.value;
                if (sunsetTime != null) {
                    self.sunsetTime = sunsetTime;
                }
                break;
            case Complications.COMPLICATION_TYPE_BATTERY:
                self.batteryLevel = complication.value;
                break;
        }
    }

    function updateBackBuffer(dc as Dc, refresh as Boolean) as Void {
        var backBufferdc = null as Graphics.Dc?;

        if (self.backBuffer != null && !refresh) {
            return;
        }

        backBufferdc = self.backBuffer.getDc();
        backBufferdc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        backBufferdc.clear();

        //backBufferdc.drawBitmap2(0, 98, self.dayNightBand, self.drawDayNightOptions);
        self.background.draw(backBufferdc);

        self.stepsLabel.draw(backBufferdc);

        // sun set and sunrise arcs
        var arcRadius = 83;
        var arcX = 130;
        var arcY = 130;
        backBufferdc.setPenWidth(1);
        // night arc
        backBufferdc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
        var sunriseAngle = 115 - 35 * self.min(self.sunsetTime, self.sunriseTime) / 86400.0;
        var sunsetAngle = 115 - 35 * self.max(self.sunsetTime, self.sunriseTime) / 86400.0;
        backBufferdc.drawArc(
            arcX,
            arcY,
            arcRadius,
            Graphics.ARC_CLOCKWISE,
            115,
            sunriseAngle
        );
        // day arc
        backBufferdc.setColor(0xFF5500, Graphics.COLOR_TRANSPARENT);
        backBufferdc.drawArc(
            arcX,
            arcY,
            arcRadius,
            Graphics.ARC_CLOCKWISE,
            sunriseAngle,
            sunsetAngle
        );
        // night arc
        backBufferdc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
        backBufferdc.drawArc(
            arcX,
            arcY,
            arcRadius,
            Graphics.ARC_CLOCKWISE,
            sunsetAngle,
            80
        );

        self.drawArcGraph(backBufferdc,
            73, 78,
            self.pressureSteps[0], self.pressureSteps[1], self.pressureSteps[2],
            0xAAAAAA, 0x555555
        );

        self.drawArcGraph(backBufferdc,
            187, 78,
            self.heartRateSteps[0], self.heartRateSteps[1], self.heartRateSteps[2],
            0xAAAAAA, 0x555555
        );

        backBufferdc.drawBitmap2(
            112 - self.moonPhaseTile[0],
            188 - self.moonPhaseTile[1],
            self.moonPhaseTiles, {
            :bitmapX => self.moonPhaseTile[0],
            :bitmapY => self.moonPhaseTile[1],
            :bitmapWidth => 40,
            :bitmapHeight => 40
        });

        backBufferdc.drawBitmap2(
            162 - self.dayNighPhaseTile[0],
            184 - self.dayNighPhaseTile[1],
            self.dayNightPhases, {
            :bitmapX => self.dayNighPhaseTile[0],
            :bitmapY => self.dayNighPhaseTile[1],
            :bitmapWidth => 50,
            :bitmapHeight => 50
        });

        backBufferdc = null;
    }

    function updateFrontBuffer(dc as Dc, refresh as Boolean) as Void {
        var frontBufferdc = null as Graphics.Dc?;

        if (self.frontBuffer != null && !refresh) {
            return;
        }

        frontBufferdc = self.frontBuffer.getDc();
        frontBufferdc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_TRANSPARENT);
        frontBufferdc.clear();

        frontBufferdc.setAntiAlias(true);

        self.analogClock.draw(frontBufferdc);
        self.secondsClock.draw(frontBufferdc);
        frontBufferdc = null;
    }

    function updateInfoBuffer(dc as Dc) as Void {
        var infoBufferdc = null as Graphics.Dc?;

        infoBufferdc = self.infoBuffer.getDc();
        infoBufferdc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_TRANSPARENT);
        infoBufferdc.clear();

        infoBufferdc.setAntiAlias(true);

        self.weekDay.draw(infoBufferdc);
        self.infoWeather.draw(infoBufferdc);
        self.stepsCount.draw(infoBufferdc);
        self.month.draw(infoBufferdc);
        self.date.draw(infoBufferdc);
        self.currentHour.draw(infoBufferdc);
        self.currentMinute.draw(infoBufferdc);
        self.heartRate.draw(infoBufferdc);
        self.energyLevel.draw(infoBufferdc);
        self.barometer.draw(infoBufferdc);
        self.battery.draw(infoBufferdc);
        self.solarCharging.draw(infoBufferdc);
        self.bluetooth.draw(infoBufferdc);
        self.alarm.draw(infoBufferdc);
        self.vibrate.draw(infoBufferdc);

        var barWidth = 41 * self.batteryLevel / 100.0;
        infoBufferdc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        infoBufferdc.setFill(self.batteryLevelTexture);
        infoBufferdc.fillRectangle(176, 137, barWidth, 6);

        infoBufferdc.setColor(0x55AAAA, Graphics.COLOR_TRANSPARENT);
        infoBufferdc.fillPolygon(self.stepsData);

        infoBufferdc = null;
    }

    function syncData() as Void {
        try {
            var activityMonitor = ActivityMonitor.getInfo();
            if (activityMonitor != null && activityMonitor.steps != null) {
              var steps = activityMonitor.steps;
              self.stepsCount.setText(steps.format("%d"));
            }

            var now = Time.now();
            var date = Date.info(now, Time.FORMAT_SHORT);

            var stats = System.getSystemStats();
            if (stats.solarIntensity > 49) {
                self.solarCharging.setText("7");
                self.solarCharging.setColor(0x55AAAA);
            } else if (stats.solarIntensity > 24) {
                self.solarCharging.setText("6");
                self.solarCharging.setColor(0x55AAAA);
            } else if (stats.solarIntensity > 0) {
                self.solarCharging.setText("5");
                self.solarCharging.setColor(0x55AAAA);
            } else {
                self.solarCharging.setText("5");
                self.solarCharging.setColor(0x000055);
            }

            var phase = self.moonPhase(now);
            if (phase < 0.9843529235253333) {
                self.moonPhaseTile = [22, 44];
            } else if (phase < 1.9687058470506666) {
                self.moonPhaseTile = [97, 44];
            } else if (phase < 2.953058770576) {
                self.moonPhaseTile = [169, 44];
            } else if (phase < 3.9374116941013333) {
                self.moonPhaseTile = [241, 44];
            } else if (phase < 4.921764617626667) {
                self.moonPhaseTile = [311, 44];
            } else if (phase < 5.906117541152) {
                self.moonPhaseTile = [385, 44];
            } else if (phase < 6.890470464677334) {
                self.moonPhaseTile = [457, 44];
            } else if (phase < 7.874823388202667) {
                self.moonPhaseTile = [530, 44];
            } else if (phase < 8.859176311728) {
                self.moonPhaseTile = [603, 44];
            } else if (phase < 9.843529235253333) {
                self.moonPhaseTile = [674, 44];
            } else if (phase < 10.827882158778667) {
                self.moonPhaseTile = [22, 185];
            } else if (phase < 11.812235082304) {
                self.moonPhaseTile = [98, 185];
            } else if (phase < 12.796588005829333) {
                self.moonPhaseTile = [169, 185];
            } else if (phase < 13.780940929354667) {
                self.moonPhaseTile = [242, 185];
            } else if (phase < 14.76529385288) {
                self.moonPhaseTile = [314, 185];
            } else if (phase < 15.749646776405333) {
                self.moonPhaseTile = [385, 185];
            } else if (phase < 16.733999699930667) {
                self.moonPhaseTile = [458, 185];
            } else if (phase < 17.718352623456) {
                self.moonPhaseTile = [529, 185];
            } else if (phase < 18.702705546981335) {
                self.moonPhaseTile = [603, 185];
            } else if (phase < 19.687058470506667) {
                self.moonPhaseTile = [676, 185];
            } else if (phase < 20.671411394032) {
                self.moonPhaseTile = [24, 316];
            } else if (phase < 21.655764317557335) {
                self.moonPhaseTile = [98, 316];
            } else if (phase < 22.640117241082667) {
                self.moonPhaseTile = [170, 316];
            } else if (phase < 23.624470164608) {
                self.moonPhaseTile = [242, 316];
            } else if (phase < 24.608823088133335) {
                self.moonPhaseTile = [314, 316];
            } else if (phase < 25.593176011658667) {
                self.moonPhaseTile = [386, 316];
            } else if (phase < 26.577528935184) {
                self.moonPhaseTile = [459, 316];
            } else if (phase < 27.561881858709334) {
                self.moonPhaseTile = [530, 316];
            }

            var sunriseTime1 = self.min(self.sunriseTime, self.sunsetTime);
            var sunsetTime1 = self.max(self.sunriseTime, self.sunsetTime);
            var time = date.hour * 60 * 60 + date.min * 60 + date.sec;
            var beforeSunriseTime = sunriseTime1 - 60 * 60;
            var afterSunriseTime = sunriseTime1 + 60 * 60;
            var beforeSunsetTime = sunsetTime1 - 60 * 60;

            if (time < beforeSunriseTime) {
                self.dayNighPhaseTile = [21, 73];
            } else if (time < sunriseTime1) {
                self.dayNighPhaseTile = [81, 73];
            } else if (time < afterSunriseTime) {
                self.dayNighPhaseTile = [140, 73];
            } else if (time < beforeSunsetTime) {
                self.dayNighPhaseTile = [200, 73];
            } else if (time < sunsetTime1) {
                self.dayNighPhaseTile = [260, 73];
            } else {
                self.dayNighPhaseTile = [324, 73];
            }

            var settings = Toybox.System.getDeviceSettings();
            if (settings.phoneConnected) {
                self.bluetooth.setText("1");
                self.bluetooth.setColor(0x55AAAA);
            } else {
                self.bluetooth.setText("3");
                self.bluetooth.setColor(0x000055);
            }

            if (settings.alarmCount > 0) {
                self.alarm.setColor(0x55AAAA);
            } else {
                self.alarm.setColor(0x000055);
            }

            if (settings.vibrateOn) {
                self.vibrate.setColor(0x55AAAA);
            } else {
                self.vibrate.setColor(0x000055);
            }

            if (Toybox has :SensorHistory) {
                var bodyBatteryIterator = Toybox.SensorHistory.getBodyBatteryHistory({ :period => 1 });
                var sample = bodyBatteryIterator.next();
                if (sample != null && sample.data != null) {
                    self.energyLevel.setText(Lang.format("$1$%", [sample.data.format("%d")]));
                }
                if (Toybox.SensorHistory has :getPressureHistory) {
                    sample = Toybox.SensorHistory.getPressureHistory({});
                    var value = self.graphDataToFlat(sample, self.pressureSteps);
                    self.barometerLevel = value;
                    self.barometer.setText((value / 100).format("%d"));
                }
                if (Toybox.SensorHistory has :getHeartRateHistory) {
                    sample = Toybox.SensorHistory.getHeartRateHistory({});
                    self.graphDataToFlat(sample, self.heartRateSteps);
                }
                self.stepsHistoryToArray(
                    78, 164,
                    self.stepsData
                );
		    }
            var activityInfo = Activity.getActivityInfo();
            if (activityInfo != null && activityInfo.currentHeartRate != null) {
                self.heartRate.setText(activityInfo.currentHeartRate.format("%d"));
            }

            self.battery.setText(Lang.format("$1$%", [self.batteryLevel.format("%d")]));

            self.clockTime = System.getClockTime();
            self.seconds = self.clockTime.sec;

            self.currentHour.setText(Lang.format("$1$:", [self.clockTime.hour.format("%02d")]));
            self.currentMinute.setText(self.clockTime.min.format("%02d"));
            self.weekDay.setText(WEEK_DAYS[date.day_of_week]);
            self.weekDay.setColor(date.day_of_week == Date.DAY_SUNDAY ? 0xFF0055 : 0xAA5500);
            self.month.setText(MONTHS[date.month]);
            self.date.setText(date.day.format("%02d"));

            self.secondsClock.setSeconds(clockTime.sec);

            var dayNightPosition = (self.clockTime.hour + self.clockTime.min / 60.0) / 24.0 * 240.0 - 200.0;
            self.transformDayNight.initialize();
            self.transformDayNight.translate(dayNightPosition, 70.0);
        } catch (ex) {
        }
    }

    function min(a, b) {
        return a < b ? a : b;
    }

    function max(a, b) {
        return a > b ? a : b;
    }

    function arraySumm(array, def) {
		var sum = 0;
		for (var i = 0; i < array.size(); i++) {
			if (array[i] == null || array[i].data == null) {
				array[i] = def;
            } else {
				array[i] = array[i].data;
			}
			sum += array[i];
		}
		return sum;
	}

    function stepsHistoryToArray(offsetX, offsetY, items) {
        var history = ActivityMonitor.getHistory();
        var max = 10000;
        var length = self.min(items.size() / 4, history.size());
        var height = 10.0;

        if (history != null) {
            for (var i = 0; i < length; i++) {
                var value = self.min(history[i].steps, max);
                value = value * height / max;
                var x = offsetX - i;
                var y = offsetY - value;
                items[4 * i] = [3 * x, offsetY];
                items[4 * i + 1] = [3 * x, offsetY - value];
                items[4 * i + 2] = [3 * x + 2, offsetY - value];
                items[4 * i + 3] = [3 * x + 2, offsetY];
            }
            for (var i = length; i < items.size() / 4; i++) {
                items[4 * i] = [offsetX, offsetY];
                items[4 * i + 1] = [offsetX, offsetY];
                items[4 * i + 2] = [offsetX, offsetY];
                items[4 * i + 3] = [offsetX, offsetY];
            }
        }
    }

    function graphDataToFlat(sample, items as Array<Lang.Float>) {
        if (sample != null) {
            var max = sample.getMax().toFloat();
            var min = sample.getMin().toFloat();
            var diff = max - min;
            var firstItem = null;
            var minItem = sample.getMax().toFloat();
            var maxItem = sample.getMin().toFloat();
            var samples = [];

            var data = sample.next();
            while (data != null) {
                if (data.data == null) {
                    data = sample.next();
                    continue;
                }
                if (firstItem == null) {
                    firstItem = data.data.toFloat();
                }
                samples.add(data.data);
                data = sample.next();
            }
            var middleIndex = (samples.size() / 2).toNumber();
            for (var i = 0; i < middleIndex; i++) {
                minItem = self.min(minItem, samples[i].toFloat());
                maxItem = self.max(maxItem, samples[i].toFloat());
            }

            items[0] = (firstItem - min) / diff;
            items[1] = (minItem - min) / diff;
            items[2] = (maxItem - min) / diff;

            return firstItem;
        }

        return 0;
    }

    function graphDataToArray(offsetX, offsetY, sample, items) {
        var max = sample.getMax();
        var min = sample.getMin();
        var diff = max - min;
        var length = 13;
        var height = 10.0;
        var result = 0.0;
        if (sample != null) {
            // iterate over the samples and draw the graph
            var data = sample.next();
            var value = data.data;
            result = value;
            value = arraySumm([
                data, sample.next(), sample.next(), sample.next(),
                sample.next(), sample.next(), sample.next(), sample.next(),
                sample.next(), sample.next(), sample.next(), sample.next(),
                sample.next(), sample.next()
            ], min) / 14.0;
            for (var i = 0; i < length; i++) {
                value = (value - min) * height / diff;
                var x = offsetX - i;
                var y = offsetY - value;
                items[4 * i] = [3 * x, offsetY];
                items[4 * i + 1] = [3 * x, offsetY - value];
                items[4 * i + 2] = [3 * x + 2, offsetY - value];
                items[4 * i + 3] = [3 * x + 2, offsetY];
                value = arraySumm([
                    sample.next(), sample.next(), sample.next(), sample.next(),
                    sample.next(), sample.next(), sample.next(), sample.next(),
                    sample.next(), sample.next(), sample.next(), sample.next(),
                    sample.next(), sample.next()
                ], min) / 14.0;
            }
        }
        return result;
    }

    function moonPhase(now as Toybox.Time.Moment) {
        var time = (now.value() * 1000.0) / 86400000.0 + EPOCH;
        var phase = (time - 2451550.1) / SYNODIC_MONTH;
        var moonAge = phase - Math.floor(phase);
        if (moonAge < 0) {
            moonAge = moonAge + 1.0;
        }
        return moonAge * SYNODIC_MONTH;
    }

    function drawArcGraph(
        dc as Graphics.Dc,
        arcX, arcY,
        current as Float, step1 as Float, step2 as Float,
        step1Color, step2Color
    ) {
        var arcRadius = 25;
        // night arc
        dc.setColor(step1Color, Graphics.COLOR_TRANSPARENT);
        var sunriseAngle = 230 - 280 * step1;
        var sunsetAngle = 230 - 280 * step2;
        dc.drawArc(
            arcX,
            arcY,
            arcRadius,
            Graphics.ARC_CLOCKWISE,
            230,
            sunriseAngle - 1
        );
        // day arc
        dc.setColor(step2Color, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(
            arcX,
            arcY,
            arcRadius,
            Graphics.ARC_CLOCKWISE,
            sunriseAngle,
            sunsetAngle - 1
        );
        // night arc
        dc.setColor(step1Color, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(
            arcX,
            arcY,
            arcRadius,
            Graphics.ARC_CLOCKWISE,
            sunsetAngle,
            -50
        );

        self.transformIndicatorArrow.initialize();
        self.transformIndicatorArrow.rotate((-50 + 280.0 * current) * Math.PI / 180.0);
        self.transformIndicatorArrow.translate(-27.0, -5.0);

        dc.drawBitmap2(arcX, arcY, self.indicatorArrowBitmap, self.drawIndicatorArrowOptions);
    }
}
