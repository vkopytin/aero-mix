import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

module lib {
    // Match Class L Fenix 7: load on draw rather than retain a background object.
    function drawBackground(dc as Graphics.Dc, dx as Lang.Number, dy as Lang.Number) as Void {
        dc.drawBitmap(-dx, -dy, WatchUi.loadResource(Rez.Drawables.background));
    }
}
