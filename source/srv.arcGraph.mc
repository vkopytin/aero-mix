import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.Math;

module srv {
    module arcGraph {
        var indicatorArrowBitmap = null as WatchUi.BitmapResource ? ;
        const transformIndicatorArrow = new Graphics.AffineTransform();
        const drawIndicatorArrowOptions = { :transform => self.transformIndicatorArrow };

        function initialize() as Void {
            self.indicatorArrowBitmap = WatchUi.loadResource(Rez.Drawables.indicatorArrow);
        }

        function draw(dc as Graphics.Dc, arcX, arcY, current as Float, step1 as Float, step2 as Float, step1Color,
                      step2Color) {
            var arcRadius = 25;
            // night arc
            dc.setPenWidth(2);
            dc.setColor(step1Color, Graphics.COLOR_TRANSPARENT);
            var sunriseAngle = 230 - 280 * step1;
            var sunsetAngle = 230 - 280 * step2;
            dc.drawArc(arcX, arcY, arcRadius, Graphics.ARC_CLOCKWISE, 230, sunriseAngle - 1);
            // day arc
            dc.setPenWidth(4);
            dc.setColor(step2Color, Graphics.COLOR_TRANSPARENT);
            dc.drawArc(arcX, arcY, arcRadius, Graphics.ARC_CLOCKWISE, sunriseAngle, sunsetAngle - 1);
            // night arc
            dc.setPenWidth(2);
            dc.setColor(step1Color, Graphics.COLOR_TRANSPARENT);
            dc.drawArc(arcX, arcY, arcRadius, Graphics.ARC_CLOCKWISE, sunsetAngle, -50);

            self.transformIndicatorArrow.initialize();
            self.transformIndicatorArrow.rotate((-50 + 280.0 * current) * Math.PI / 180.0);
            self.transformIndicatorArrow.translate(-27.0, -5.0);

            dc.drawBitmap2(arcX, arcY, self.indicatorArrowBitmap, self.drawIndicatorArrowOptions);
        }
    }
}
