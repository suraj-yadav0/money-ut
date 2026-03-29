import QtQuick 2.7
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3
import ".."
import "../components"

Page {
    id: splitGroupDetailPage

    property int groupId: -1
    property string groupName: ""
    property string currencyCode: "INR"
    property var members: []
    property var expenses: []
    property var balances: []

    signal addExpenseRequested(int gid, var mems)

    function refreshData() {
        var settings = Database.getUserSettings();
        if (settings) currencyCode = settings.currency || "INR";
        if (groupId < 0) return;
        var g = Database.getSplitGroupById(groupId);
        if (g) groupName = g.name;
        members = Database.getSplitMembers(groupId);
        expenses = Database.getSplitExpenses(groupId);
        balances = Database.getSplitGroupBalances(groupId);
    }

    Component.onCompleted: refreshData()

    header: PageHeader {
        id: header
        title: groupName
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

            // Members row
            GlassCard {
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: Theme.spacingSM

                    Text {
                        text: "Members"
                        font.pixelSize: Theme.fontSizeMD
                        font.weight: Font.DemiBold
                        color: Theme.gray700
                    }

                    Flow {
                        Layout.fillWidth: true
                        spacing: Theme.spacingSM

                        Repeater {
                            model: members

                            Rectangle {
                                width: memberNameText.width + Theme.spacingLG
                                height: 28
                                radius: 14
                                color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12)

                                Text {
                                    id: memberNameText
                                    anchors.centerIn: parent
                                    text: modelData.name
                                    font.pixelSize: Theme.fontSizeSM
                                    color: Theme.primary
                                    font.weight: Font.DemiBold
                                }
                            }
                        }
                    }
                }
            }

            // Balances section
            GlassCard {
                Layout.fillWidth: true
                visible: balances.length > 0

                ColumnLayout {
                    spacing: Theme.spacingSM

                    Text {
                        text: "Balances"
                        font.pixelSize: Theme.fontSizeMD
                        font.weight: Font.DemiBold
                        color: Theme.gray700
                    }

                    Repeater {
                        model: balances

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Theme.spacingSM

                            Text {
                                text: modelData.fromName
                                font.pixelSize: Theme.fontSizeMD
                                font.weight: Font.DemiBold
                                color: Theme.expense
                                Layout.preferredWidth: 80
                                elide: Text.ElideRight
                            }

                            Text {
                                text: "owes"
                                font.pixelSize: Theme.fontSizeSM
                                color: Theme.gray500
                            }

                            Text {
                                text: modelData.toName
                                font.pixelSize: Theme.fontSizeMD
                                font.weight: Font.DemiBold
                                color: Theme.income
                                Layout.preferredWidth: 80
                                elide: Text.ElideRight
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                text: Theme.formatFullCurrency(modelData.amount, currencyCode)
                                font.pixelSize: Theme.fontSizeMD
                                font.weight: Font.Bold
                                color: Theme.gray900
                            }

                            // Settle button
                            Rectangle {
                                width: settleText.width + Theme.spacingMD
                                height: 28
                                radius: 14
                                color: Theme.income

                                Text {
                                    id: settleText
                                    anchors.centerIn: parent
                                    text: "Settle"
                                    font.pixelSize: Theme.fontSizeXS
                                    font.weight: Font.DemiBold
                                    color: Theme.white
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        Database.settleBetweenMembers(groupId, modelData.fromMemberId, modelData.toMemberId);
                                        refreshData();
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // All settled state
            GlassCard {
                Layout.fillWidth: true
                visible: balances.length === 0 && expenses.length > 0

                RowLayout {
                    spacing: Theme.spacingMD

                    Text {
                        text: "✅"
                        font.pixelSize: 24
                    }

                    Text {
                        text: "All settled up!"
                        font.pixelSize: Theme.fontSizeMD
                        font.weight: Font.DemiBold
                        color: Theme.income
                    }
                }
            }

            // Expenses section header
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Expenses"
                    font.pixelSize: Theme.fontSizeLG
                    font.weight: Font.Bold
                    color: Theme.gray900
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: expenses.length + " total"
                    font.pixelSize: Theme.fontSizeSM
                    color: Theme.gray500
                }
            }

            // Expenses list
            Repeater {
                model: expenses

                GlassCard {
                    Layout.fillWidth: true

                    ColumnLayout {
                        spacing: Theme.spacingSM

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Theme.spacingMD

                            Rectangle {
                                width: 40
                                height: 40
                                radius: 20
                                color: Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.15)

                                Text {
                                    anchors.centerIn: parent
                                    text: "💳"
                                    font.pixelSize: 18
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: modelData.description
                                    font.pixelSize: Theme.fontSizeMD
                                    font.weight: Font.DemiBold
                                    color: Theme.gray900
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: "Paid by " + modelData.paid_by_name + " · " + modelData.date
                                    font.pixelSize: Theme.fontSizeXS
                                    color: Theme.gray500
                                }
                            }

                            ColumnLayout {
                                spacing: 2

                                Text {
                                    text: Theme.formatCurrency(modelData.amount, currencyCode)
                                    font.pixelSize: Theme.fontSizeLG
                                    font.weight: Font.Bold
                                    color: Theme.gray900
                                    horizontalAlignment: Text.AlignRight
                                    Layout.alignment: Qt.AlignRight
                                }

                                // Delete button
                                Text {
                                    text: "🗑"
                                    font.pixelSize: 14
                                    color: Theme.gray400
                                    Layout.alignment: Qt.AlignRight

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            Database.deleteSplitExpense(modelData.id);
                                            refreshData();
                                        }
                                    }
                                }
                            }
                        }

                        // Shares breakdown
                        SplitSharesView {
                            expenseId: modelData.id
                            currencyCode: splitGroupDetailPage.currencyCode
                            Layout.fillWidth: true
                        }
                    }
                }
            }

            // Empty state for expenses
            EmptyState {
                Layout.fillWidth: true
                Layout.topMargin: Theme.spacing2XL
                visible: expenses.length === 0
                emoji: "💳"
                title: "No Expenses Yet"
                subtitle: "Add the first shared expense"
                actionText: "Add Expense"
                onActionClicked: splitGroupDetailPage.addExpenseRequested(groupId, members)
            }

            Item { Layout.preferredHeight: 80 }
        }
    }

    // FAB: Add expense
    Rectangle {
        anchors {
            right: parent.right
            bottom: parent.bottom
            rightMargin: Theme.spacingLG
            bottomMargin: Theme.spacingLG
        }
        width: 56
        height: 56
        radius: 28
        color: Theme.primary

        Text {
            anchors.centerIn: parent
            text: "+"
            font.pixelSize: 28
            font.weight: Font.Bold
            color: Theme.white
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: splitGroupDetailPage.addExpenseRequested(groupId, members)
        }
    }
}
