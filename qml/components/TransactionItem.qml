import QtQuick 2.7
import QtQuick.Layouts 1.3
import ".."

Rectangle {
    id: transactionItem

    property var transaction
    property string currencyCode: "INR"

    signal editRequested()
    signal deleteRequested()

    width: parent ? parent.width : 300
    height: 72
    color: "transparent"
    radius: Theme.radiusMD

    property real swipeX: 0
    property bool isSwiping: false

    // Background for swipe actions
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: swipeX > 0 ? Theme.income : swipeX < 0 ? Theme.expense : "transparent"
        opacity: Math.abs(swipeX) / 80

        Row {
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
                leftMargin: Theme.spacingLG
            }
            spacing: Theme.spacingSM
            visible: swipeX > 40

            Text {
                text: "✏️"
                font.pixelSize: 20
            }
            Text {
                text: "Edit"
                color: Theme.white
                font.pixelSize: Theme.fontSizeMD
                font.weight: Font.SemiBold
            }
        }

        Row {
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                rightMargin: Theme.spacingLG
            }
            spacing: Theme.spacingSM
            visible: swipeX < -40

            Text {
                text: "Delete"
                color: Theme.white
                font.pixelSize: Theme.fontSizeMD
                font.weight: Font.SemiBold
            }
            Text {
                text: "🗑️"
                font.pixelSize: 20
            }
        }
    }

    // Main content
    Rectangle {
        id: content
        width: parent.width
        height: parent.height
        radius: parent.radius
        color: mouseArea.containsMouse ? Theme.gray50 : Theme.white
        x: swipeX

        Behavior on x {
            enabled: !isSwiping
            NumberAnimation { duration: Theme.animationNormal; easing.type: Easing.OutCubic }
        }

        RowLayout {
            anchors {
                fill: parent
                margins: Theme.spacingMD
            }
            spacing: Theme.spacingMD

            // Category icon
            Rectangle {
                width: 44
                height: 44
                radius: width / 2
                color: transaction && transaction.type === "income" ?
                       Qt.rgba(Theme.income.r, Theme.income.g, Theme.income.b, 0.15) :
                       Qt.rgba(Theme.expense.r, Theme.expense.g, Theme.expense.b, 0.15)

                Text {
                    anchors.centerIn: parent
                    text: getCategoryEmoji(transaction ? transaction.category_icon : "")
                    font.pixelSize: 20
                }
            }

            // Details
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: transaction ? transaction.category_name : ""
                    font.pixelSize: Theme.fontSizeMD
                    font.weight: Font.SemiBold
                    color: Theme.gray900
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                RowLayout {
                    spacing: Theme.spacingXS
                    Layout.fillWidth: true

                    Text {
                        text: transaction ? Theme.formatTime(transaction.timestamp) : ""
                        font.pixelSize: Theme.fontSizeSM
                        color: Theme.gray500
                    }

                    Text {
                        text: "•"
                        font.pixelSize: Theme.fontSizeSM
                        color: Theme.gray400
                        visible: transaction && transaction.note
                    }

                    Text {
                        text: transaction ? (transaction.note || "") : ""
                        font.pixelSize: Theme.fontSizeSM
                        color: Theme.gray500
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        visible: transaction && transaction.note
                    }
                }
            }

            // Amount and receipt indicator
            ColumnLayout {
                spacing: 2
                Layout.alignment: Qt.AlignRight

                Text {
                    text: transaction ?
                          (transaction.type === "income" ? "+" : "-") +
                          Theme.formatCurrency(transaction.amount, currencyCode) : ""
                    font.pixelSize: Theme.fontSizeMD
                    font.weight: Font.SemiBold
                    color: transaction && transaction.type === "income" ? Theme.income : Theme.expense
                    Layout.alignment: Qt.AlignRight
                }

                Row {
                    spacing: Theme.spacingXS
                    Layout.alignment: Qt.AlignRight

                    Text {
                        text: "📎"
                        font.pixelSize: 12
                        visible: transaction && transaction.receipt_image_path
                    }

                    Text {
                        text: transaction ? (transaction.payment_mode || "") : ""
                        font.pixelSize: Theme.fontSizeXS
                        color: Theme.gray400
                    }
                }
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true

            property real startX: 0
            property real lastX: 0

            onPressed: {
                startX = mouse.x;
                lastX = mouse.x;
                isSwiping = true;
            }

            onPositionChanged: {
                if (pressed) {
                    var deltaX = mouse.x - lastX;
                    swipeX = Math.max(-80, Math.min(80, swipeX + deltaX));
                    lastX = mouse.x;
                }
            }

            onReleased: {
                isSwiping = false;
                if (swipeX > 60) {
                    editRequested();
                } else if (swipeX < -60) {
                    deleteRequested();
                }
                swipeX = 0;
            }

            onClicked: {
                if (Math.abs(swipeX) < 10) {
                    editRequested();
                }
            }
        }
    }

    function getCategoryEmoji(icon) {
        var emojiMap = {
            "restaurant": "🍽️",
            "directions_car": "🚗",
            "shopping_bag": "🛍️",
            "movie": "🎬",
            "receipt_long": "📄",
            "local_hospital": "🏥",
            "school": "🎓",
            "spa": "💆",
            "local_grocery_store": "🛒",
            "card_giftcard": "🎁",
            "savings": "💰",
            "show_chart": "📊",
            "family_restroom": "👨‍👩‍👧",
            "more_horiz": "⋯",
            "work": "💼",
            "laptop": "💻",
            "trending_up": "📈",
            "attach_money": "💵"
        };
        return emojiMap[icon] || "📝";
    }
}
