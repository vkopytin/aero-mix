import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

module srv {
    module digital {
        var currentHour = cfg.currentHourInitialText;
        var currentMinute = cfg.currentMinuteInitialText;

        var bluetooth = cfg.bluetoothInitialText;
        var bluetoothColor = cfg.bluetoothColor;
        var alarmColor = cfg.alarmColor;
        var vibrateColor = cfg.vibrateColor;

        function updateStatus(settings as System.DeviceSettings) as Void {
            self.bluetooth = settings.phoneConnected ? "1" : "3";
            self.bluetoothColor = settings.phoneConnected ? 0x55AAAA : 0x000055;
            self.alarmColor = settings.alarmCount > 0 ? 0x55AAAA : 0x000055;
            self.vibrateColor = settings.vibrateOn ? 0x55AAAA : 0x000055;
        }

        function update(time as System.ClockTime) as Void {
            self.currentHour = Lang.format("$1$:", [time.hour.format("%02d")]);
            self.currentMinute = time.min.format("%02d");
        }

        function draw(dc as Graphics.Dc) as Void {
            if (cfg.currentHourVisible) {
                dc.setColor(cfg.currentHourColor, Graphics.COLOR_TRANSPARENT);
                dc.drawText(cfg.currentHourX, cfg.currentHourY, WatchUi.loadResource(Rez.Fonts.font14x22), self.currentHour, cfg.currentHourJustification);
            }
            if (cfg.currentMinuteVisible) {
                dc.setColor(cfg.currentMinuteColor, Graphics.COLOR_TRANSPARENT);
                dc.drawText(cfg.currentMinuteX, cfg.currentMinuteY, WatchUi.loadResource(Rez.Fonts.font14x22), self.currentMinute, cfg.currentMinuteJustification);
            }
        }
        function drawStatus(dc as Graphics.Dc) as Void {
            if (cfg.bluetoothVisible) {
                dc.setColor(self.bluetoothColor, Graphics.COLOR_TRANSPARENT);
                dc.drawText(cfg.bluetoothX, cfg.bluetoothY, WatchUi.loadResource(Rez.Fonts.system12), self.bluetooth, cfg.bluetoothJustification);
            }
            if (cfg.alarmVisible) {
                dc.setColor(self.alarmColor, Graphics.COLOR_TRANSPARENT);
                dc.drawText(cfg.alarmX, cfg.alarmY, WatchUi.loadResource(Rez.Fonts.system12), cfg.alarmInitialText, cfg.alarmJustification);
            }
            if (cfg.vibrateVisible) {
                dc.setColor(self.vibrateColor, Graphics.COLOR_TRANSPARENT);
                dc.drawText(cfg.vibrateX, cfg.vibrateY, WatchUi.loadResource(Rez.Fonts.system12), cfg.vibrateInitialText, cfg.vibrateJustification);
            }
        }
    }
}
