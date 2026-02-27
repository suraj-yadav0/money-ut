import QtQuick 2.7
import Lomiri.Components 1.3
import ".."

AbstractButton {
    id: chip

    property string text: ""
    property string icon: ""
    property bool selected: false
    property color selectedColor: Theme.primary
    property color defaultColor: Theme.white

    width: content.width + units.gu(2.5)
    height: units.gu(4)

    LomiriShape {
        anchors.fill: parent
        aspect: LomiriShape.Flat
        backgroundColor: selected ? selectedColor : defaultColor
        radius: "large"
        relativeRadius: 0.5

        Row {
            id: content
            anchors.centerIn: parent
            spacing: units.gu(0.5)

            Label {
                text: chip.icon
                fontSize: "small"
                visible: chip.icon !== ""
                anchors.verticalCenter: parent.verticalCenter
            }

            Label {
                text: chip.text
                fontSize: "small"
                font.weight: selected ? Font.DemiBold : Font.Normal
                color: selected ? Theme.white : Theme.gray700
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
