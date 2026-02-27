import QtQuick 2.7
import ".."

Item {
    id: progressBar

    property real value: 0  // 0.0 to 1.0
    property real maxValue: 1.0
    property color barColor: Theme.primary
    property color backgroundColor: Theme.gray200
    property int barHeight: 8
    property bool showMilestones: false
    property bool animated: true

    width: parent ? parent.width : 200
    height: barHeight

    // Background track
    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: backgroundColor
    }

    // Progress fill
    Rectangle {
        width: Math.min(parent.width * (value / maxValue), parent.width)
        height: parent.height
        radius: height / 2
        color: barColor

        Behavior on width {
            enabled: animated
            NumberAnimation { duration: Theme.animationNormal; easing.type: Easing.OutCubic }
        }
    }

    // Milestone markers (for goals: 25%, 50%, 75%)
    Row {
        anchors.fill: parent
        visible: showMilestones

        Repeater {
            model: [0.25, 0.5, 0.75]

            Item {
                width: progressBar.width * modelData
                height: parent.height

                Rectangle {
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    width: 16
                    height: 16
                    radius: 8
                    color: (progressBar.value / progressBar.maxValue) >= modelData ? Theme.income : Theme.gray300
                    border.width: 2
                    border.color: Theme.white

                    Text {
                        anchors.centerIn: parent
                        text: (progressBar.value / progressBar.maxValue) >= modelData ? "✓" : ""
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        color: Theme.white
                    }

                    Behavior on color {
                        enabled: animated
                        ColorAnimation { duration: Theme.animationNormal }
                    }
                }
            }
        }
    }
}
