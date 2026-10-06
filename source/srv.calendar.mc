import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.Time.Gregorian as Date;

module srv {
    module calendar {
        const WEEK_DAYS = ["", "SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
        const MONTHS = { Date.MONTH_JANUARY => "JAN", Date.MONTH_FEBRUARY => "FEB", Date.MONTH_MARCH => "MAR",
                         Date.MONTH_APRIL => "APR",   Date.MONTH_MAY => "MAY",      Date.MONTH_JUNE => "JUN",
                         Date.MONTH_JULY => "JUL",    Date.MONTH_AUGUST => "AUG",   Date.MONTH_SEPTEMBER => "SEP",
                         Date.MONTH_OCTOBER => "OCT", Date.MONTH_NOVEMBER => "NOV", Date.MONTH_DECEMBER => "DEC" };

        var weekDay = cfg.weekDayInitialText;
        var month = cfg.monthInitialText;
        var date = cfg.dateInitialText;

        var weekDayColor = cfg.weekDayColor;
        var smallFont = null as WatchUi.FontResource?;
        var dateFont = null as WatchUi.FontResource?;

        function initialize() as Void {
            self.smallFont = WatchUi.loadResource(Rez.Fonts.font6x12);
            self.dateFont = WatchUi.loadResource(Rez.Fonts.font18x18);
        }

        function update(info as Date.Info) as Void {
            self.weekDay = self.WEEK_DAYS[info.day_of_week];
            self.weekDayColor = info.day_of_week == Date.DAY_SUNDAY ? 0xFF0055 : 0xAA5500;
            self.month = self.MONTHS[info.month];
            self.date = info.day.format("%02d");
        }

        // Separate draw calls preserve the order of the existing information layer.
        function drawWeekDay(dc as Graphics.Dc) as Void {
            if (cfg.weekDayVisible) {
                dc.setColor(self.weekDayColor, Graphics.COLOR_TRANSPARENT);
                dc.drawText(cfg.weekDayX, cfg.weekDayY, self.smallFont, self.weekDay, cfg.weekDayJustification);
            }
        }

        function drawDate(dc as Graphics.Dc) as Void {
            if (cfg.monthVisible) {
                dc.setColor(cfg.monthColor, Graphics.COLOR_TRANSPARENT);
                dc.drawText(cfg.monthX, cfg.monthY, self.smallFont, self.month, cfg.monthJustification);
            }
            if (cfg.dateVisible) {
                dc.setColor(cfg.dateColor, Graphics.COLOR_TRANSPARENT);
                dc.drawText(cfg.dateX, cfg.dateY, self.dateFont, self.date, cfg.dateJustification);
            }
        }
    }
}
