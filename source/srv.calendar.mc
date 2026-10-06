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

        var weekDay = null as WatchUi.Text ? ;
        var month = null as WatchUi.Text   ? ;
        var date = null as WatchUi.Text    ? ;

        function initialize(weekDayLabel as WatchUi.Text, monthLabel as WatchUi.Text, dateLabel as WatchUi.Text)
            as Void {
            self.weekDay = weekDayLabel;
            self.month = monthLabel;
            self.date = dateLabel;
            self.weekDay.setFont(WatchUi.loadResource(Rez.Fonts.font6x12));
            self.month.setFont(WatchUi.loadResource(Rez.Fonts.font6x12));
            self.date.setFont(WatchUi.loadResource(Rez.Fonts.font18x18));
        }

        function update(info as Date.Info) as Void {
            self.weekDay.setText(self.WEEK_DAYS[info.day_of_week]);
            self.weekDay.setColor(info.day_of_week == Date.DAY_SUNDAY ? 0xFF0055 : 0xAA5500);
            self.month.setText(self.MONTHS[info.month]);
            self.date.setText(info.day.format("%02d"));
        }

        // Separate draw calls preserve the order of the existing information layer.
        function drawWeekDay(dc as Graphics.Dc) as Void { self.weekDay.draw(dc); }

        function drawDate(dc as Graphics.Dc) as Void {
            self.month.draw(dc);
            self.date.draw(dc);
        }
    }
}
