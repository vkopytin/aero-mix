import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

module srv {
    module battery {
        var batteryLevel = 0;
        var battery = null as WatchUi.Text?;
        var solarCharging = null as WatchUi.Text?;
        var batteryLevelBitmap = null as WatchUi.BitmapResource?;
        var batteryLevelTexture = null as Graphics.BitmapTexture?;

        function initialize(label as WatchUi.Text, solarLabel as WatchUi.Text) as Void {
            self.battery = label;
            self.solarCharging = solarLabel;
            self.battery.setFont(WatchUi.loadResource(Rez.Fonts.font16x16));
            self.solarCharging.setFont(WatchUi.loadResource(Rez.Fonts.system12));
            self.batteryLevelBitmap = WatchUi.loadResource(Rez.Drawables.batteryLevel);
            self.batteryLevelTexture = new Graphics.BitmapTexture({ :bitmap => self.batteryLevelBitmap });
        }

        function updateComplication(value) as Void {
            self.batteryLevel = value;
        }

        function update(stats as System.Stats) as Void {
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
            self.battery.setText(Lang.format("$1$%", [self.batteryLevel.format("%d")]));
        }

        function draw(dc as Graphics.Dc) as Void {
            self.battery.draw(dc);
            self.solarCharging.draw(dc);
        }

        function drawGauge(dc as Graphics.Dc) as Void {
            var barWidth = 41 * self.batteryLevel / 100.0;
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.setFill(self.batteryLevelTexture);
            dc.fillRectangle(176, 137, barWidth, 6);
        }
    }
}
