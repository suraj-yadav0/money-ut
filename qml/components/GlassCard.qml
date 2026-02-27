import QtQuick 2.7
import QtQuick.Layouts 1.3
import ".."

GlassContainer {
    id: card

    property alias contentItem: contentArea.data

    width: parent ? parent.width : 300
    implicitHeight: contentArea.implicitHeight + Theme.spacingLG * 2

    Item {
        id: contentArea
        anchors {
            fill: parent
            margins: Theme.spacingLG
        }
    }
}
