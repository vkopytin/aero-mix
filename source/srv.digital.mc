import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

module srv {
    module digital {
        var currentHour = null as WatchUi.Text?;
        var currentMinute = null as WatchUi.Text?;

        function initialize(hourLabel as WatchUi.Text, minuteLabel as WatchUi.Text) as Void {
            self.currentHour = hourLabel;
            self.currentMinute = minuteLabel;
            var font = WatchUi.loadResource(Rez.Fonts.font14x22);
            self.currentHour.setFont(font);
            self.currentMinute.setFont(font);
        }

        function update(time as System.ClockTime) as Void {
            self.currentHour.setText(Lang.format("$1$:", [time.hour.format("%02d")]));
            self.currentMinute.setText(time.min.format("%02d"));
        }

        function draw(dc as Graphics.Dc) as Void {
            self.currentHour.draw(dc);
            self.currentMinute.draw(dc);
        }
    }
}
