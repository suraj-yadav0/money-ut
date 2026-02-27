import QtQuick 2.7
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3
import ".."

ListItem {
    id: transactionItem

    property var transaction
    property string currencyCode: "INR"

    signal editRequested()
    signal deleteRequested()

    height: units.gu(8)
    divider.visible: true

    leadingActions: ListItemActions {
        actions: [
            Action {
                iconName: "edit"
                text: "Edit"
                onTriggered: editRequested()
            }
        ]
    }

    trailingActions: ListItemActions {
        actions: [
            Action {
                iconName: "delete"
                text: "Delete"
                onTriggered: deleteRequested()
            }
        ]
    }

    onClicked: editRequested()

    RowLayout {
        anchors {
            fill: parent
            leftMargin: units.gu(2)
            rightMargin: units.gu(2)
            topMargin: units.gu(0.5)
            bottomMargin: units.gu(0.5)
        }
        spacing: units.gu(1.5)

        // Category icon
        LomiriShape {
            Layout.preferredWidth: units.gu(5)
            Layout.preferredHeight: units.gu(5)
            aspect: LomiriShape.Flat
            radius: "medium"
            backgroundColor: transaction && transaction.type === "income" ?
                Qt.rgba(Theme.income.r, Theme.income.g, Theme.income.b, 0.15) :
                Qt.rgba(Theme.expense.r, Theme.expense.g, Theme.expense.b, 0.15)

            Icon {
                anchors.centerIn: parent
                width: units.gu(2.5)
                height: units.gu(2.5)
                name: getCategoryIcon(transaction ? transaction.category_icon : "")
                color: transaction && transaction.type === "income" ? Theme.income : Theme.expense
            }
        }

        // Details
        ColumnLayout {
            Layout.fillWidth: true
            spacing: units.dp(2)

            Label {
                text: transaction ? transaction.category_name : ""
                fontSize: "medium"
                font.weight: Font.DemiBold
                color: Theme.gray900
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            RowLayout {
                spacing: units.gu(0.5)
                Layout.fillWidth: true

                Label {
                    text: transaction ? Theme.formatTime(transaction.timestamp) : ""
                    fontSize: "x-small"
                    color: Theme.gray500
                }

                Label {
                    text: "·"
                    fontSize: "x-small"
                    color: Theme.gray400
                    visible: transaction && transaction.note
                }

                Label {
                    text: transaction ? (transaction.note || "") : ""
                    fontSize: "x-small"
                    color: Theme.gray500
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    visible: transaction && transaction.note
                }
            }
        }

        // Amount
        ColumnLayout {
            spacing: units.dp(2)
            Layout.alignment: Qt.AlignRight

            Label {
                text: transaction ?
                      (transaction.type === "income" ? "+" : "-") +
                      Theme.formatCurrency(transaction.amount, currencyCode) : ""
                fontSize: "medium"
                font.weight: Font.DemiBold
                color: transaction && transaction.type === "income" ? Theme.income : Theme.expense
                Layout.alignment: Qt.AlignRight
            }

            Label {
                text: transaction ? (transaction.payment_mode || "") : ""
                fontSize: "xx-small"
                color: Theme.gray400
                Layout.alignment: Qt.AlignRight
            }
        }
    }

    function getCategoryIcon(icon) {
        var iconMap = {
            "restaurant": "like",
            "directions_car": "stock_transport-car",
            "shopping_bag": "stock_store",
            "movie": "stock_music",
            "receipt_long": "stock_document",
            "local_hospital": "stock_health",
            "school": "stock_note",
            "spa": "like",
            "local_grocery_store": "stock_store",
            "card_giftcard": "stock_event",
            "savings": "save",
            "show_chart": "stock_website",
            "family_restroom": "contact-group",
            "more_horiz": "other-actions",
            "work": "stock_application",
            "laptop": "computer-symbolic",
            "trending_up": "stock_website",
            "attach_money": "save"
        };
        return iconMap[icon] || "stock_note";
    }
}
