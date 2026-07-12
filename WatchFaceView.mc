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
        :width => 11,
        :height => 76,
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
    private const initClip = [[1.0, 78.0], [1.0, 0.0], [12.0, 0.0], [12.0, 78.0]];
    private const clearRange = [156, 183, 25, 20];
    private const emptyOpts = {};
    private var lastTime = 0;
    private var clockTime = null as System.ClockTime?;

    private var currentTime = null as Toybox.WatchUi.Text?;
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
    private var dayNightBand = null as WatchUi.BitmapResource?;
    private var secondsClock = null as SecondsClockView?;
    private var infoWeather = null as InfoWeather?;
    private var heartRate = null as Toybox.WatchUi.Text?;
    private var energyLevel = null as Toybox.WatchUi.Text?;
    private var barometer = null as Toybox.WatchUi.Text?;
    private var battery = null as Toybox.WatchUi.Text?;
    private var stepsData = new [28] as Array<Graphics.Point2D>;
    private var moonPhaseTile = [15, 15] as [Number, Number];
    private var pressureSteps = [0.5, 0.25, 0.75] as [Lang.Float, Lang.Float];
    private var heartRateSteps = [0.5, 0.25, 0.75] as [Lang.Float, Lang.Float];

    private var renderPhase = false;

    function initialize() {
        Complications.registerComplicationChangeCallback(method(:updateComplication));
        self.subscribeToComplications();

        WatchFace.initialize();
        self.transformMove.translate(130.0, 111.0);
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
        self.dayNightBand = WatchUi.loadResource(Rez.Drawables.dayNightBand);
        self.batteryLevelBitmap = WatchUi.loadResource(Rez.Drawables.batteryLevel);
        self.background = View.findDrawableById("background");
        self.foreground = View.findDrawableById("foreground") as Toybox.WatchUi.Drawable;
        self.currentTime = View.findDrawableById("currentTime") as Toybox.WatchUi.Text;
        self.weekDay = View.findDrawableById("weekDay");
        self.stepsCount = View.findDrawableById("stepsCount") as Toybox.WatchUi.Text;
        self.stepsLabel = View.findDrawableById("stepsLabel") as Toybox.WatchUi.Text;
        self.month = View.findDrawableById("month");
        self.date = View.findDrawableById("date");
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
        self.currentTime.setFont(WatchUi.loadResource(Rez.Fonts.font14x22));
        self.battery.setFont(WatchUi.loadResource(Rez.Fonts.font16x16));
        self.barometer.setFont(WatchUi.loadResource(Rez.Fonts.font16x16));
        self.heartRate.setFont(WatchUi.loadResource(Rez.Fonts.font18x18));
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
        self.transform.translate(-4.0, -54.0);
        dc.drawBitmap2(0, 0, self.drawBuffer[self.currentDrawBuffer], self.emptyOpts);
        //dc.fillPolygon(clip);
        //dc.drawRectangle(minX, minY, maxX - minX, maxY - minY);
        dc.drawBitmap2(130, 111, self.buffer, self.drawBitmapOptions);

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
        var arcRadius = 130;
        var arcX = 130;
        var arcY = 130;
        backBufferdc.setPenWidth(3);
        // night arc
        backBufferdc.setColor(0xFF5555, Graphics.COLOR_TRANSPARENT);
        var sunriseAngle = 210 - 240 * self.sunriseTime / 86400.0;
        var sunsetAngle = 210 - 240 * self.sunsetTime / 86400.0;
        backBufferdc.drawArc(
            arcX,
            arcY,
            arcRadius,
            Graphics.ARC_CLOCKWISE,
            210,
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
            -30
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
            40 - self.moonPhaseTile[0],
            193 - self.moonPhaseTile[1],
            self.moonPhaseTiles, {
            :bitmapX => self.moonPhaseTile[0],
            :bitmapY => self.moonPhaseTile[1],
            :bitmapWidth => 20,
            :bitmapHeight => 20
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
        self.currentTime.draw(infoBufferdc);
        self.heartRate.draw(infoBufferdc);
        self.energyLevel.draw(infoBufferdc);
        self.barometer.draw(infoBufferdc);
        self.battery.draw(infoBufferdc);
        self.solarCharging.draw(infoBufferdc);
        self.bluetooth.draw(infoBufferdc);
        self.alarm.draw(infoBufferdc);
        self.vibrate.draw(infoBufferdc);

        var barWidth = 31 * self.batteryLevel / 100.0;
        infoBufferdc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        infoBufferdc.setFill(self.batteryLevelTexture);
        infoBufferdc.fillRectangle(114, 228, barWidth, 9);

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
            if (phase < 1.135) {
                self.moonPhaseTile = [15, 15];
            } else if (phase < 2.272) {
                self.moonPhaseTile = [48, 15];
            } else if (phase < 3.407) {
                self.moonPhaseTile = [80, 15];
            } else if (phase < 4.543) {
                self.moonPhaseTile = [113, 15];
            } else if (phase < 5.679) {
                self.moonPhaseTile = [146, 15];
            } else if (phase < 6.815) {
                self.moonPhaseTile = [178, 15];
            } else if (phase < 7.951) {
                self.moonPhaseTile = [15, 54];
            } else if (phase < 9.086) {
                self.moonPhaseTile = [48, 54];
            } else if (phase < 10.222) {
                self.moonPhaseTile = [80, 54];
            } else if (phase < 11.358) {
                self.moonPhaseTile = [113, 54];
            } else if (phase < 12.494) {
                self.moonPhaseTile = [146, 54];
            } else if (phase < 13.629) {
                self.moonPhaseTile = [178, 54];
            } else if (phase < 14.765) {
                self.moonPhaseTile = [15, 94];
            } else if (phase < 15.901) {
                self.moonPhaseTile = [15, 94];
            } else if (phase < 17.037) {
                self.moonPhaseTile = [48, 94];
            } else if (phase < 18.173) {
                self.moonPhaseTile = [80, 94];
            } else if (phase < 19.308) {
                self.moonPhaseTile = [113, 94];
            } else if (phase < 20.444) {
                self.moonPhaseTile = [146, 94];
            } else if (phase < 21.58) {
                self.moonPhaseTile = [178, 94];
            } else if (phase < 22.716) {
                self.moonPhaseTile = [15, 133];
            } else if (phase < 23.852) {
                self.moonPhaseTile = [48, 133];
            } else if (phase < 24.987) {
                self.moonPhaseTile = [80, 133];
            } else if (phase < 26.123) {
                self.moonPhaseTile = [113, 133];
            } else if (phase < 27.259) {
                self.moonPhaseTile = [146, 133];
            } else if (phase < 28.394) {
                self.moonPhaseTile = [178, 133];
            } else {
                self.moonPhaseTile = [15, 173];
            }

            var settings = Toybox.System.getDeviceSettings();
            if (settings.phoneConnected) {
                self.bluetooth.setText("1");
            } else {
                self.bluetooth.setText("3");
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

            self.currentTime.setText(Lang.format("$1$:$2$", [self.clockTime.hour.format("%02d"), self.clockTime.min.format("%02d")]));
            self.weekDay.setText(WEEK_DAYS[date.day_of_week]);
            self.weekDay.setColor(date.day_of_week == Date.DAY_SUNDAY ? 0xFF5500 : 0x55AAAA);
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
