import QtQuick 2.7
import Lomiri.Components 1.3
import ".."

Item {
    id: pieChart

    property var data: []
    property int donutRadius: 35
    property bool showLegend: true

    implicitWidth: units.gu(25)
    implicitHeight: chartCanvas.height + (showLegend && data.length > 0 ? legendColumn.height + units.gu(1) : 0)

    Canvas {
        id: chartCanvas
        width: pieChart.width
        height: Math.min(pieChart.width - units.gu(2.5), units.gu(20))

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();

            if (pieChart.data.length === 0) return;

            var centerX = width / 2;
            var centerY = height / 2;
            var radius = Math.min(centerX, centerY) - units.dp(5);
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

    onDataChanged: chartCanvas.requestPaint()
    onWidthChanged: chartCanvas.requestPaint()
    Component.onCompleted: chartCanvas.requestPaint()

    Column {
        id: legendColumn
        y: chartCanvas.height + units.gu(1)
        width: pieChart.width
        visible: showLegend && pieChart.data.length > 0
        spacing: units.gu(0.5)

        Grid {
            columns: 2
            columnSpacing: units.gu(1.5)
            rowSpacing: units.gu(0.5)
            anchors.horizontalCenter: parent.horizontalCenter

            Repeater {
                model: pieChart.data

                Row {
                    spacing: units.gu(0.5)
                    width: units.gu(14)

                    Rectangle {
                        width: units.gu(1.2)
                        height: units.gu(1.2)
                        radius: width / 2
                        color: modelData.color || Theme.chartColors[index % Theme.chartColors.length]
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Label {
                        text: modelData.label + " (" + (modelData.percentage ? modelData.percentage.toFixed(0) : 0) + "%)"
                        fontSize: "x-small"
                        color: Theme.gray600
                        elide: Text.ElideRight
                        width: units.gu(11)
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }
}
