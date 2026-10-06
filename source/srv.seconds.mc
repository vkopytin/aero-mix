import Toybox.Math;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

module srv {
    module seconds {
        const oneRad = Math.PI * 2.0 / 60.0;
        var previousSeconds = 0;
        var canonicalSecond = 0;
        var partialSecond = 0;
        var lastStep = 0.0;
        var pid = PidController.create(0.21, 0.2, 0.05);
        var hand = null as WatchUi.BitmapResource?;
        var secTransform = Gfx.createAffineTransform();
        const drawOptions = { :transform => self.secTransform };

        function initialize() as Void {
            self.hand = Gfx.loadHand(cfg.secondsHandResource);
        }

        function synchronize(second as Lang.Numeric) as Void {
            self.previousSeconds = self.canonicalSecond;
            self.canonicalSecond = second;
            self.partialSecond = second;
            self.pid.setTarget(self.canonicalSecond);
            if (self.previousSeconds > self.canonicalSecond) {
                self.pid.reset();
                self.lastStep = self.pid.update(-1.0);
            }
        }

        function prepareTransform(transform as DeviceTransform, angle as Lang.Numeric) as Void {
            transform.initialize();
            transform.translate(cfg.secondsX.toFloat(), cfg.secondsY.toFloat());
            transform.rotate(angle);
            transform.translate(cfg.secondsHandDx, cfg.secondsHandDy);
        }

        function draw(dc as Graphics.Dc) as Void {
            self.lastStep = self.pid.update(self.lastStep);
            self.prepareTransform(self.secTransform, self.renderedAngle());
            Gfx.drawHand(dc, "seconds", self.hand, self.drawOptions);
        }

        function renderedAngle() as Lang.Numeric { return self.lastStep * self.oneRad; }
        function partialAngle() as Lang.Numeric { return self.partialSecond * self.oneRad; }
        function advancePartial() as Void { self.partialSecond = (self.partialSecond + 1) % 60; }

        function drawPartial(dc as Graphics.Dc, options) as Void {
            Gfx.drawHand(dc, "seconds", self.hand, options);
        }
    }
}
