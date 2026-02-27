import QtQuick 2.7
import Lomiri.Components 1.3
import ".."

Item {
    id: barChart

    property var data: []
    property string currencyCode: "INR"
    property int barWidth: units.gu(5)
    property int barSpacing: units.gu(1)

    width: Math.max(data.length * (barWidth + barSpacing) + units.gu(8), units.gu(25))
    height: units.gu(25)

    property real maxValue: {
        var max = 0;
        for (var i = 0; i < data.length; i++) {
            if (data[i].value > max) max = data[i].value;
        }
        return max || 1;
    }

    // Y-axis labels
    Column {
        id: yAxis
        x: 0
        y: units.gu(1)
        width: units.gu(5.5)
        height: barChart.height - units.gu(6)

        Repeater {
            model: 5

            Label {
                width: parent.width
                height: (barChart.height - units.gu(6)) / 4
                text: Theme.formatCompactCurrency(maxValue * (1 - index / 4), currencyCode)
                fontSize: "x-small"
                color: Theme.gray500
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignTop
            }
        }
    }

    // Chart area
    Item {
        id: chartArea
        x: units.gu(6)
        y: units.gu(1)
        width: barChart.width - units.gu(8)
        height: barChart.height - units.gu(6)

        // Grid lines
        Repeater {
            model: 5

            Rectangle {
                y: chartArea.height * (index / 4)
                width: chartArea.width
                height: units.dp(1)
                color: Theme.gray200
            }
        }

        // Bars
        Row {
            anchors.bottom: parent.bottom
            height: parent.height
            spacing: barSpacing

            Repeater {
                model: barChart.data

                Item {
                    width: barWidth
                    height: parent.height

                    Rectangle {
                        width: barWidth
                        height: Math.max((modelData.value / maxValue) * parent.height, units.dp(4))
                        anchors.bottom: parent.bottom
                        radius: units.dp(4)
                        color: modelData.color || Theme.chartColors[index % Theme.chartColors.length]

                        Behavior on height {
                            NumberAnimation { duration: Theme.animationNormal; easing.type: Easing.OutCubic }
                        }
                    }

                    // X-axis label
                    Label {
                        y: parent.height + units.gu(0.5)
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: modelData.label ? modelData.label.substring(0, 6) : ""
                        fontSize: "x-small"
                        color: Theme.gray500
                        rotation: -45
                        transformOrigin: Item.TopLeft
                    }
                }
            }
        }
    }
}
