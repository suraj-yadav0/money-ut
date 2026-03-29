import QtQuick 2.7
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3
import ".."
import "../components"

Page {
    id: allTransactionsPage

    property string currencyCode: "INR"
    property var groupedTransactions: ({})
    property var sortedDates: []

    signal editTransaction(var transaction)

    header: PageHeader {
        id: header
        title: "All Transactions"

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

        onContentYChanged: {
            if (contentY < -units.gu(10) && !dragging) {
                refreshData();
            }
        }

        ColumnLayout {
            id: contentColumn
            width: parent.width - units.gu(4)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: units.gu(1.5)

            Item { Layout.preferredHeight: units.gu(1) }

            // Grouped transactions
            Repeater {
                model: sortedDates

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: units.gu(1)

                    // Date header
                    Label {
                        text: Theme.getSmartDateHeader(modelData)
                        fontSize: "small"
                        font.weight: Font.DemiBold
                        color: Theme.gray500
                        Layout.topMargin: index > 0 ? units.gu(1.5) : 0
                    }

                    // Transactions for this date
                    GlassCard {
                        Layout.fillWidth: true
                        implicitHeight: dateTransactions.height + units.gu(4)

                        Column {
                            id: dateTransactions
                            width: parent.width

                            Repeater {
                                model: groupedTransactions[modelData] || []

                                TransactionItem {
                                    width: dateTransactions.width
                                    transaction: modelData
                                    currencyCode: allTransactionsPage.currencyCode

                                    onEditRequested: editTransaction(modelData)
                                    onDeleteRequested: {
                                        Database.deleteTransaction(modelData.id);
                                        refreshData();
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Empty state
            EmptyState {
                Layout.fillWidth: true
                Layout.topMargin: units.gu(4)
                visible: sortedDates.length === 0
                iconName: "stock_note"
                title: "No Transactions"
                subtitle: "Your transaction history will appear here"
            }

            Item { Layout.preferredHeight: units.gu(3) }
        }
    }

    function refreshData() {
        var settings = Database.getUserSettings();
        if (settings) {
            currencyCode = settings.currency || "INR";
        }

        groupedTransactions = Database.getTransactionsGroupedByDate(null, null);

        sortedDates = Object.keys(groupedTransactions).sort(function(a, b) {
            return b.localeCompare(a);
        });
    }

    Component.onCompleted: {
        refreshData();
    }
}
