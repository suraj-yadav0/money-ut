import QtQuick 2.7
import ".."

Item {
    id: pieChart

    property var data: []  // Array of { label, value, color }
    property int donutRadius: 35
    property bool showLegend: true

    implicitWidth: 200
    implicitHeight: chartCanvas.height + (showLegend ? legendColumn.height + Theme.spacingSM : 0)

    Canvas {
        id: chartCanvas
        anchors.horizontalCenter: pieChart.horizontalCenter
        width: Math.min(pieChart.width - 20, 160)
        height: width

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();

            if (pieChart.data.length === 0) return;

            var centerX = width / 2;
            var centerY = height / 2;
            var radius = Math.min(centerX, centerY) - 5;
            var innerRadius = radius * (pieChart.donutRadius / 100);

            var total = 0;
            for (var i = 0; i < pieChart.data.length; i++) {
                total += pieChart.data[i].value;
            }

            if (total === 0) return;

            var startAngle = -Math.PI / 2;

            for (var j = 0; j < pieChart.data.length; j++) {
                var sliceAngle = (pieChart.data[j].value / total) * 2 * Math.PI;
                var endAngle = startAngle + sliceAngle;

                ctx.beginPath();
                ctx.fillStyle = pieChart.data[j].color || Theme.chartColors[j % Theme.chartColors.length];

                ctx.arc(centerX, centerY, radius, startAngle, endAngle);
                ctx.arc(centerX, centerY, innerRadius, endAngle, startAngle, true);
                ctx.closePath();
                ctx.fill();

                startAngle = endAngle;
            }
        }
    }

    Connections {
        target: pieChart
        onDataChanged: chartCanvas.requestPaint()
        onWidthChanged: chartCanvas.requestPaint()
    }

    onWidthChanged: chartCanvas.requestPaint()
    Component.onCompleted: chartCanvas.requestPaint()

    // Legend
    Column {
        id: legendColumn
        anchors {
            top: chartCanvas.bottom
            topMargin: Theme.spacingSM
            horizontalCenter: pieChart.horizontalCenter
        }
        visible: showLegend && pieChart.data.length > 0
        spacing: Theme.spacingXS

        Grid {
            columns: 2
            columnSpacing: Theme.spacingMD
            rowSpacing: Theme.spacingXS

            Repeater {
                model: pieChart.data

                Row {
                    spacing: Theme.spacingXS
                    width: 110

                    Rectangle {
                        width: 10
                        height: 10
                        radius: 5
                        color: modelData.color || Theme.chartColors[index % Theme.chartColors.length]
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: modelData.label + " (" + (modelData.percentage ? modelData.percentage.toFixed(0) : 0) + "%)"
                        font.pixelSize: Theme.fontSizeXS
                        color: Theme.gray600
                        elide: Text.ElideRight
                        width: 90
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }
}
