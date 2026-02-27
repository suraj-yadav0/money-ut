import QtQuick 2.7
import ".."

Rectangle {
    id: chip

    property string text: ""
    property string icon: ""
    property bool selected: false
    property color selectedColor: Theme.primary
    property color defaultColor: Theme.white

    signal clicked()

    width: content.width + Theme.spacingLG * 2
    height: 36
    radius: height / 2

    color: selected ? selectedColor :
           mouseArea.containsMouse ? Qt.rgba(selectedColor.r, selectedColor.g, selectedColor.b, 0.1) :
           defaultColor

    border.width: selected ? 0 : 1
    border.color: Theme.gray300

    Row {
        id: content
        anchors.centerIn: parent
        spacing: Theme.spacingXS

        Text {
            text: chip.icon
            font.pixelSize: 14
            visible: chip.icon !== ""
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: chip.text
            font.pixelSize: Theme.fontSizeSM
            font.weight: selected ? Font.SemiBold : Font.Normal
            color: selected ? Theme.white : Theme.gray700
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: chip.clicked()
    }

    Behavior on color {
        ColorAnimation { duration: Theme.animationFast }
    }
}
