import QtQuick 2.7
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3
import ".."
import "../components"

Page {
    id: dayTransactionsPage

    property date selectedDate: new Date()
    property string currencyCode: "INR"
    property var transactions: []
    property var daySummary: ({ income: 0, expenses: 0, net: 0 })

    signal editTransaction(var transaction)

    header: PageHeader {
        id: header
        title: Qt.formatDate(selectedDate, "dddd, MMMM d")

        leadingActionBar.actions: [
            Action {
                iconName: "back"
                text: "Back"
                onTriggered: pageStack.pop()
            }
        ]
    }

    // Background
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.lightBg1 }
            GradientStop { position: 0.5; color: Theme.lightBg2 }
            GradientStop { position: 1.0; color: Theme.lightBg3 }
        }
    }

    Flickable {
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        contentHeight: contentColumn.height + Theme.spacing2XL
        clip: true

        ColumnLayout {
            id: contentColumn
            width: parent.width - Theme.spacingLG * 2
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.spacingLG

            Item { Layout.preferredHeight: Theme.spacingSM }

            // Day summary card
            GlassCard {
                Layout.fillWidth: true

                contentItem: RowLayout {
                    spacing: Theme.spacingMD

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: "Income"
                            font.pixelSize: Theme.fontSizeXS
                            color: Theme.gray500
                        }

                        Text {
                            text: Theme.formatCurrency(daySummary.income, currencyCode)
                            font.pixelSize: Theme.fontSizeMD
                            font.weight: Font.SemiBold
                            color: Theme.income
                        }
                    }

                    Rectangle { width: 1; height: 35; color: Theme.gray200 }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: "Expenses"
                            font.pixelSize: Theme.fontSizeXS
                            color: Theme.gray500
                        }

                        Text {
                            text: Theme.formatCurrency(daySummary.expenses, currencyCode)
                            font.pixelSize: Theme.fontSizeMD
                            font.weight: Font.SemiBold
                            color: Theme.expense
                        }
                    }

                    Rectangle { width: 1; height: 35; color: Theme.gray200 }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: "Net"
                            font.pixelSize: Theme.fontSizeXS
                            color: Theme.gray500
                        }

                        Text {
                            text: Theme.formatCurrency(daySummary.net, currencyCode)
                            font.pixelSize: Theme.fontSizeMD
                            font.weight: Font.SemiBold
                            color: daySummary.net >= 0 ? Theme.income : Theme.expense
                        }
                    }
                }
            }

            // Transactions list
            GlassCard {
                Layout.fillWidth: true
                visible: transactions.length > 0
                implicitHeight: transactionsList.height + Theme.spacingLG * 2

                contentItem: Column {
                    id: transactionsList
                    width: parent.width
                    spacing: 1

                    Repeater {
                        model: transactions

                        TransactionItem {
                            width: parent.width
                            transaction: modelData
                            currencyCode: dayTransactionsPage.currencyCode

                            onEditRequested: editTransaction(modelData)
                            onDeleteRequested: {
                                Database.deleteTransaction(modelData.id);
                                refreshData();
                            }
                        }
                    }
                }
            }

            // Empty state
            EmptyState {
                Layout.fillWidth: true
                Layout.topMargin: Theme.spacing2XL
                visible: transactions.length === 0
                emoji: "📅"
                title: "No Transactions"
                subtitle: "No transactions on this day"
            }

            Item { Layout.preferredHeight: Theme.spacing2XL }
        }
    }

    function refreshData() {
        var settings = Database.getUserSettings();
        if (settings) {
            currencyCode = settings.currency || "INR";
        }

        transactions = Database.getTransactionsByDate(selectedDate);

        // Calculate day summary
        daySummary = { income: 0, expenses: 0, net: 0 };
        for (var i = 0; i < transactions.length; i++) {
            if (transactions[i].type === "income") {
                daySummary.income += transactions[i].amount;
            } else {
                daySummary.expenses += transactions[i].amount;
            }
        }
        daySummary.net = daySummary.income - daySummary.expenses;
    }

    Component.onCompleted: {
        refreshData();
    }
}
