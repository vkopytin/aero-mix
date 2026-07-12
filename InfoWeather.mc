import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Activity;
import Toybox.Application;

class InfoWeather extends WatchUi.Drawable {
    private var weatherConditions = null as WatchUi.BitmapResource;
    private var color = Graphics.COLOR_BLACK;
    private var colorAccent = 0xAA5500;
    private var font = Graphics.FONT_TINY;

    function initialize(params) {
        self.weatherConditions = WatchUi.loadResource(@Rez.Drawables.weatherConditions);
        Drawable.initialize(params);
        self.color = params.get(:color);
    }

    function draw(dc as Dc) {
        Drawable.draw(dc);

        self.drawWeatherIcon(dc, self.locX, self.locY, self.locX, self.color);
        self.drawTemperature(dc, self.locX + 6, self.locY + 36, false, self.color);
    }

    function drawWeatherIcon(dc, x, y, x2, fontColor) {
        var weather = Toybox.Weather.getCurrentConditions();
        if (weather == null) {
            dc.drawBitmap2(
                x - 10,
                y - 26,
                self.weatherConditions, {
                :bitmapX => 10,
                :bitmapY => 24,
                :bitmapWidth => 40,
                :bitmapHeight => 40
            });
            return false;
        }
        var cond = weather.condition;
        var sunset, sunrise;

        if (cond != null and cond instanceof Number) {
            var clockTime = System.getClockTime().hour;

            // gets the correct symbol (sun/moon) depending on actual sun events
            var position =
                Toybox.Weather.getCurrentConditions()
                    .observationLocationPosition;  // or
                                                // Activity.Info.currentLocation
                                                // if observation is null?
            var today =
                Toybox.Weather.getCurrentConditions()
                    .observationTime;  // or new Time.Moment(Time.now().value()); ?

            if (position != null and today != null) {
                if (Weather.getSunset(position, today) != null) {
                    sunset = Time.Gregorian.info(Weather.getSunset(position, today),
                                                Time.FORMAT_SHORT);
                    sunset = sunset.hour;
                } else {
                    sunset = 18;
                }
                if (Weather.getSunrise(position, today) != null) {
                    sunrise = Time.Gregorian.info(Weather.getSunrise(position, today),
                                                Time.FORMAT_SHORT);
                    sunrise = sunrise.hour;
                } else {
                    sunrise = 6;
                }
            } else {
                sunset = 18;
                sunrise = 6;
            }

            // weather icon test
            // cond = Weather.CONDITION_UNKNOWN;
            var tileCoordinates = [10, 26];
            switch (cond) {
                case Weather.CONDITION_CLEAR:
                    tileCoordinates = [10, 26];
                    break;
                case Weather.CONDITION_PARTLY_CLOUDY:
                    tileCoordinates = [80, 26];
                    break;
                case Weather.CONDITION_MOSTLY_CLOUDY:
                    tileCoordinates = [145, 26];
                    break;
                case Weather.CONDITION_RAIN:
                    tileCoordinates = [216, 26];
                    break;
                case Weather.CONDITION_SNOW:
                    tileCoordinates = [280, 26];
                    break;
                case Weather.CONDITION_WINDY:
                    tileCoordinates = [350, 28];
                    break;
                case Weather.CONDITION_THUNDERSTORMS:
                    tileCoordinates = [414, 27];
                    break;
                case Weather.CONDITION_WINTRY_MIX:
                    tileCoordinates = [480, 27];
                    break;
                case Weather.CONDITION_FOG:
                    tileCoordinates = [548, 27];
                    break;
                case Weather.CONDITION_HAZY:
                    tileCoordinates = [614, 27];
                    break;
                case Weather.CONDITION_HAIL:
                    tileCoordinates = [10, 100];
                    break;
                case Weather.CONDITION_SCATTERED_SHOWERS:
                    tileCoordinates = [76, 102];
                    break;
                case Weather.CONDITION_SCATTERED_THUNDERSTORMS:
                    tileCoordinates = [146, 102];
                    break;
                case Weather.CONDITION_UNKNOWN_PRECIPITATION:
                    tileCoordinates = [214, 102];
                    break;
                case Weather.CONDITION_LIGHT_RAIN:
                    tileCoordinates = [282, 100];
                    break;
                case Weather.CONDITION_HEAVY_RAIN:
                    tileCoordinates = [348, 100];
                    break;
                case Weather.CONDITION_LIGHT_SNOW:
                    tileCoordinates = [414, 100];
                    break;
                case Weather.CONDITION_HEAVY_SNOW:
                    tileCoordinates = [480, 100];
                    break;
                case Weather.CONDITION_LIGHT_RAIN_SNOW:
                    tileCoordinates = [548, 101];
                    break;
                case Weather.CONDITION_HEAVY_RAIN_SNOW:
                    tileCoordinates = [614, 101];
                    break;
                case Weather.CONDITION_CLOUDY:
                    tileCoordinates = [10, 173];
                    break;
                case Weather.CONDITION_RAIN_SNOW:
                    tileCoordinates = [76, 173];
                    break;
                case Weather.CONDITION_PARTLY_CLEAR:
                    tileCoordinates = [146, 173];
                    break;
                case Weather.CONDITION_MOSTLY_CLEAR:
                    tileCoordinates = [214, 173];
                    break;
                case Weather.CONDITION_LIGHT_SHOWERS:
                    tileCoordinates = [282, 175];
                    break;
                case Weather.CONDITION_SHOWERS:
                    tileCoordinates = [348, 172];
                    break;
                case Weather.CONDITION_HEAVY_SHOWERS:
                    tileCoordinates = [414, 173];
                    break;
                case Weather.CONDITION_CHANCE_OF_SHOWERS:
                    tileCoordinates = [480, 175];
                    break;
                case Weather.CONDITION_CHANCE_OF_THUNDERSTORMS:
                    tileCoordinates = [548, 175];
                    break;
                case Weather.CONDITION_MIST:
                    tileCoordinates = [614, 175];
                    break;
                case Weather.CONDITION_DUST:
                    tileCoordinates = [10, 241];
                    break;
                case Weather.CONDITION_DRIZZLE:
                    tileCoordinates = [76, 241];
                    break;
                case Weather.CONDITION_TORNADO:
                    tileCoordinates = [146, 240];
                    break;
                case Weather.CONDITION_SMOKE:
                    tileCoordinates = [214, 242];
                    break;
                case Weather.CONDITION_ICE:
                    tileCoordinates = [282, 242];
                    break;
                case Weather.CONDITION_SAND:
                    tileCoordinates = [344, 242];
                    break;
                case Weather.CONDITION_SQUALL:
                    tileCoordinates = [412, 242];
                    break;
                case Weather.CONDITION_SANDSTORM:
                    tileCoordinates = [480, 242];
                    break;
                case Weather.CONDITION_VOLCANIC_ASH:
                    tileCoordinates = [548, 240];
                    break;
                case Weather.CONDITION_HAZE:
                    tileCoordinates = [614, 242];
                    break;
                case Weather.CONDITION_FAIR:
                    tileCoordinates = [10, 308];
                    break;
                case Weather.CONDITION_HURRICANE:
                    tileCoordinates = [76, 308];
                    break;
                case Weather.CONDITION_TROPICAL_STORM:
                    tileCoordinates = [146, 308];
                    break;
                case Weather.CONDITION_CHANCE_OF_SNOW:
                    tileCoordinates = [214, 312];
                    break;
                case Weather.CONDITION_CHANCE_OF_RAIN_SNOW:
                    tileCoordinates = [280, 312];
                    break;
                case Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN:
                    tileCoordinates = [344, 312];
                    break;
                case Weather.CONDITION_CLOUDY_CHANCE_OF_SNOW:
                    tileCoordinates = [412, 312];
                    break;
                case Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN_SNOW:
                    tileCoordinates = [480, 312];
                    break;
                case Weather.CONDITION_FLURRIES:
                    tileCoordinates = [548, 308];
                    break;
                case Weather.CONDITION_FREEZING_RAIN:
                    tileCoordinates = [614, 308];
                    break;
                case Weather.CONDITION_SLEET:
                    tileCoordinates = [10, 371];
                    break;
                case Weather.CONDITION_ICE_SNOW:
                    tileCoordinates = [77, 371];
                    break;
                case Weather.CONDITION_THIN_CLOUDS:
                    tileCoordinates = [146, 371];
                    break;
                case Weather.CONDITION_UNKNOWN:
                default:
                    tileCoordinates = [214, 371];
            }
            dc.drawBitmap2(
                x - tileCoordinates[0],
                y - tileCoordinates[1],
                self.weatherConditions, {
                :bitmapX => tileCoordinates[0],
                :bitmapY => tileCoordinates[1],
                :bitmapWidth => 44,
                :bitmapHeight => 41
            });

            return true;
        } else {
            return false;
        }
    }

