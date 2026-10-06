import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Complications;

typedef DeviceTransform as Graphics.AffineTransform;

module Gfx {
    function createAffineTransform() as DeviceTransform { return new Graphics.AffineTransform(); }
    function createBufferedBitmap(options) as Graphics.BufferedBitmap {
        return Graphics.createBufferedBitmap(options).get();
    }
    function setAntiAlias(dc as Graphics.Dc) as Void { dc.setAntiAlias(true); }
    function loadHand(resource) { return WatchUi.loadResource(resource); }
    function drawHand(dc as Graphics.Dc, kind, bitmap, options) as Void {
        dc.drawBitmap2(0, 0, bitmap, options);
    }
    function drawIndicator(dc as Graphics.Dc, x, y, bitmap, options) as Void {
        dc.drawBitmap2(x, y, bitmap, options);
    }
    function drawTile(dc as Graphics.Dc, x, y, kind, sourceX, sourceY, width, height) as Void {
        var resource = Rez.Drawables.weatherConditions;
        if (kind == :moon) { resource = Rez.Drawables.moonPhaseTiles; }
        else if (kind == :twilight) { resource = Rez.Drawables.dayNightPhases; }
        // x/y are the widget destination; sourceX/Y only select the atlas tile.
        // Clip explicitly to avoid mixing drawBitmap2 source-region coordinates
        // with the atlas-origin offset used by drawBitmap.
        dc.setClip(x, y, width, height);
        dc.drawBitmap(x - sourceX, y - sourceY, WatchUi.loadResource(resource));
        dc.clearClip();
    }
    function registerComplications(callback) as Void {
        Complications.registerComplicationChangeCallback(callback);
    }
    function subscribeToComplications() as Void {
        var sunrise = new Complications.Id(Complications.COMPLICATION_TYPE_SUNRISE);
        var sunset = new Complications.Id(Complications.COMPLICATION_TYPE_SUNSET);
        var battery = new Complications.Id(Complications.COMPLICATION_TYPE_BATTERY);
        Complications.subscribeToUpdates(sunrise);
        Complications.subscribeToUpdates(sunset);
        Complications.subscribeToUpdates(battery);
        // Subscribing does not guarantee an immediate change callback.
        self.handleComplication(sunrise);
        self.handleComplication(sunset);
        self.handleComplication(battery);
    }
    function unsubscribeFromComplications() as Void { Complications.unsubscribeFromAllUpdates(); }
    function handleComplication(id as Complications.Id) as Void {
        var data = Complications.getComplication(id);
        if (data == null) { return; }
        switch (id.getType()) {
            case Complications.COMPLICATION_TYPE_SUNRISE:
            case Complications.COMPLICATION_TYPE_SUNSET:
                if (data.value != null) {
                    if (id.getType() == Complications.COMPLICATION_TYPE_SUNRISE) {
                        srv.twilight.sunriseTime = data.value;
                    } else { srv.twilight.sunsetTime = data.value; }
                }
                break;
            case Complications.COMPLICATION_TYPE_BATTERY:
                srv.battery.updateComplication(data.value);
                break;
        }
    }
    function updateSunTimes() as Void {}
    var batteryTexture = null as Graphics.BitmapTexture?;
    function initializeBatteryGauge() as Void {
        self.batteryTexture = new Graphics.BitmapTexture({
            :bitmap => WatchUi.loadResource(Rez.Drawables.batteryLevel)
        });
    }
    function drawBatteryGauge(dc as Graphics.Dc, x, y, width, height) as Void {
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.setFill(self.batteryTexture);
        dc.fillRectangle(x, y, width, height);
    }
}
