import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
module lib {
    const pieces = [Rez.Drawables.bg_0_0, Rez.Drawables.bg_0_1, Rez.Drawables.bg_0_2, Rez.Drawables.bg_0_3, Rez.Drawables.bg_1_0, Rez.Drawables.bg_1_1, Rez.Drawables.bg_1_2, Rez.Drawables.bg_1_3, Rez.Drawables.bg_2_0, Rez.Drawables.bg_2_1, Rez.Drawables.bg_2_2, Rez.Drawables.bg_2_3, Rez.Drawables.bg_3_0, Rez.Drawables.bg_3_1, Rez.Drawables.bg_3_2, Rez.Drawables.bg_3_3];
    // Resource selectors stay in code; no retained dictionary or string keys.
    function tileResource(kind, x, y) {
        var key = x * 1024 + y;
        if (kind == :moon) { key += 1000000; }
        else if (kind == :twilight) { key += 2000000; }
        switch (key) {
            case 10264: return Rez.Drawables.weather_10_24;
            case 10266: return Rez.Drawables.weather_10_26;
            case 10340: return Rez.Drawables.weather_10_100;
            case 10413: return Rez.Drawables.weather_10_173;
            case 10481: return Rez.Drawables.weather_10_241;
            case 10548: return Rez.Drawables.weather_10_308;
            case 10611: return Rez.Drawables.weather_10_371;
            case 77926: return Rez.Drawables.weather_76_102;
            case 77997: return Rez.Drawables.weather_76_173;
            case 78065: return Rez.Drawables.weather_76_241;
            case 78132: return Rez.Drawables.weather_76_308;
            case 79219: return Rez.Drawables.weather_77_371;
            case 81946: return Rez.Drawables.weather_80_26;
            case 148506: return Rez.Drawables.weather_145_26;
            case 149606: return Rez.Drawables.weather_146_102;
            case 149677: return Rez.Drawables.weather_146_173;
            case 149744: return Rez.Drawables.weather_146_240;
            case 149812: return Rez.Drawables.weather_146_308;
            case 149875: return Rez.Drawables.weather_146_371;
            case 219238: return Rez.Drawables.weather_214_102;
            case 219309: return Rez.Drawables.weather_214_173;
            case 219378: return Rez.Drawables.weather_214_242;
            case 219448: return Rez.Drawables.weather_214_312;
            case 219507: return Rez.Drawables.weather_214_371;
            case 221210: return Rez.Drawables.weather_216_26;
            case 286746: return Rez.Drawables.weather_280_26;
            case 287032: return Rez.Drawables.weather_280_312;
            case 288868: return Rez.Drawables.weather_282_100;
            case 288943: return Rez.Drawables.weather_282_175;
            case 289010: return Rez.Drawables.weather_282_242;
            case 352498: return Rez.Drawables.weather_344_242;
            case 352568: return Rez.Drawables.weather_344_312;
            case 356452: return Rez.Drawables.weather_348_100;
            case 356524: return Rez.Drawables.weather_348_172;
            case 358428: return Rez.Drawables.weather_350_28;
            case 422130: return Rez.Drawables.weather_412_242;
            case 422200: return Rez.Drawables.weather_412_312;
            case 423963: return Rez.Drawables.weather_414_27;
            case 424036: return Rez.Drawables.weather_414_100;
            case 424109: return Rez.Drawables.weather_414_173;
            case 491547: return Rez.Drawables.weather_480_27;
            case 491620: return Rez.Drawables.weather_480_100;
            case 491695: return Rez.Drawables.weather_480_175;
            case 491762: return Rez.Drawables.weather_480_242;
            case 491832: return Rez.Drawables.weather_480_312;
            case 561179: return Rez.Drawables.weather_548_27;
            case 561253: return Rez.Drawables.weather_548_101;
            case 561327: return Rez.Drawables.weather_548_175;
            case 561392: return Rez.Drawables.weather_548_240;
            case 561460: return Rez.Drawables.weather_548_308;
            case 628763: return Rez.Drawables.weather_614_27;
            case 628837: return Rez.Drawables.weather_614_101;
            case 628911: return Rez.Drawables.weather_614_175;
            case 628978: return Rez.Drawables.weather_614_242;
            case 629044: return Rez.Drawables.weather_614_308;
            case 1015375: return Rez.Drawables.moon_15_15;
            case 1022572: return Rez.Drawables.moon_22_44;
            case 1022713: return Rez.Drawables.moon_22_185;
            case 1024892: return Rez.Drawables.moon_24_316;
            case 1099372: return Rez.Drawables.moon_97_44;
            case 1100537: return Rez.Drawables.moon_98_185;
            case 1100668: return Rez.Drawables.moon_98_316;
            case 1173100: return Rez.Drawables.moon_169_44;
            case 1173241: return Rez.Drawables.moon_169_185;
            case 1174396: return Rez.Drawables.moon_170_316;
            case 1246828: return Rez.Drawables.moon_241_44;
            case 1247993: return Rez.Drawables.moon_242_185;
            case 1248124: return Rez.Drawables.moon_242_316;
            case 1318508: return Rez.Drawables.moon_311_44;
            case 1321721: return Rez.Drawables.moon_314_185;
            case 1321852: return Rez.Drawables.moon_314_316;
            case 1394284: return Rez.Drawables.moon_385_44;
            case 1394425: return Rez.Drawables.moon_385_185;
            case 1395580: return Rez.Drawables.moon_386_316;
            case 1468012: return Rez.Drawables.moon_457_44;
            case 1469177: return Rez.Drawables.moon_458_185;
            case 1470332: return Rez.Drawables.moon_459_316;
            case 1541881: return Rez.Drawables.moon_529_185;
            case 1542764: return Rez.Drawables.moon_530_44;
            case 1543036: return Rez.Drawables.moon_530_316;
            case 1617516: return Rez.Drawables.moon_603_44;
            case 1617657: return Rez.Drawables.moon_603_185;
            case 1690220: return Rez.Drawables.moon_674_44;
            case 1692409: return Rez.Drawables.moon_676_185;
            case 2021577: return Rez.Drawables.twilight_21_73;
            case 2083017: return Rez.Drawables.twilight_81_73;
            case 2143433: return Rez.Drawables.twilight_140_73;
            case 2204873: return Rez.Drawables.twilight_200_73;
            case 2266313: return Rez.Drawables.twilight_260_73;
            case 2331849: return Rez.Drawables.twilight_324_73;
        }
        return Rez.Drawables.weather_10_24;
    }
    function initializeSecondsHand() as Void {}

    function drawSecondsHand(dc as Graphics.Dc, options) as Void {
        var transformedCoords = options[:transform].transformPoints(cfg.secondsHandCoordinates)
                                    as Lang.Array<Graphics.Point2D>;

        dc.setColor(0xFFAA00, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawLine(transformedCoords[0][0], transformedCoords[0][1], transformedCoords[1][0], transformedCoords[1][1]);
        dc.drawLine(transformedCoords[2][0], transformedCoords[2][1], transformedCoords[3][0], transformedCoords[3][1]);
    }

    function drawBackground(dc as Graphics.Dc, dx as Lang.Number, dy as Lang.Number) as Void {
        for (var i = 0; i < 16; i++) {
            dc.drawBitmap((i % 4) * 65 - dx, (i / 4).toNumber() * 65 - dy,
                          WatchUi.loadResource(self.pieces[i]));
        }
    }
}
