import QtQuick 2.7
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3
import ".."

Item {
    id: balanceCard

    property real totalIncome: 0
    property real totalExpenses: 0
    property real balance: totalIncome - totalExpenses
    property string currencyCode: "INR"

    width: parent ? parent.width : units.gu(40)
    height: units.gu(22)
    clip: true

    // Background shape
    LomiriShape {
        anchors.fill: parent
        aspect: LomiriShape.DropShadow
        backgroundMode: LomiriShape.VerticalGradient
        backgroundColor: Theme.primary
        secondaryBackgroundColor: Theme.primaryDark
        radius: "large"
    }

    // Decorative circles (clipped by parent Item)
    Rectangle {
        width: units.gu(14)
        height: units.gu(14)
        radius: width / 2
        color: Qt.rgba(1, 1, 1, 0.08)
        x: parent.width - units.gu(9)
        y: -units.gu(5)
    }

    Rectangle {
        width: units.gu(9)
        height: units.gu(9)
        radius: width / 2
        color: Qt.rgba(1, 1, 1, 0.06)
        x: parent.width - units.gu(14)
        y: units.gu(3)
    }

    // Content
    ColumnLayout {
        anchors {
            fill: parent
            margins: units.gu(2)
        }
        spacing: units.gu(0.5)

        // Card header with chip
        RowLayout {
            Layout.fillWidth: true
            spacing: units.gu(1)

            // Card chip
            Rectangle {
                width: units.gu(5)
                height: units.gu(3.5)
                radius: units.dp(4)
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#D4AF37" }
                    GradientStop { position: 1.0; color: "#AA8C2C" }
                }

                Column {
                    anchors.centerIn: parent
                    spacing: units.dp(2)
                    Repeater {
                        model: 3
                        Rectangle {
                            width: units.gu(3.5)
                            height: units.dp(2)
                            color: Qt.rgba(0, 0, 0, 0.2)
                        }
                    }
                }
            }

            Item { Layout.fillWidth: true }

            // Contactless icon
            Icon {
                width: units.gu(2.5)
                height: units.gu(2.5)
                name: "transfer-progress"
                color: Qt.rgba(1, 1, 1, 0.5)
            }
        }

        Item { Layout.fillHeight: true }

        // Balance
        Label {
            text: Theme.formatFullCurrency(balanceCard.balance, currencyCode)
            font.pixelSize: units.gu(4)
            font.weight: Font.Bold
            color: Theme.white
        }

        // Card number dots
        Label {
            text: "****  ****  ****  1965"
            fontSize: "small"
            color: Qt.rgba(1, 1, 1, 0.5)
            font.letterSpacing: 2
        }

        Item { Layout.fillHeight: true }

        // Income and Expense row
        RowLayout {
            Layout.fillWidth: true
            spacing: units.gu(2.5)

            ColumnLayout {
                spacing: units.dp(2)

                Label {
                    text: "INCOME"
                    fontSize: "x-small"
                    font.weight: Font.Medium
                    color: Qt.rgba(1, 1, 1, 0.6)
                }

                Label {
                    text: Theme.formatCurrency(totalIncome, currencyCode)
                    fontSize: "medium"
                    font.weight: Font.DemiBold
                    color: "#81C784"
                }
            }

            Rectangle {
                width: units.dp(1)
                height: units.gu(3.5)
                color: Qt.rgba(1, 1, 1, 0.2)
            }

            ColumnLayout {
                spacing: units.dp(2)

                Label {
                    text: "EXPENSES"
                    fontSize: "x-small"
                    font.weight: Font.Medium
                    color: Qt.rgba(1, 1, 1, 0.6)
                }

                Label {
                    text: Theme.formatCurrency(totalExpenses, currencyCode)
                    fontSize: "medium"
                    font.weight: Font.DemiBold
                    color: "#EF9A9A"
                }
            }

            Item { Layout.fillWidth: true }
        }
    }
}
