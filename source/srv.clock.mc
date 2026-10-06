import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.WatchUi;

module srv {
    module clock {
        var hours = 0;
        var minutes = 0;
        var seconds = 0;
        var hourHand = null as WatchUi.BitmapResource   ? ;
        var minuteHand = null as WatchUi.BitmapResource ? ;
        var hourHandTransform = Gfx.createAffineTransform();
        var minuteHandTransform = Gfx.createAffineTransform();
        const hourHandOptions = { :transform => self.hourHandTransform };
        const minuteHandOptions = { :transform => self.minuteHandTransform };

        function initialize() as Void {
            self.hourHand = Gfx.loadHand(cfg.hourHandResource);
            self.minuteHand = Gfx.loadHand(cfg.minuteHandResource);
        }

        function setTime(hours, minutes, seconds) as Void {
            self.hours = hours;
            self.minutes = minutes;
            self.seconds = seconds;
        }

        function draw(dc as Graphics.Dc) as Void {
            var secondAngle = (self.seconds / 60.0) * 2.0 * Math.PI;
            var minuteAngle = (self.minutes / 60.0) * 2.0 * Math.PI;
            var hourAngle = self.hours / 12.0 * 2.0 * Math.PI;

            self.minuteHandTransform.initialize();
            self.minuteHandTransform.translate(cfg.analogClockX, cfg.analogClockY);
            self.minuteHandTransform.rotate(minuteAngle + secondAngle / 60.0);
            self.minuteHandTransform.translate(cfg.minuteHandDx, cfg.minuteHandDy);

            self.hourHandTransform.initialize();
            self.hourHandTransform.translate(cfg.analogClockX, cfg.analogClockY);
            self.hourHandTransform.rotate(hourAngle + minuteAngle / 12.0);
            self.hourHandTransform.translate(cfg.hourHandDx, cfg.hourHandDy);

            Gfx.drawHand(dc, :minute, self.minuteHand, self.minuteHandOptions);
            Gfx.drawHand(dc, :hour, self.hourHand, self.hourHandOptions);
        }
    }
}
