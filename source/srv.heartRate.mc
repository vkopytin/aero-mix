import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.Activity;

module srv {
    module heartRate {
        var text = cfg.heartRateInitialText;
        var steps = WatchUi.loadResource(Rez.JsonData.graphSteps) as Array<Lang.Float>;

        function update() as Void {
            if (Toybox has :SensorHistory && Toybox.SensorHistory has :getHeartRateHistory) {
                var sample = Toybox.SensorHistory.getHeartRateHistory({});
                srv.graphDataToFlat(sample, self.steps);
            }

            var info = Activity.getActivityInfo();
            if (info != null && info.currentHeartRate != null) {
                self.text = info.currentHeartRate.format("%d");
            }
        }

        function drawGraph(dc as Graphics.Dc) as Void {
            srv.arcGraph.draw(dc, 187, 78, self.steps[0], self.steps[1], self.steps[2],
                              0xAAAAAA, 0x555555);
        }

        function draw(dc as Graphics.Dc) as Void {
            if (cfg.heartRateVisible) {
                dc.setColor(cfg.heartRateColor, Graphics.COLOR_TRANSPARENT);
                dc.drawText(cfg.heartRateX, cfg.heartRateY, WatchUi.loadResource(Rez.Fonts.font18x18), self.text, cfg.heartRateJustification);
            }
        }
    }
}
