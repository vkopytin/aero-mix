import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Activity;

class SecondsClockView extends WatchUi.Drawable {
    const oneRad = Math.PI * 2.0 / 60.0;
    private var previousSeconds = 0;
    private var seconds = 0;
    private var hand = null as WatchUi.BitmapResource    ? ;
    private var buffer = null as Graphics.BufferedBitmap ? ;
    private var transform = new Graphics.AffineTransform();
    private var transformMove = new Graphics.AffineTransform();
    private var drawBitmapOptions = { :transform => self.transform };
    private var initBufferOptions = {
        :width => 7,
        :height => 141,
    };
    private var locX = 130;
    private var locY = 130;

    function initialize(params) {
        Drawable.initialize(params);
        self.locX = params.get(:locX);
        self.locY = params.get(:locY);
        self.hand = WatchUi.loadResource(params.get(:rezId));
        self.transformMove.translate(self.locX, self.locY);
        self.buffer = Graphics.createBufferedBitmap(self.initBufferOptions).get();
    }

    function draw(dc as Dc) {
        Drawable.draw(dc);
        self.buffer = Graphics.createBufferedBitmap(self.initBufferOptions).get();

        var bufferdc = self.buffer.getDc();
        bufferdc.drawBitmap(0, 0, self.hand);
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

    private var pid = PidController.create(0.21, 0.2, 0.05);
    private var lastStep = 0.0;
    function drawSecondsHand(dc as Dc, backBuffer as BufferedBitmap, frontBuffer as BufferedBitmap) {
        var posX = self.locX;
        var posY = self.locY;
        self.clearSecondsHand(dc, frontBuffer, false);

        self.lastStep = self.pid.update(self.lastStep);
        var angle = self.lastStep * oneRad;

        self.transform.initialize();
        self.transform.rotate(angle);
        self.transform.translate(-3.5, -110.0);
        self.clearSecondsHand(dc, backBuffer, true);
        dc.drawBitmap2(posX, posY, self.buffer, self.drawBitmapOptions);
    }

    // private var initClip = [[-5.0, 68.0],[-5.0, -1.0],[22.0, -1.0],[22.0,68.0]];
    private var initClip = [[1.0, 141.0], [1.0, 0.0], [7.0, 0.0], [7.0, 141.0]];
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
