using Toybox.Math;
using Toybox.Time;
module srv {
    module moonPhase {
        const EPOCH = 2440587.5;
        const SYNODIC_MONTH = 29.53058770576;
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
