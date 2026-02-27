import QtQuick 2.7
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3
import ".."

Item {
    id: emptyState

    property string iconName: "stock_note"
    property string emoji: ""
    property string title: "No Data"
    property string subtitle: ""
    property string actionText: ""
    property bool showAction: actionText !== ""

    signal actionClicked()

    width: parent ? parent.width : units.gu(30)
    height: column.height

    ColumnLayout {
        id: column
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: units.gu(1.5)
        width: parent.width * 0.8

        Icon {
            width: units.gu(6)
            height: units.gu(6)
            name: emptyState.iconName
            color: Theme.gray400
            Layout.alignment: Qt.AlignHCenter
        }

        Label {
            text: emptyState.title
            fontSize: "large"
            font.weight: Font.DemiBold
            color: Theme.gray700
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
        }

        Label {
            text: emptyState.subtitle
            fontSize: "small"
            color: Theme.gray500
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            visible: subtitle !== ""
        }

        Button {
            visible: showAction
            Layout.alignment: Qt.AlignHCenter
            text: emptyState.actionText
            color: Theme.primary
            onClicked: actionClicked()
        }
    }
}
