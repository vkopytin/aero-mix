import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Activity;

class AnalogClockView extends WatchUi.Drawable {
    private var hours = 0;
    private var minutes = 0;
    private var seconds = 0;
    private var locX = 0;
    private var locY = 0;
    private var hourHand = null as WatchUi.BitmapResource   ? ;
    private var minuteHand = null as WatchUi.BitmapResource ? ;
    private var hourHandTransform = new Graphics.AffineTransform();
    private var minuteHandTransform = new Graphics.AffineTransform();

    function setTime(hours, minutes, seconds) {
        self.hours = hours;
        self.minutes = minutes;
        self.seconds = seconds;
    }

    function initialize(params) {
        Drawable.initialize(params);

        self.locX = params.get(:locX);
        self.locY = params.get(:locY);
        self.hourHand = WatchUi.loadResource(params.get(:hourHandResId));
        self.minuteHand = WatchUi.loadResource(params.get(:minuteHandResId));
    }

    function draw(dc as Dc) {
        var posX = self.locX;
        var posY = self.locY;
        Drawable.draw(dc);

        var secondAngle = (self.seconds / 60.0) * 2.0 * Math.PI;
        var minuteAngle = (self.minutes / 60.0) * 2.0 * Math.PI;
        var hourAngle = self.hours / 12.0 * 2.0 * Math.PI;

        minuteHandTransform = new Graphics.AffineTransform();
        minuteHandTransform.translate(posX, posY);
        minuteHandTransform.scale(1.0, 1.0);
        minuteHandTransform.rotate(minuteAngle + secondAngle / 60.0);
        minuteHandTransform.translate(-5.5, -112.5);

        hourHandTransform = new Graphics.AffineTransform();
        hourHandTransform.translate(posX, posY);
        hourHandTransform.scale(1.0, 1.0);
        hourHandTransform.rotate(hourAngle + minuteAngle / 12.0);
        hourHandTransform.translate(-10.0, -59.0);

        dc.drawBitmap2(0, 0, self.minuteHand,
                       {
                           :transform => minuteHandTransform,
                       });

        dc.drawBitmap2(0, 0, self.hourHand,
                       {
                           :transform => hourHandTransform,
                       });

        // dc.fillCircle(posX, posY, 4);
    }
}
