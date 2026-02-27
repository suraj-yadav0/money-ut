import QtQuick 2.7
import Lomiri.Components 1.3
import ".."

LomiriShape {
    id: container

    property real glassOpacity: 0.65

    aspect: LomiriShape.DropShadow
    backgroundMode: LomiriShape.VerticalGradient
    backgroundColor: Qt.rgba(1, 1, 1, glassOpacity)
    secondaryBackgroundColor: Qt.rgba(1, 1, 1, glassOpacity * 0.8)
    radius: "large"
    relativeRadius: 0.4
}
