import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

module srv {
    module barometer {
        var label = null as WatchUi.Text?;
        var level = 0;
        var steps = [0.5, 0.25, 0.75] as [Lang.Float, Lang.Float];

        function initialize(drawable as WatchUi.Text) as Void {
            self.label = drawable;
            self.label.setFont(WatchUi.loadResource(Rez.Fonts.font16x16));
        }

        function update() as Void {
            if (Toybox has :SensorHistory && Toybox.SensorHistory has :getPressureHistory) {
                var sample = Toybox.SensorHistory.getPressureHistory({});
                self.level = srv.graphDataToFlat(sample, self.steps);
                self.label.setText((self.level / 100).format("%d"));
            }
        }

        function drawGraph(dc as Graphics.Dc) as Void {
            srv.arcGraph.draw(dc, 73, 78, self.steps[0], self.steps[1], self.steps[2],
                              0xAAAAAA, 0x555555);
        }

        function draw(dc as Graphics.Dc) as Void {
            self.label.draw(dc);
        }
    }
}
