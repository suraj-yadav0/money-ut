import QtQuick 2.7
import QtGraphicalEffects 1.0
import ".."

Canvas {
    id: lineChart

    property var data: []  // Array of { date, value }
    property string currencyCode: "INR"
    property color lineColor: Theme.primary
    property color fillColor: lineColor
    property real smoothness: 0.3
    property bool showGradient: true
    property bool showDots: true
    property bool showTooltip: true

    width: Math.max(data.length * 50, 300)
    height: 200

    property real maxValue: {
        var max = 0;
        for (var i = 0; i < data.length; i++) {
            if (data[i].value > max) max = data[i].value;
        }
        return max || 1;
    }

    property real minValue: 0

    property int chartPadding: 30

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

        // Calculate points
        var points = [];
        for (var i = 0; i < data.length; i++) {
            var x = chartPadding + (i / (data.length - 1)) * chartWidth;
            var y = chartPadding + chartHeight - ((data[i].value - minValue) / range) * chartHeight;
            points.push({ x: x, y: y });
        }

        // Draw gradient fill
        if (showGradient) {
            var gradient = ctx.createLinearGradient(0, chartPadding, 0, height - chartPadding);
            gradient.addColorStop(0, Qt.rgba(fillColor.r, fillColor.g, fillColor.b, 0.4));
            gradient.addColorStop(1, Qt.rgba(fillColor.r, fillColor.g, fillColor.b, 0.05));

            ctx.beginPath();
            ctx.moveTo(points[0].x, height - chartPadding);
            ctx.lineTo(points[0].x, points[0].y);

            for (var j = 1; j < points.length; j++) {
                var prev = points[j - 1];
                var curr = points[j];
                var cpX = (prev.x + curr.x) / 2;

                ctx.bezierCurveTo(cpX, prev.y, cpX, curr.y, curr.x, curr.y);
            }

            ctx.lineTo(points[points.length - 1].x, height - chartPadding);
            ctx.closePath();
            ctx.fillStyle = gradient;
            ctx.fill();
        }

        // Draw line
        ctx.beginPath();
        ctx.moveTo(points[0].x, points[0].y);

        for (var k = 1; k < points.length; k++) {
            var p0 = points[k - 1];
            var p1 = points[k];
            var cp1X = p0.x + (p1.x - p0.x) * smoothness;
            var cp2X = p1.x - (p1.x - p0.x) * smoothness;

            ctx.bezierCurveTo(cp1X, p0.y, cp2X, p1.y, p1.x, p1.y);
        }

        ctx.strokeStyle = lineColor;
        ctx.lineWidth = 2.5;
        ctx.stroke();

        // Draw dots
        if (showDots) {
            for (var m = 0; m < points.length; m++) {
                ctx.beginPath();
                ctx.arc(points[m].x, points[m].y, 4, 0, Math.PI * 2);
                ctx.fillStyle = lineColor;
                ctx.fill();

                ctx.beginPath();
                ctx.arc(points[m].x, points[m].y, 2, 0, Math.PI * 2);
                ctx.fillStyle = Theme.white;
                ctx.fill();
            }
        }
    }

    // X-axis labels
    Row {
        anchors {
            bottom: lineChart.bottom
            left: lineChart.left
            leftMargin: chartPadding
            right: lineChart.right
            rightMargin: chartPadding
        }
        height: chartPadding - 5

        Repeater {
            model: {
                // Show max 7 labels
                var step = Math.ceil(lineChart.data.length / 7);
                var labels = [];
                for (var i = 0; i < lineChart.data.length; i += step) {
                    labels.push({ index: i, label: lineChart.data[i].label || lineChart.data[i].date });
                }
                return labels;
            }

            Text {
                x: (modelData.index / (lineChart.data.length - 1)) * (lineChart.width - chartPadding * 2) - width / 2
                text: modelData.label
                font.pixelSize: Theme.fontSizeXS
                color: Theme.gray500
            }
        }
    }

    // Interactive tooltip
    MouseArea {
        anchors.fill: parent
        hoverEnabled: showTooltip

        property int hoveredIndex: -1

        onPositionChanged: {
            if (!showTooltip || data.length === 0) return;

            var chartWidth = width - chartPadding * 2;
            var relX = mouse.x - chartPadding;
            var index = Math.round((relX / chartWidth) * (data.length - 1));
            index = Math.max(0, Math.min(data.length - 1, index));

            if (index !== hoveredIndex) {
                hoveredIndex = index;
                tooltipItem.visible = true;
                tooltipItem.x = chartPadding + (index / (data.length - 1)) * chartWidth - tooltipItem.width / 2;
                tooltipItem.y = 10;
                tooltipLabel.text = data[index].label + ": " + Theme.formatCurrency(data[index].value, currencyCode);
            }
        }

        onExited: {
            hoveredIndex = -1;
            tooltipItem.visible = false;
        }
    }

    Rectangle {
        id: tooltipItem
        visible: false
        width: tooltipLabel.width + Theme.spacingSM * 2
        height: tooltipLabel.height + Theme.spacingXS * 2
        color: Theme.gray900
        radius: 4

        Text {
            id: tooltipLabel
            anchors.centerIn: parent
            font.pixelSize: Theme.fontSizeXS
            color: Theme.white
        }
    }
}
