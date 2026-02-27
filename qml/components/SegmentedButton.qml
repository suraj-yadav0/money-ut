import QtQuick 2.7
import QtQuick.Layouts 1.3
import ".."

Row {
    id: segmentedButton

    property var segments: []  // Array of { key, label }
    property string selectedKey: segments.length > 0 ? segments[0].key : ""
    property color activeColor: Theme.primary
    property color inactiveColor: Theme.white

    signal selectionChanged(string key)

    spacing: 0
    height: 40

    Repeater {
        model: segments

        Rectangle {
            width: segmentLabel.implicitWidth + Theme.spacingLG * 2
            height: parent.height
            color: segmentedButton.selectedKey === modelData.key ? activeColor : inactiveColor
            border.width: 1
            border.color: activeColor

            radius: index === 0 ? Theme.radiusSM : (index === segments.length - 1 ? Theme.radiusSM : 0)

            // Handle corner radius for first and last items
            Rectangle {
                visible: index === 0
                anchors {
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                }
                width: Theme.radiusSM
                color: parent.color
            }

            Rectangle {
                visible: index === segments.length - 1
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }
                width: Theme.radiusSM
                color: parent.color
            }

            Text {
                id: segmentLabel
                anchors.centerIn: parent
                text: modelData.label
                font.pixelSize: Theme.fontSizeSM
                font.weight: segmentedButton.selectedKey === modelData.key ? Font.DemiBold : Font.Normal
                color: segmentedButton.selectedKey === modelData.key ? Theme.white : activeColor
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    segmentedButton.selectedKey = modelData.key;
                    segmentedButton.selectionChanged(modelData.key);
                }
            }

            Behavior on color {
                ColorAnimation { duration: Theme.animationFast }
            }
        }
    }
}
