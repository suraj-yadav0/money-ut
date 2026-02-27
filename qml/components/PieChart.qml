import QtQuick 2.7
import ".."

Canvas {
    id: pieChart

    property var data: []  // Array of { label, value, color }
    property int donutRadius: 35
    property bool showLegend: true

    width: 200
    height: 200 + (showLegend ? legendHeight : 0)

    property int legendHeight: Math.ceil(data.length / 2) * 28 + Theme.spacingMD

    onDataChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    onPaint: {
        var ctx = getContext("2d");
        ctx.reset();

        if (data.length === 0) return;

        var centerX = width / 2;
        var centerY = (height - (showLegend ? legendHeight : 0)) / 2;
        var radius = Math.min(centerX, centerY) - 10;
        var innerRadius = radius * (donutRadius / 100);

        var total = 0;
        for (var i = 0; i < data.length; i++) {
            total += data[i].value;
        }

        if (total === 0) return;

        var startAngle = -Math.PI / 2;

        for (var j = 0; j < data.length; j++) {
            var sliceAngle = (data[j].value / total) * 2 * Math.PI;
            var endAngle = startAngle + sliceAngle;

            ctx.beginPath();
            ctx.fillStyle = data[j].color || Theme.chartColors[j % Theme.chartColors.length];

            // Draw arc
            ctx.arc(centerX, centerY, radius, startAngle, endAngle);
            ctx.arc(centerX, centerY, innerRadius, endAngle, startAngle, true);
            ctx.closePath();
            ctx.fill();

            startAngle = endAngle;
        }
    }

    // Legend
    Column {
        anchors {
            top: parent.top
            topMargin: height - legendHeight
            horizontalCenter: parent.horizontalCenter
        }
        visible: showLegend
        spacing: Theme.spacingXS

        Grid {
            columns: 2
            columnSpacing: Theme.spacingLG
            rowSpacing: Theme.spacingXS

            Repeater {
                model: pieChart.data

                Row {
                    spacing: Theme.spacingXS
                    width: 120

                    Rectangle {
                        width: 12
                        height: 12
                        radius: 6
                        color: modelData.color || Theme.chartColors[index % Theme.chartColors.length]
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: modelData.label + " (" + modelData.percentage.toFixed(0) + "%)"
                        font.pixelSize: Theme.fontSizeXS
                        color: Theme.gray600
                        elide: Text.ElideRight
                        width: 100
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }
}
