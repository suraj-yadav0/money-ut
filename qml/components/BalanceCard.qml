import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import ".."

GlassContainer {
    id: balanceCard

    property real totalIncome: 0
    property real totalExpenses: 0
    property real balance: totalIncome - totalExpenses
    property string currencyCode: "INR"

    width: parent.width
    height: 180
    glassOpacity: 0.75

    // Credit card style gradient overlay
    Rectangle {
        id: gradientMask
        anchors.fill: parent
        radius: parent.radius
        color: "transparent"
        clip: true

        LinearGradient {
            anchors.fill: parent
            start: Qt.point(0, 0)
            end: Qt.point(parent.width, 0)
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1) }
                GradientStop { position: 1.0; color: Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.1) }
            }
        }
    }

    // Decorative circles
    Rectangle {
        width: 120
        height: 120
        radius: 60
        color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1)
        x: parent.width - 80
        y: -40
    }

    Rectangle {
        width: 80
        height: 80
        radius: 40
        color: Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.1)
        x: parent.width - 120
        y: 20
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: Theme.spacingLG
        }
        spacing: Theme.spacingSM

        // Card header with chip
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingSM

            // Chip icon
            Rectangle {
                width: 40
                height: 30
                radius: 4
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#D4AF37" }
                    GradientStop { position: 1.0; color: "#AA8C2C" }
                }

                // Chip lines
                Column {
                    anchors.centerIn: parent
                    spacing: 2
                    Repeater {
                        model: 3
                        Rectangle {
                            width: 30
                            height: 2
                            color: Qt.rgba(0, 0, 0, 0.2)
                        }
                    }
                }
            }

            Item { Layout.fillWidth: true }

            // Contactless icon
            Text {
                text: "◢"
                color: Theme.gray400
                font.pixelSize: 16
                rotation: 45
            }
        }

        Item { Layout.fillHeight: true }

        // Balance
        Text {
            text: Theme.formatFullCurrency(balanceCard.balance, currencyCode)
            font.pixelSize: Theme.fontSize4XL
            font.weight: Font.Bold
            color: balanceCard.balance >= 0 ? Theme.gray900 : Theme.expense
        }

        // Card number style text
        Text {
            text: "****  ****  ****  1965"
            font.pixelSize: Theme.fontSizeSM
            color: Theme.gray500
            font.letterSpacing: 2
        }

        Item { Layout.fillHeight: true }

        // Income and Expense row
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingXL

            // Income
            ColumnLayout {
                spacing: 2

                Text {
                    text: "INCOME"
                    font.pixelSize: Theme.fontSizeXS
                    font.weight: Font.Medium
                    color: Theme.gray500
                }

                Text {
                    text: Theme.formatCurrency(totalIncome, currencyCode)
                    font.pixelSize: Theme.fontSizeLG
                    font.weight: Font.DemiBold
                    color: Theme.income
                }
            }

            Rectangle {
                width: 1
                height: 30
                color: Theme.gray300
            }

            // Expenses
            ColumnLayout {
                spacing: 2

                Text {
                    text: "EXPENSES"
                    font.pixelSize: Theme.fontSizeXS
                    font.weight: Font.Medium
                    color: Theme.gray500
                }

                Text {
                    text: Theme.formatCurrency(totalExpenses, currencyCode)
                    font.pixelSize: Theme.fontSizeLG
                    font.weight: Font.DemiBold
                    color: Theme.expense
                }
            }

            Item { Layout.fillWidth: true }
        }
    }
}
