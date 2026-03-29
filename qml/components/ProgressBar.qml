import QtQuick 2.7
import Lomiri.Components 1.3
import ".."

Item {
    id: progressBar

    property real value: 0
    property real maxValue: 1.0
    property color barColor: Theme.primary
    property color backgroundColor: Theme.gray200
    property int barHeight: units.gu(1)
    property bool showMilestones: false
    property bool animated: true

    width: parent ? parent.width : units.gu(20)
    height: barHeight

    // Background track
    LomiriShape {
        anchors.fill: parent
        aspect: LomiriShape.Flat
        backgroundColor: progressBar.backgroundColor
        radius: "large"
        relativeRadius: 0.5
    }

    // Progress fill
    LomiriShape {
        width: Math.min(parent.width * (value / maxValue), parent.width)
        height: parent.height
        aspect: LomiriShape.Flat
        backgroundColor: barColor
        radius: "large"
        relativeRadius: 0.5

        Behavior on width {
            enabled: animated
            LomiriNumberAnimation {}
        }
    }

    // Milestone markers
    Row {
        anchors.fill: parent
        visible: showMilestones

        Repeater {
            model: [0.25, 0.5, 0.75]

            Item {
                width: progressBar.width * modelData
                height: parent.height

                LomiriShape {
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    width: units.gu(2)
                    height: units.gu(2)
                    aspect: LomiriShape.Flat
                    backgroundColor: (progressBar.value / progressBar.maxValue) >= modelData ?
                        Theme.income : Theme.gray300
                    radius: "large"
                    relativeRadius: 0.5

                    Label {
                        anchors.centerIn: parent
                        text: (progressBar.value / progressBar.maxValue) >= modelData ? "✓" : ""
                        fontSize: "xx-small"
                        font.weight: Font.Bold
                        color: Theme.white
                    }
                }
            }
        }
    }
}
