import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.ActivityMonitor;

module srv {
    module steps {
        var text = cfg.stepsCountInitialText;
        var font = null as WatchUi.FontResource?;
        var history = new [28] as Array<Graphics.Point2D>;

        function initialize() as Void {
            self.font = WatchUi.loadResource(Rez.Fonts.font8x16);
            for (var i = 0; i < self.history.size(); i++) {
                self.history[i] = [0, 0];
            }
        }

        function update() as Void {
            var info = ActivityMonitor.getInfo();
            if (info != null && info.steps != null) {
                self.text = info.steps.format("%d");
            }
            if (Toybox has :SensorHistory) {
                srv.stepsHistoryToArray(78, 164, self.history);
                for (var i = 0; i < self.history.size(); i++) {
                    self.history[i][0] -= cfg.bufferDx;
                    self.history[i][1] -= cfg.bufferDy;
                }
            }
        }

        function drawLabel(dc as Graphics.Dc) as Void {
            if (cfg.stepsLabelVisible) {
                dc.setColor(cfg.stepsLabelColor, Graphics.COLOR_TRANSPARENT);
                dc.drawText(cfg.stepsLabelX, cfg.stepsLabelY, self.font, cfg.stepsLabelInitialText,
                            cfg.stepsLabelJustification);
            }
        }

        function draw(dc as Graphics.Dc) as Void {
            if (cfg.stepsCountVisible) {
                dc.setColor(cfg.stepsCountColor, Graphics.COLOR_TRANSPARENT);
                dc.drawText(cfg.stepsCountX, cfg.stepsCountY, self.font, self.text, cfg.stepsCountJustification);
            }
        }

        function drawGraph(dc as Graphics.Dc) as Void {
            dc.setColor(0x55AAAA, Graphics.COLOR_TRANSPARENT);
            dc.fillPolygon(self.history);
        }
    }
}
