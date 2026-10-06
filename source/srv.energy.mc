import Toybox.Graphics;
import Toybox.Lang;

module srv {
    module energy {
        var text = cfg.energyLevelInitialText;

        function update() as Void {
            if (Toybox has :SensorHistory) {
                var iterator = Toybox.SensorHistory.getBodyBatteryHistory({ :period => 1 });
                var sample = iterator.next();
                if (sample != null && sample.data != null) {
                    self.text = Lang.format("$1$%", [sample.data.format("%d")]);
                }
            }
        }

        function draw(dc as Graphics.Dc) as Void {
            if (cfg.energyLevelVisible) {
                dc.setColor(cfg.energyLevelColor, Graphics.COLOR_TRANSPARENT);
                dc.drawText(cfg.energyLevelX, cfg.energyLevelY, Graphics.FONT_GLANCE, self.text,
                            cfg.energyLevelJustification);
            }
        }
    }
}
