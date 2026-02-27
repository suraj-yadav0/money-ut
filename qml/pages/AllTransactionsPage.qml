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
        contentHeight: contentColumn.height + Theme.spacing2XL
        clip: true

        // Pull to refresh
        onContentYChanged: {
            if (contentY < -80 && !dragging) {
                refreshData();
            }
        }

        ColumnLayout {
            id: contentColumn
            width: parent.width - Theme.spacingLG * 2
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.spacingMD

            Item { Layout.preferredHeight: Theme.spacingSM }

            // Grouped transactions
            Repeater {
                model: sortedDates

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingSM

                    // Date header
                    Label {
                        text: Theme.getSmartDateHeader(modelData)
                        font.pixelSize: Theme.fontSizeSM
                        font.weight: Font.DemiBold
                        color: Theme.gray500
                        Layout.topMargin: index > 0 ? Theme.spacingMD : 0
                    }

                    // Transactions for this date
                    GlassCard {
                        Layout.fillWidth: true
                        implicitHeight: dateTransactions.height + Theme.spacingLG * 2

                        Column {
                            id: dateTransactions
                            width: parent.width
                            spacing: 1

                            Repeater {
                                model: groupedTransactions[modelData] || []

                                TransactionItem {
                                    width: parent.width
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
                Layout.topMargin: Theme.spacing3XL
                visible: sortedDates.length === 0
                emoji: "📝"
                title: "No Transactions"
                subtitle: "Your transaction history will appear here"
            }

            Item { Layout.preferredHeight: Theme.spacing2XL }
        }
    }

    function refreshData() {
        var settings = Database.getUserSettings();
        if (settings) {
            currencyCode = settings.currency || "INR";
        }

        groupedTransactions = Database.getTransactionsGroupedByDate(null, null);

        // Sort dates descending
        sortedDates = Object.keys(groupedTransactions).sort(function(a, b) {
            return b.localeCompare(a);
        });
    }

    Component.onCompleted: {
        refreshData();
    }
}
