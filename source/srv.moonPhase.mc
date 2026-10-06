import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.Math;
using Toybox.Time;
module srv {
    module moonPhase {
        const EPOCH = 2440587.5;
        const SYNODIC_MONTH = 29.53058770576;
        var phaseTile = WatchUi.loadResource(Rez.JsonData.moonPhaseTile) as Array<Number>;

        function update(now as Time.Moment) as Void {
            var phase = self.calculate(now);
            if (phase < 0.9843529235253333) {
                self.phaseTile[0] = 22;
                self.phaseTile[1] = 44;
            } else if (phase < 1.9687058470506666) {
                self.phaseTile[0] = 97;
                self.phaseTile[1] = 44;
            } else if (phase < 2.953058770576) {
                self.phaseTile[0] = 169;
                self.phaseTile[1] = 44;
            } else if (phase < 3.9374116941013333) {
                self.phaseTile[0] = 241;
                self.phaseTile[1] = 44;
            } else if (phase < 4.921764617626667) {
                self.phaseTile[0] = 311;
                self.phaseTile[1] = 44;
            } else if (phase < 5.906117541152) {
                self.phaseTile[0] = 385;
                self.phaseTile[1] = 44;
            } else if (phase < 6.890470464677334) {
                self.phaseTile[0] = 457;
                self.phaseTile[1] = 44;
            } else if (phase < 7.874823388202667) {
                self.phaseTile[0] = 530;
                self.phaseTile[1] = 44;
            } else if (phase < 8.859176311728) {
                self.phaseTile[0] = 603;
                self.phaseTile[1] = 44;
            } else if (phase < 9.843529235253333) {
                self.phaseTile[0] = 674;
                self.phaseTile[1] = 44;
            } else if (phase < 10.827882158778667) {
                self.phaseTile[0] = 22;
                self.phaseTile[1] = 185;
            } else if (phase < 11.812235082304) {
                self.phaseTile[0] = 98;
                self.phaseTile[1] = 185;
            } else if (phase < 12.796588005829333) {
                self.phaseTile[0] = 169;
                self.phaseTile[1] = 185;
            } else if (phase < 13.780940929354667) {
                self.phaseTile[0] = 242;
                self.phaseTile[1] = 185;
            } else if (phase < 14.76529385288) {
                self.phaseTile[0] = 314;
                self.phaseTile[1] = 185;
            } else if (phase < 15.749646776405333) {
                self.phaseTile[0] = 385;
                self.phaseTile[1] = 185;
            } else if (phase < 16.733999699930667) {
                self.phaseTile[0] = 458;
                self.phaseTile[1] = 185;
            } else if (phase < 17.718352623456) {
                self.phaseTile[0] = 529;
                self.phaseTile[1] = 185;
            } else if (phase < 18.702705546981335) {
                self.phaseTile[0] = 603;
                self.phaseTile[1] = 185;
            } else if (phase < 19.687058470506667) {
                self.phaseTile[0] = 676;
                self.phaseTile[1] = 185;
            } else if (phase < 20.671411394032) {
                self.phaseTile[0] = 24;
                self.phaseTile[1] = 316;
            } else if (phase < 21.655764317557335) {
                self.phaseTile[0] = 98;
                self.phaseTile[1] = 316;
            } else if (phase < 22.640117241082667) {
                self.phaseTile[0] = 170;
                self.phaseTile[1] = 316;
            } else if (phase < 23.624470164608) {
                self.phaseTile[0] = 242;
                self.phaseTile[1] = 316;
            } else if (phase < 24.608823088133335) {
                self.phaseTile[0] = 314;
                self.phaseTile[1] = 316;
            } else if (phase < 25.593176011658667) {
                self.phaseTile[0] = 386;
                self.phaseTile[1] = 316;
            } else if (phase < 26.577528935184) {
                self.phaseTile[0] = 459;
                self.phaseTile[1] = 316;
            } else if (phase < 27.561881858709334) {
                self.phaseTile[0] = 530;
                self.phaseTile[1] = 316;
            }
        }

        function draw(dc as Graphics.Dc) as Void {
            Gfx.drawTile(dc, 112 - cfg.bufferDx, 188 - cfg.bufferDy, "moon", self.phaseTile[0], self.phaseTile[1], 40, 40);
        }

        function calculate(now as Toybox.Time.Moment) {
            var time = (now.value() * 1000.0) / 86400000.0 + EPOCH;
            var phase = (time - 2451550.1) / SYNODIC_MONTH;
            var moonAge = phase - Math.floor(phase);
            if (moonAge < 0) {
                moonAge = moonAge + 1.0;
            }
            return moonAge * SYNODIC_MONTH;
        }

    }

}
