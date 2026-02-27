import QtQuick 2.7
import QtQuick.Layouts 1.3
import ".."

GlassContainer {
    id: card

    default property alias contentChildren: contentColumn.data

    width: parent ? parent.width : 300
    implicitHeight: contentColumn.implicitHeight + Theme.spacingLG * 2

    ColumnLayout {
        id: contentColumn
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: Theme.spacingLG
        }
        spacing: Theme.spacingSM
    }
}
