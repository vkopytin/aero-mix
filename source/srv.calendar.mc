import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.Time.Gregorian as Date;

module srv {
    module calendar {
        var weekDay = cfg.weekDayInitialText;
        var month = cfg.monthInitialText;
        var date = cfg.dateInitialText;

        var weekDayColor = cfg.weekDayColor;

        function update(info as Date.Info) as Void {
            self.weekDay = WatchUi.loadResource(Rez.JsonData.weekDays)[info.day_of_week];
            self.weekDayColor = info.day_of_week == Date.DAY_SUNDAY ? 0xFF0055 : 0xAA5500;
            self.month = WatchUi.loadResource(Rez.JsonData.months)[info.month];
            self.date = info.day.format("%02d");
        }

        // Separate draw calls preserve the order of the existing information layer.
        function drawWeekDay(dc as Graphics.Dc) as Void {
            if (cfg.weekDayVisible) {
                dc.setColor(self.weekDayColor, Graphics.COLOR_TRANSPARENT);
                dc.drawText(cfg.weekDayX, cfg.weekDayY, WatchUi.loadResource(Rez.Fonts.font6x12), self.weekDay, cfg.weekDayJustification);
            }
        }

        function drawDate(dc as Graphics.Dc) as Void {
            if (cfg.monthVisible) {
                dc.setColor(cfg.monthColor, Graphics.COLOR_TRANSPARENT);
                dc.drawText(cfg.monthX, cfg.monthY, WatchUi.loadResource(Rez.Fonts.font6x12), self.month, cfg.monthJustification);
            }
            if (cfg.dateVisible) {
                dc.setColor(cfg.dateColor, Graphics.COLOR_TRANSPARENT);
                dc.drawText(cfg.dateX, cfg.dateY, WatchUi.loadResource(Rez.Fonts.font18x18), self.date, cfg.dateJustification);
            }
        }
    }
}
