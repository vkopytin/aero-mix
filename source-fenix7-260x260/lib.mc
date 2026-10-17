import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

module lib {
    var secondsHandResource = null as WatchUi.BitmapResource?;

    function initializeSecondsHand() as Void {
        self.secondsHandResource = WatchUi.loadResource(cfg.secondsHandResource);
    }

    function drawSecondsHand(dc as Graphics.Dc, options) as Void {
        options[:transform].translate(cfg.secondsHandDx, cfg.secondsHandDy);
        dc.drawBitmap2(0, 0, self.secondsHandResource, options);
    }

    // Match Class L Fenix 7: load on draw rather than retain a background object.
    function drawBackground(dc as Graphics.Dc, dx as Lang.Number, dy as Lang.Number) as Void {
        dc.drawBitmap(-dx, -dy, WatchUi.loadResource(Rez.Drawables.background));
    }
}
