import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

module srv {
    module battery {
        var batteryLevel = 0;
        var battery = cfg.batteryInitialText;
        var solarCharging = cfg.solarChargingInitialText;
        var solarColor = cfg.solarChargingColor;
        var font = null as WatchUi.FontResource?;
        var solarFont = null as WatchUi.FontResource?;

        function initialize() as Void {
            Gfx.initializeBatteryGauge();
            self.font = WatchUi.loadResource(Rez.Fonts.font16x16);
            self.solarFont = WatchUi.loadResource(Rez.Fonts.system12);
        }

        function updateComplication(value) as Void {
            self.batteryLevel = value;
        }

        function update(stats as System.Stats) as Void {
            if (!cfg.usesComplications) { self.batteryLevel = stats.battery; }
            var solar = stats has :solarIntensity && stats.solarIntensity != null ? stats.solarIntensity : 0;
            if (solar > 49) {
                self.solarCharging = "7";
                self.solarColor = 0x55AAAA;
            } else if (solar > 24) {
                self.solarCharging = "6";
                self.solarColor = 0x55AAAA;
            } else if (solar > 0) {
                self.solarCharging = "5";
                self.solarColor = 0x55AAAA;
            } else {
                self.solarCharging = "5";
                self.solarColor = 0x000055;
            }
            self.battery = Lang.format("$1$%", [self.batteryLevel.format("%d")]);
        }

        function draw(dc as Graphics.Dc) as Void {
            if (cfg.batteryVisible) {
                dc.setColor(cfg.batteryColor, Graphics.COLOR_TRANSPARENT);
                dc.drawText(cfg.batteryX, cfg.batteryY, self.font, self.battery, cfg.batteryJustification);
            }
            if (cfg.solarChargingVisible) {
                dc.setColor(self.solarColor, Graphics.COLOR_TRANSPARENT);
                dc.drawText(cfg.solarChargingX, cfg.solarChargingY, self.solarFont, self.solarCharging, cfg.solarChargingJustification);
            }
        }

        function drawGauge(dc as Graphics.Dc) as Void {
            var barWidth = 41 * self.batteryLevel / 100.0;
            Gfx.drawBatteryGauge(dc, 176 - cfg.bufferDx, 137 - cfg.bufferDy, barWidth, 6);
        }
    }
}
