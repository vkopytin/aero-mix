import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Complications;
using Toybox.Time.Gregorian as Date;

module srv {
    module twilight {
        var sunriseTime = 0;
        var sunsetTime = 0;
        var phaseTile = [21, 73] as [Number, Number];
        var phases = null as WatchUi.BitmapResource?;

        function initialize() as Void {
            self.phases = WatchUi.loadResource(Rez.Drawables.dayNightPhases);
        }

        // Keep the last known sunrise/sunset when a complication has no value.
        function updateComplication(id as Complications.Id, value) as Void {
            if (value == null) {
                return;
            }
            if (id.getType() == Complications.COMPLICATION_TYPE_SUNRISE) {
                self.sunriseTime = value;
            } else if (id.getType() == Complications.COMPLICATION_TYPE_SUNSET) {
                self.sunsetTime = value;
            }
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
            var arcX = 130;
            var arcY = 130;
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
            dc.drawBitmap2(162 - self.phaseTile[0], 184 - self.phaseTile[1], self.phases,
                           { :bitmapX => self.phaseTile[0], :bitmapY => self.phaseTile[1],
                             :bitmapWidth => 50, :bitmapHeight => 50 });
        }
    }
}
