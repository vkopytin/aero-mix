import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

module srv {
    module barometer {
        var text = cfg.barometerInitialText;
        var level = 0;
        var steps = WatchUi.loadResource(Rez.JsonData.graphSteps) as Array<Lang.Float>;

        function update() as Void {
            if (Toybox has :SensorHistory && Toybox.SensorHistory has :getPressureHistory) {
                var sample = Toybox.SensorHistory.getPressureHistory({});
                self.level = srv.graphDataToFlat(sample, self.steps);
                self.text = (self.level / 100).format("%d");
            }
        }

        function drawGraph(dc as Graphics.Dc) as Void {
            srv.arcGraph.draw(dc, 73, 78, self.steps[0], self.steps[1], self.steps[2],
                              0xAAAAAA, 0x555555);
        }

        function draw(dc as Graphics.Dc) as Void {
            if (cfg.barometerVisible) {
                dc.setColor(cfg.barometerColor, Graphics.COLOR_TRANSPARENT);
                dc.drawText(cfg.barometerX, cfg.barometerY, WatchUi.loadResource(Rez.Fonts.font16x16), self.text, cfg.barometerJustification);
            }
        }
    }
}
