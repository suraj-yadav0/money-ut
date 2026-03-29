import QtQuick 2.7
import Lomiri.Components 1.3
import ".."

Canvas {
    id: lineChart

    property var data: []
    property string currencyCode: "INR"
    property color lineColor: Theme.primary
    property color fillColor: lineColor
    property real smoothness: 0.3
    property bool showGradient: true
    property bool showDots: true

    width: Math.max(data.length * units.gu(6), units.gu(38))
    height: units.gu(25)

    property real maxValue: {
        var max = 0;
        for (var i = 0; i < data.length; i++) {
            if (data[i].value > max) max = data[i].value;
        }
        return max || 1;
    }

    property real minValue: 0
    property int chartPadding: units.gu(4)

    onDataChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    onPaint: {
        var ctx = getContext("2d");
        ctx.reset();

        if (data.length < 2) return;

        var chartWidth = width - chartPadding * 2;
        var chartHeight = height - chartPadding * 2;
        var range = maxValue - minValue || 1;

        var points = [];
        for (var i = 0; i < data.length; i++) {
            var x = chartPadding + (i / (data.length - 1)) * chartWidth;
            var y = chartPadding + chartHeight - ((data[i].value - minValue) / range) * chartHeight;
            points.push({ x: x, y: y });
        }

        // Gradient fill
        if (showGradient) {
            var gradient = ctx.createLinearGradient(0, chartPadding, 0, height - chartPadding);
            gradient.addColorStop(0, Qt.rgba(fillColor.r, fillColor.g, fillColor.b, 0.4));
            gradient.addColorStop(1, Qt.rgba(fillColor.r, fillColor.g, fillColor.b, 0.05));

            ctx.beginPath();
            ctx.moveTo(points[0].x, height - chartPadding);
            ctx.lineTo(points[0].x, points[0].y);

            for (var j = 1; j < points.length; j++) {
                var cpX1 = (points[j - 1].x + points[j].x) / 2;
                ctx.bezierCurveTo(cpX1, points[j - 1].y, cpX1, points[j].y, points[j].x, points[j].y);
            }

            ctx.lineTo(points[points.length - 1].x, height - chartPadding);
            ctx.closePath();
            ctx.fillStyle = gradient;
            ctx.fill();
        }

        // Line
        ctx.beginPath();
        ctx.moveTo(points[0].x, points[0].y);

        for (var k = 1; k < points.length; k++) {
            var cp1X = points[k - 1].x + (points[k].x - points[k - 1].x) * smoothness;
            var cp2X = points[k].x - (points[k].x - points[k - 1].x) * smoothness;
            ctx.bezierCurveTo(cp1X, points[k - 1].y, cp2X, points[k].y, points[k].x, points[k].y);
        }

        ctx.strokeStyle = lineColor;
        ctx.lineWidth = 2.5;
        ctx.stroke();

        // Dots
        if (showDots) {
            for (var m = 0; m < points.length; m++) {
                ctx.beginPath();
                ctx.arc(points[m].x, points[m].y, units.dp(4), 0, Math.PI * 2);
                ctx.fillStyle = lineColor;
                ctx.fill();

                ctx.beginPath();
                ctx.arc(points[m].x, points[m].y, units.dp(2), 0, Math.PI * 2);
                ctx.fillStyle = Theme.white;
                ctx.fill();
            }
        }

        // X-axis labels
        var step = Math.ceil(data.length / 7);
        ctx.fillStyle = Theme.gray500;
        ctx.font = units.dp(10) + "px sans-serif";
        ctx.textAlign = "center";
        for (var n = 0; n < data.length; n += step) {
            var lx = chartPadding + (n / (data.length - 1)) * chartWidth;
            var label = data[n].label || data[n].date || "";
            ctx.fillText(label, lx, height - units.dp(5));
        }
    }
}
