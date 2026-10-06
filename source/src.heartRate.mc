import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.Activity;

module srv {
    module heartRate {
        var label = null as WatchUi.Text?;
        var steps = [0.5, 0.25, 0.75] as [Lang.Float, Lang.Float];

        function initialize(drawable as WatchUi.Text) as Void {
            self.label = drawable;
            self.label.setFont(WatchUi.loadResource(Rez.Fonts.font18x18));
        }

        function update() as Void {
            if (Toybox has :SensorHistory && Toybox.SensorHistory has :getHeartRateHistory) {
                var sample = Toybox.SensorHistory.getHeartRateHistory({});
                srv.graphDataToFlat(sample, self.steps);
            }

            var info = Activity.getActivityInfo();
            if (info != null && info.currentHeartRate != null) {
                self.label.setText(info.currentHeartRate.format("%d"));
            }
        }

        function drawGraph(dc as Graphics.Dc) as Void {
            srv.arcGraph.draw(dc, 187, 78, self.steps[0], self.steps[1], self.steps[2],
                              0xAAAAAA, 0x555555);
        }

        function draw(dc as Graphics.Dc) as Void {
            self.label.draw(dc);
        }
    }
}
