import QtQuick 2.7
import QtQuick.Layouts 1.3
import ".."

Item {
    id: emptyState

    property string emoji: "📝"
    property string title: "No Data"
    property string subtitle: ""
    property string actionText: ""
    property bool showAction: actionText !== ""

    signal actionClicked()

    width: parent ? parent.width : 300
    height: column.height

    ColumnLayout {
        id: column
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Theme.spacingMD
        width: parent.width * 0.8

        Text {
            text: emptyState.emoji
            font.pixelSize: 64
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: emptyState.title
            font.pixelSize: Theme.fontSizeXL
            font.weight: Font.SemiBold
            color: Theme.gray700
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            text: emptyState.subtitle
            font.pixelSize: Theme.fontSizeMD
            color: Theme.gray500
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            visible: subtitle !== ""
        }

        Rectangle {
            visible: showAction
            Layout.alignment: Qt.AlignHCenter
            width: actionLabel.implicitWidth + Theme.spacingXL * 2
            height: 44
            radius: Theme.radiusButton
            color: Theme.primary

            Text {
                id: actionLabel
                anchors.centerIn: parent
                text: emptyState.actionText
                font.pixelSize: Theme.fontSizeMD
                font.weight: Font.SemiBold
                color: Theme.white
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: emptyState.actionClicked()
            }
        }
    }
}