  function drawTemperature(dc, x, y, showBoolean, fontColor) {
    var TempMetric = System.getDeviceSettings().temperatureUnits;
    var temp = null, units = "", minTemp = null, maxTemp = null;
    var weather = Weather.getCurrentConditions();
    if (weather == null) {
      return;
    }

    if ((weather.lowTemperature != null) and (weather.highTemperature != null)) {
        // and weather.lowTemperature instanceof Number ;  and
        // weather.highTemperature instanceof Number
      minTemp = weather.lowTemperature;
      maxTemp = weather.highTemperature;
    }

    var offset = 0;

    if (showBoolean == false and
        (weather.feelsLikeTemperature !=
         null)) {  // feels like ;  and weather.feelsLikeTemperature instanceof
                   // Number
      if (TempMetric == System.UNIT_METRIC or
          Storage.getValue(16) == true) {  // Celsius
        units = "°"; // C
        temp = weather.feelsLikeTemperature;
      } else {
        temp = (weather.feelsLikeTemperature * 9 / 5) + 32;
        if (minTemp != null and maxTemp != null) {
          minTemp = (minTemp * 9 / 5) + 32;
          maxTemp = (maxTemp * 9 / 5) + 32;
        }
        // temp = Lang.format("$1$", [temp.format("%d")] );
        units = "°"; // F
      }
    } else if ((weather.temperature != null)) {
      // real temperature ;  and weather.temperature
      // instanceof Number
      if (TempMetric == System.UNIT_METRIC or
          Storage.getValue(16) == true) {  // Celsius
        units = "°"; // C
        temp = weather.temperature;
      } else {
        temp = (weather.temperature * 9 / 5) + 32;
        if (minTemp != null and maxTemp != null) {
          minTemp = (minTemp * 9 / 5) + 32;
          maxTemp = (maxTemp * 9 / 5) + 32;
        }
        // temp = Lang.format("$1$", [temp.format("%d")] );
        units = "°"; // F
      }
    }

    if (temp != null) {  // and temp instanceof Number
      dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
      if ((minTemp != null) and
          (maxTemp != null)) {  //  and minTemp instanceof Number ;  and maxTemp
                                //  instanceof Number
        if (temp <= minTemp) {
          if (fontColor == Graphics.COLOR_WHITE) {  // Dark Theme
            dc.setColor(Graphics.COLOR_BLUE,
                        Graphics.COLOR_TRANSPARENT);  // Light Blue 0x55AAFF
          } else {                                    // Light Theme
            dc.setColor(0x0055AA, Graphics.COLOR_TRANSPARENT);
          }
        } else if (temp >= maxTemp) {
          if (fontColor == Graphics.COLOR_WHITE) {              // Dark Theme
            dc.setColor(0xFFAA00, Graphics.COLOR_TRANSPARENT);  // Light Orange
          } else {                                              // Light Theme
            dc.setColor(0xAA5500, Graphics.COLOR_TRANSPARENT);
          }
        }
      }

      temp = temp.format("%d");

      dc.drawText(x, y + offset, self.font, temp,
                  Graphics.TEXT_JUSTIFY_LEFT);
      dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
      dc.drawText(x + dc.getTextWidthInPixels(temp, self.font),
                  y + offset, self.font, units,
                  Graphics.TEXT_JUSTIFY_LEFT);
    }
  }
}
