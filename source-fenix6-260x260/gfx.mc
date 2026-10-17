import Toybox.Math;
import Toybox.Weather;
import Toybox.Time;
using Toybox.Time.Gregorian as Date;
typedef DeviceTransform as Gfx.AffineTransform;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Activity;

typedef CreateBufferedBitmapOptions as { :width as Number, :height as Number };

module Gfx {
    class AffineTransform {
        private var m00 = 1.0;
        private var m01 = 0.0;
        private var m02 = 0.0;
        private var m10 = 0.0;
        private var m11 = 1.0;
        private var m12 = 0.0;

        function initialize() {
            self.m00 = 1.0;
            self.m01 = 0.0;
            self.m02 = 0.0;
            self.m10 = 0.0;
            self.m11 = 1.0;
            self.m12 = 0.0;
        }

        function translate(tx as Numeric, ty as Numeric) as Void {
            self.m02 += tx * self.m00 + ty * self.m01;
            self.m12 += tx * self.m10 + ty * self.m11;
        }

        function scale(sx as Numeric, sy as Numeric) as Void {
            self.m00 *= sx;
            self.m01 *= sy;
            self.m10 *= sx;
            self.m11 *= sy;
        }

        function rotate(theta as Numeric) as Void {
            var cosTheta = Math.cos(theta);
            var sinTheta = Math.sin(theta);

            var m00New = self.m00 * cosTheta + self.m01 * sinTheta;
            var m01New = -self.m00 * sinTheta + self.m01 * cosTheta;
            var m10New = self.m10 * cosTheta + self.m11 * sinTheta;
            var m11New = -self.m10 * sinTheta + self.m11 * cosTheta;

            self.m00 = m00New;
            self.m01 = m01New;
            self.m10 = m10New;
            self.m11 = m11New;
        }

        function transformPoint(x, y, point, dx, dy) as Void {
            point[0] = self.m00 * x + self.m01 * y + self.m02 + dx;
            point[1] = self.m10 * x + self.m11 * y + self.m12 + dy;
        }

        function transformPoints(points as Array<Point2D>) as Array<Point2D> {
            var transformedPoints = new Array<Point2D>[points.size()];
            for (var i = 0; i < points.size(); i++) {
                var x = points[i][0];
                var y = points[i][1];
                var newX = self.m00 * x + self.m01 * y + self.m02;
                var newY = self.m10 * x + self.m11 * y + self.m12;
                transformedPoints[i] = [newX, newY];
            }
            return transformedPoints;
        }
    }
    function createAffineTransform() as Gfx.AffineTransform { return new Gfx.AffineTransform(); }

    function createBufferedBitmap(options as CreateBufferedBitmapOptions) as Graphics.BufferedBitmap {
        return new Graphics.BufferedBitmap(options);
    }

    function drawAlwaysOn(dc as Graphics.Dc) as Void {}

    function setAntiAlias(dc as Graphics.Dc) as Void {}
    function loadHand(resource) { return null; }
    function drawHand(dc as Graphics.Dc, kind, bitmap, options) as Void {
        var resource = Rez.JsonData.hourGeometry;
        if (kind == :minute) {
            resource = Rez.JsonData.minuteGeometry;
        }
        drawGeometry(dc, resource, options[:transform], 0, 0);
    }

    function drawIndicator(dc as Graphics.Dc, x, y, bitmap, options) as Void {
        drawGeometry(dc, Rez.JsonData.indicatorGeometry, options[:transform], x, y);
    }

    // Each strip is [color, x0, y0, x1, y1]. Reuse the four point arrays.
    function drawGeometry(dc as Graphics.Dc, resource, transform, dx, dy) as Void {
        var strips = WatchUi.loadResource(resource);
        var points = WatchUi.loadResource(Rez.JsonData.geometryPoints) as Array<Graphics.Point2D>;
        for (var i = 0; i < strips.size(); i += 5) {
            transform.transformPoint(strips[i + 1], strips[i + 2], points[0], dx, dy);
            transform.transformPoint(strips[i + 3], strips[i + 2], points[1], dx, dy);
            transform.transformPoint(strips[i + 3], strips[i + 4], points[2], dx, dy);
            transform.transformPoint(strips[i + 1], strips[i + 4], points[3], dx, dy);
            dc.setColor(strips[i], Graphics.COLOR_TRANSPARENT);
            dc.fillPolygon(points);
        }
    }

    function drawTile(dc as Graphics.Dc, x, y, kind, sourceX, sourceY, width, height) as Void {
        dc.drawBitmap(x, y, WatchUi.loadResource(lib.tileResource(kind, sourceX, sourceY)));
    }
    function registerComplications(callback) as Void {}
    function subscribeToComplications() as Void {}
    function unsubscribeFromComplications() as Void {}
    function handleComplication(id) as Void {}
    function updateSunTimes() as Void {
        var conditions = Weather.getCurrentConditions();
        if (conditions == null || conditions.observationLocationPosition == null) {
            return;
        }
        var now = Time.now();
        var sunrise = Weather.getSunrise(conditions.observationLocationPosition, now);
        var sunset = Weather.getSunset(conditions.observationLocationPosition, now);
        if (sunrise != null && sunset != null) {
            var rise = Date.info(sunrise, Time.FORMAT_SHORT);
            var set = Date.info(sunset, Time.FORMAT_SHORT);
            srv.twilight.setSunTimes(rise.hour * 3600 + rise.min * 60 + rise.sec,
                                     set.hour * 3600 + set.min * 60 + set.sec);
        }
    }
    function initializeBatteryGauge() as Void {}
    function drawBatteryGauge(dc as Graphics.Dc, x, y, width, height) as Void {
        dc.setClip(x, y, width, height);
        dc.drawBitmap(x, y, WatchUi.loadResource(Rez.Drawables.batteryLevel));
        dc.clearClip();
    }
}
