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
        contentHeight: contentColumn.height + units.gu(3)
        clip: true

        ColumnLayout {
            id: contentColumn
            width: parent.width - units.gu(4)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: units.gu(2)

            Item { Layout.preferredHeight: units.gu(1) }

            // Day summary card
            GlassCard {
                Layout.fillWidth: true

                RowLayout {
                    spacing: units.gu(1.5)

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: units.dp(2)

                        Label {
                            text: "Income"
                            fontSize: "x-small"
                            color: Theme.gray500
                        }

                        Label {
                            text: Theme.formatCurrency(daySummary.income, currencyCode)
                            fontSize: "medium"
                            font.weight: Font.DemiBold
                            color: Theme.income
                        }
                    }

                    Rectangle { width: units.dp(1); height: units.gu(4); color: Theme.gray200 }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: units.dp(2)

                        Label {
                            text: "Expenses"
                            fontSize: "x-small"
                            color: Theme.gray500
                        }

                        Label {
                            text: Theme.formatCurrency(daySummary.expenses, currencyCode)
                            fontSize: "medium"
                            font.weight: Font.DemiBold
                            color: Theme.expense
                        }
                    }

                    Rectangle { width: units.dp(1); height: units.gu(4); color: Theme.gray200 }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: units.dp(2)

                        Label {
                            text: "Net"
                            fontSize: "x-small"
                            color: Theme.gray500
                        }

                        Label {
                            text: Theme.formatCurrency(daySummary.net, currencyCode)
                            fontSize: "medium"
                            font.weight: Font.DemiBold
                            color: daySummary.net >= 0 ? Theme.income : Theme.expense
                        }
                    }
                }
            }

            // Transactions list
            GlassCard {
                Layout.fillWidth: true
                visible: transactions.length > 0
                implicitHeight: transactionsList.height + units.gu(4)

                Column {
                    id: transactionsList
                    Layout.fillWidth: true

                    Repeater {
                        model: transactions

                        TransactionItem {
                            width: transactionsList.width
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
                Layout.topMargin: units.gu(3)
                visible: transactions.length === 0
                iconName: "calendar"
                title: "No Transactions"
                subtitle: "No transactions on this day"
            }

            Item { Layout.preferredHeight: units.gu(3) }
        }
    }

    function refreshData() {
        var settings = Database.getUserSettings();
        if (settings) {
            currencyCode = settings.currency || "INR";
        }

        transactions = Database.getTransactionsByDate(selectedDate);

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
