using Toybox.Graphics;
import Toybox.Lang;
using Toybox.ActivityMonitor;
using Toybox.Math;

module srv {
    function min(a, b) {
        return a < b ? a : b;
    }

    function max(a, b) {
        return a > b ? a : b;
    }

    function stepsHistoryToArray(offsetX, offsetY, items) {
        var history = ActivityMonitor.getHistory();
        var max = 10000;
        var length = history == null ? 0 : self.min(items.size() / 4, history.size());
        var height = 10.0;

        if (history != null) {
            for (var i = 0; i < length; i++) {
                var value = self.min(history[i].steps, max);
                value = value * height / max;
                var x = offsetX - i;
                items[4 * i][0] = 3 * x;
                items[4 * i][1] = offsetY;
                items[4 * i + 1][0] = 3 * x;
                items[4 * i + 1][1] = offsetY - value;
                items[4 * i + 2][0] = 3 * x + 2;
                items[4 * i + 2][1] = offsetY - value;
                items[4 * i + 3][0] = 3 * x + 2;
                items[4 * i + 3][1] = offsetY;
            }
            for (var i = length; i < items.size() / 4; i++) {
                items[4 * i][0] = offsetX;
                items[4 * i][1] = offsetY;
                items[4 * i + 1][0] = offsetX;
                items[4 * i + 1][1] = offsetY;
                items[4 * i + 2][0] = offsetX;
                items[4 * i + 2][1] = offsetY;
                items[4 * i + 3][0] = offsetX;
                items[4 * i + 3][1] = offsetY;
            }
        }
    }

    function graphDataToFlat(sample, items as Array<Lang.Float>) {
        if (sample != null) {
            var max = sample.getMax().toFloat();
            var min = sample.getMin().toFloat();
            var diff = max - min;
            diff = diff == 0 ? 1.0 : diff;
            var firstItem = null;
            var minItem = sample.getMax().toFloat();
            var maxItem = sample.getMin().toFloat();
            var count = 0;
            var data = sample.next();
            // Fold the recent range directly from the iterator, as Class L
            // does, without retaining SensorSample values in a work array.
            while (data != null && count < 60) {
                if (data.data != null) {
                    var value = data.data.toFloat();
                    if (firstItem == null) {
                        firstItem = value;
                    }
                    minItem = self.min(minItem, value);
                    maxItem = self.max(maxItem, value);
                    count++;
                }
                data = sample.next();
            }
            if (firstItem == null) { return 0; }

            items[0] = (firstItem - min) / diff;
            items[1] = (minItem - min) / diff;
            items[2] = (maxItem - min) / diff;

            return firstItem;
        }

        return 0;
    }

}
