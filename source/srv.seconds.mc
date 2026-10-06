import Toybox.Math;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Activity;

module srv {
    module seconds {
        const oneRad = Math.PI * 2.0 / 60.0;
        var previousSeconds = 0;
        var seconds = 0;
        var hand = null as WatchUi.BitmapResource    ? ;
        var buffer = null as Graphics.BufferedBitmap ? ;
        var transform = new Graphics.AffineTransform();
        var transformMove = new Graphics.AffineTransform();
        var drawBitmapOptions = { :transform => self.transform };
        var initBufferOptions = {
            :width => cfg.secondsBufferWidth,
            :height => cfg.secondsBufferHeight,
        };

        function initialize() as Void {
            self.hand = WatchUi.loadResource(cfg.secondsHandResource);
            self.transformMove.initialize();
            self.transformMove.translate(cfg.secondsX, cfg.secondsY);
            self.buffer = Graphics.createBufferedBitmap(self.initBufferOptions).get();
            self.buffer.getDc().drawBitmap(0, 0, self.hand);
        }

        // The seconds hand is drawn over the composed frame by drawSecondsHand().
        function draw(dc as Graphics.Dc) as Void {
            self.buffer.getDc().drawBitmap(0, 0, self.hand);
        }

        function setSeconds(seconds) {
            self.previousSeconds = self.seconds;
            self.seconds = seconds;
            self.pid.setTarget(self.seconds);
            if (self.previousSeconds > self.seconds) {
                self.pid.reset();
                self.lastStep = self.pid.update(-1.0);
            }
        }

        var pid = PidController.create(0.21, 0.2, 0.05);
        var lastStep = 0.0;
        function drawSecondsHand(dc as Dc, backBuffer as BufferedBitmap, frontBuffer as BufferedBitmap) {
            var posX = cfg.secondsX;
            var posY = cfg.secondsY;
            self.clearSecondsHand(dc, frontBuffer, false);

            self.lastStep = self.pid.update(self.lastStep);
            var angle = self.lastStep * oneRad;

            self.transform.initialize();
            self.transform.rotate(angle);
            self.transform.translate(cfg.secondsHandDx, cfg.secondsHandDy);
            self.clearSecondsHand(dc, backBuffer, true);
            dc.drawBitmap2(posX, posY, self.buffer, self.drawBitmapOptions);
        }

        // var initClip = [[-5.0, 68.0],[-5.0, -1.0],[22.0, -1.0],[22.0,68.0]];
        var initClip = cfg.secondsClip;
        function clearSecondsHand(dc as Dc, buffer as BufferedBitmap, reset) {
            dc.clearClip();
            var clip = self.transform.transformPoints(self.initClip);
            clip = self.transformMove.transformPoints(clip) as Array<[Numeric, Numeric]>;
            // dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            // dc.fillPolygon(clip);
            if (self.previousSeconds < 15) {
                dc.setClip(clip[0][0], clip[1][1], clip[2][0] - clip[0][0], clip[3][1] - clip[1][1]);
            } else if (self.previousSeconds < 30) {
                dc.setClip(clip[3][0], clip[0][1], clip[1][0] - clip[3][0], clip[2][1] - clip[0][1]);
            } else if (self.previousSeconds < 45) {
                dc.setClip(clip[2][0], clip[3][1], clip[0][0] - clip[2][0], clip[1][1] - clip[3][1]);
            } else {
                dc.setClip(clip[1][0], clip[2][1], clip[3][0] - clip[1][0], clip[0][1] - clip[2][1]);
            }
            // dc.fillRectangle(0, 0, 260, 260);
            if (reset) {
                return;
            }

            dc.drawBitmap(0, 0, buffer);
            // dc.clearClip();
        }

    }
}
