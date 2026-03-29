import QtQuick 2.7
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3
import ".."

LomiriShape {
    id: card

    default property alias contentChildren: contentColumn.data

    aspect: LomiriShape.DropShadow
    backgroundColor: Qt.rgba(1, 1, 1, 0.88)
    radius: "large"
    relativeRadius: 0.4

    implicitHeight: contentColumn.implicitHeight + units.gu(3)

    ColumnLayout {
        id: contentColumn
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: units.gu(2)
        }
        spacing: units.gu(1)
    }
}
