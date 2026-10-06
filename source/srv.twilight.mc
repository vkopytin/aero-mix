import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

using Toybox.Time.Gregorian as Date;

module srv {
    module twilight {
        var sunriseTime = 0;
        var sunsetTime = 0;
        var phaseTile = [21, 73] as [Number, Number];

        function initialize() as Void {

        }

        // Keep the last known sunrise/sunset when a complication has no value.
        function setSunTimes(sunrise, sunset) as Void {
            self.sunriseTime = sunrise;
            self.sunsetTime = sunset;
        }

        function update(date as Date.Info) as Void {
            var sunriseTime1 = srv.min(self.sunriseTime, self.sunsetTime);
            var sunsetTime1 = srv.max(self.sunriseTime, self.sunsetTime);
            var time = date.hour * 60 * 60 + date.min * 60 + date.sec;
            var beforeSunriseTime = sunriseTime1 - 60 * 60;
            var afterSunriseTime = sunriseTime1 + 60 * 60;
            var beforeSunsetTime = sunsetTime1 - 60 * 60;

            if (time < beforeSunriseTime) {
                self.phaseTile = [21, 73];
            } else if (time < sunriseTime1) {
                self.phaseTile = [81, 73];
            } else if (time < afterSunriseTime) {
                self.phaseTile = [140, 73];
            } else if (time < beforeSunsetTime) {
                self.phaseTile = [200, 73];
            } else if (time < sunsetTime1) {
                self.phaseTile = [260, 73];
            } else {
                self.phaseTile = [324, 73];
            }
        }

        function drawArcs(dc as Graphics.Dc) as Void {
            // sun set and sunrise arcs
            var arcRadius = 83;
            var arcX = 130 - cfg.bufferDx;
            var arcY = 130 - cfg.bufferDy;
            dc.setPenWidth(1);
            // night arc
            dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
            var sunriseAngle = 115 - 35 * srv.min(self.sunsetTime, self.sunriseTime) / 86400.0;
            var sunsetAngle = 115 - 35 * srv.max(self.sunsetTime, self.sunriseTime) / 86400.0;
            dc.drawArc(arcX, arcY, arcRadius, Graphics.ARC_CLOCKWISE, 115, sunriseAngle);
            // day arc
            dc.setColor(0xFF5500, Graphics.COLOR_TRANSPARENT);
            dc.drawArc(arcX, arcY, arcRadius, Graphics.ARC_CLOCKWISE, sunriseAngle, sunsetAngle);
            // night arc
            dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
            dc.drawArc(arcX, arcY, arcRadius, Graphics.ARC_CLOCKWISE, sunsetAngle, 80);
        }

        function drawTile(dc as Graphics.Dc) as Void {
            Gfx.drawTile(dc, 162 - cfg.bufferDx, 184 - cfg.bufferDy, "twilight", self.phaseTile[0], self.phaseTile[1], 50, 50);
        }
    }
}
