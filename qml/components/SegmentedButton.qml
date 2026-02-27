import QtQuick 2.7
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3
import ".."

Row {
    id: segmentedButton

    property var segments: []
    property string selectedKey: segments.length > 0 ? segments[0].key : ""
    property color activeColor: Theme.primary
    property color inactiveColor: Theme.white

    signal selectionChanged(string key)

    spacing: 0
    height: units.gu(4.5)

    Repeater {
        model: segments

        AbstractButton {
            id: segBtn
            width: segLabel.implicitWidth + units.gu(3)
            height: parent.height

            LomiriShape {
                anchors.fill: parent
                aspect: LomiriShape.Flat
                backgroundColor: segmentedButton.selectedKey === modelData.key ? activeColor : inactiveColor
                radius: "medium"

                Label {
                    id: segLabel
                    anchors.centerIn: parent
                    text: modelData.label
                    fontSize: "small"
                    font.weight: segmentedButton.selectedKey === modelData.key ? Font.DemiBold : Font.Normal
                    color: segmentedButton.selectedKey === modelData.key ? Theme.white : activeColor
                }
            }

            onClicked: {
                segmentedButton.selectedKey = modelData.key;
                segmentedButton.selectionChanged(modelData.key);
            }
        }
    }
}
