import QtQuick 2.7
import QtGraphicalEffects 1.0
import ".."

Rectangle {
    id: container

    property real glassOpacity: 0.65
    property int blurRadius: 20
    property bool showBorder: true
    property color borderColor: Qt.rgba(1, 1, 1, 0.2)
    property int borderWidth: 1
    property color gradientStart: Qt.rgba(1, 1, 1, glassOpacity)
    property color gradientEnd: Qt.rgba(1, 1, 1, glassOpacity * 0.8)
    property bool enableShadow: true

    color: "transparent"
    radius: Theme.radiusCard

    Rectangle {
        id: background
        anchors.fill: parent
        radius: parent.radius

        gradient: Gradient {
            GradientStop { position: 0.0; color: container.gradientStart }
            GradientStop { position: 1.0; color: container.gradientEnd }
        }

        border.width: container.showBorder ? container.borderWidth : 0
        border.color: container.borderColor
    }

    layer.enabled: container.enableShadow
    layer.effect: DropShadow {
        transparentBorder: true
        horizontalOffset: 0
        verticalOffset: 4
        radius: 16
        samples: 33
        color: Qt.rgba(0, 0, 0, 0.1)
    }
}
