import QtQuick 2.7
import ".."

Item {
    id: barChart

    property var data: []
    property string currencyCode: "INR"
    property int barWidth: 40
    property int barSpacing: 8

    width: Math.max(data.length * (barWidth + barSpacing) + 60, 200)
    height: 200

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
        y: 10
        width: 45
        height: parent.height - 50

        Repeater {
            model: 5

            Text {
                width: parent.width
                height: (barChart.height - 50) / 4
                text: Theme.formatCompactCurrency(maxValue * (1 - index / 4), currencyCode)
                font.pixelSize: Theme.fontSizeXS
                color: Theme.gray500
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignTop
            }
        }
    }

    // Chart area
    Item {
        id: chartArea
        x: 50
        y: 10
        width: parent.width - 60
        height: parent.height - 50

        // Grid lines
        Repeater {
            model: 5

            Rectangle {
                y: chartArea.height * (index / 4)
                width: chartArea.width
                height: 1
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
                        height: Math.max((modelData.value / maxValue) * parent.height, 4)
                        anchors.bottom: parent.bottom
                        radius: 4
                        color: modelData.color || Theme.chartColors[index % Theme.chartColors.length]

                        Behavior on height {
                            NumberAnimation { duration: Theme.animationNormal; easing.type: Easing.OutCubic }
                        }
                    }

                    // X-axis label
                    Text {
                        y: parent.height + Theme.spacingXS
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: modelData.label ? modelData.label.substring(0, 6) : ""
                        font.pixelSize: Theme.fontSizeXS
                        color: Theme.gray500
                        rotation: -45
                        transformOrigin: Item.TopLeft
                    }
                }
            }
        }
    }
}
