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

    function arraySumm(array, def) {
		var sum = 0;
		for (var i = 0; i < array.size(); i++) {
			if (array[i] == null || array[i].data == null) {
				array[i] = def;
            } else {
				array[i] = array[i].data;
			}
			sum += array[i];
		}
		return sum;
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
                var y = offsetY - value;
                items[4 * i] = [3 * x, offsetY];
                items[4 * i + 1] = [3 * x, offsetY - value];
                items[4 * i + 2] = [3 * x + 2, offsetY - value];
                items[4 * i + 3] = [3 * x + 2, offsetY];
            }
            for (var i = length; i < items.size() / 4; i++) {
                items[4 * i] = [offsetX, offsetY];
                items[4 * i + 1] = [offsetX, offsetY];
                items[4 * i + 2] = [offsetX, offsetY];
                items[4 * i + 3] = [offsetX, offsetY];
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
            var samples = [];

            var data = sample.next();
            while (data != null) {
                if (data.data == null) {
                    data = sample.next();
                    continue;
                }
                if (firstItem == null) {
                    firstItem = data.data.toFloat();
                }
                samples.add(data.data);
                data = sample.next();
            }
            if (firstItem == null) { return 0; }
            var middleIndex = (samples.size() / 2).toNumber();
            for (var i = 0; i < middleIndex; i++) {
                minItem = self.min(minItem, samples[i].toFloat());
                maxItem = self.max(maxItem, samples[i].toFloat());
            }

            items[0] = (firstItem - min) / diff;
            items[1] = (minItem - min) / diff;
            items[2] = (maxItem - min) / diff;

            return firstItem;
        }

        return 0;
    }

    function graphDataToArray(offsetX, offsetY, sample, items) {
        if (sample == null) { return 0; }
        var max = sample.getMax();
        var min = sample.getMin();
        var diff = max - min;
        diff = diff == 0 ? 1.0 : diff;
        var length = 13;
        var height = 10.0;
        var result = 0.0;
        if (sample != null) {
            // iterate over the samples and draw the graph
            var data = sample.next();
            var value = data == null || data.data == null ? min : data.data;
            result = value;
            value = arraySumm([
                data, sample.next(), sample.next(), sample.next(),
                sample.next(), sample.next(), sample.next(), sample.next(),
                sample.next(), sample.next(), sample.next(), sample.next(),
                sample.next(), sample.next()
            ], min) / 14.0;
            for (var i = 0; i < length; i++) {
                value = (value - min) * height / diff;
                var x = offsetX - i;
                var y = offsetY - value;
                items[4 * i] = [3 * x, offsetY];
                items[4 * i + 1] = [3 * x, offsetY - value];
                items[4 * i + 2] = [3 * x + 2, offsetY - value];
                items[4 * i + 3] = [3 * x + 2, offsetY];
                value = arraySumm([
                    sample.next(), sample.next(), sample.next(), sample.next(),
                    sample.next(), sample.next(), sample.next(), sample.next(),
                    sample.next(), sample.next(), sample.next(), sample.next(),
                    sample.next(), sample.next()
                ], min) / 14.0;
            }
        }
        return result;
    }

}
