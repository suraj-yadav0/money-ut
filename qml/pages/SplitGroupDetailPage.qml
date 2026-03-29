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
        contentHeight: contentColumn.height + units.gu(3)
        clip: true

        ColumnLayout {
            id: contentColumn
            width: parent.width - units.gu(4)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: units.gu(2)

            Item { Layout.preferredHeight: units.gu(1) }

            // Members row
            GlassCard {
                Layout.fillWidth: true

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: units.gu(1)

                    Label {
                        text: "Members"
                        fontSize: "medium"
                        font.weight: Font.DemiBold
                        color: Theme.gray700
                    }

                    Flow {
                        Layout.fillWidth: true
                        spacing: units.gu(1)

                        Repeater {
                            model: members

                            LomiriShape {
                                aspect: LomiriShape.Flat
                                radius: "medium"
                                implicitWidth: memberNameLabel.implicitWidth + units.gu(2)
                                implicitHeight: units.gu(3.5)
                                backgroundColor: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12)

                                Label {
                                    id: memberNameLabel
                                    anchors.centerIn: parent
                                    text: modelData.name
                                    fontSize: "small"
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
                    Layout.fillWidth: true
                    spacing: units.gu(1)

                    Label {
                        text: "Balances"
                        fontSize: "medium"
                        font.weight: Font.DemiBold
                        color: Theme.gray700
                    }

                    Repeater {
                        model: balances

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: units.gu(1)

                            Label {
                                text: modelData.fromName
                                fontSize: "medium"
                                font.weight: Font.DemiBold
                                color: Theme.expense
                                Layout.preferredWidth: 80
                                elide: Text.ElideRight
                            }

                            Label {
                                text: "owes"
                                fontSize: "small"
                                color: Theme.gray500
                            }

                            Label {
                                text: modelData.toName
                                fontSize: "medium"
                                font.weight: Font.DemiBold
                                color: Theme.income
                                Layout.preferredWidth: 80
                                elide: Text.ElideRight
                            }

                            Item { Layout.fillWidth: true }

                            Label {
                                text: Theme.formatFullCurrency(modelData.amount, currencyCode)
                                fontSize: "medium"
                                font.weight: Font.Bold
                                color: Theme.gray900
                            }

                            // Settle button
                            LomiriShape {
                                aspect: LomiriShape.Flat
                                radius: "medium"
                                implicitWidth: settleLabel.implicitWidth + units.gu(1.5)
                                implicitHeight: units.gu(3.5)
                                backgroundColor: Theme.income

                                Label {
                                    id: settleLabel
                                    anchors.centerIn: parent
                                    text: "Settle"
                                    fontSize: "x-small"
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
                    Layout.fillWidth: true
                    spacing: units.gu(1.5)

                    Icon {
                        name: "tick"
                        width: units.gu(3)
                        height: units.gu(3)
                        color: Theme.income
                    }

                    Label {
                        text: "All settled up!"
                        fontSize: "medium"
                        font.weight: Font.DemiBold
                        color: Theme.income
                    }
                }
            }

            // Expenses section header
            RowLayout {
                Layout.fillWidth: true

                Label {
                    text: "Expenses"
                    fontSize: "large"
                    font.weight: Font.Bold
                    color: Theme.gray900
                }

                Item { Layout.fillWidth: true }

                Label {
                    text: expenses.length + " total"
                    fontSize: "small"
                    color: Theme.gray500
                }
            }

            // Expenses list
            Repeater {
                model: expenses

                GlassCard {
                    Layout.fillWidth: true

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: units.gu(1)

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: units.gu(1.5)

                            LomiriShape {
                                width: units.gu(5)
                                height: units.gu(5)
                                aspect: LomiriShape.Flat
                                radius: "large"
                                relativeRadius: 0.5
                                backgroundColor: Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.15)

                                Icon {
                                    anchors.centerIn: parent
                                    width: units.gu(2.5)
                                    height: units.gu(2.5)
                                    name: "payment"
                                    color: Theme.secondary
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Label {
                                    text: modelData.description
                                    fontSize: "medium"
                                    font.weight: Font.DemiBold
                                    color: Theme.gray900
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Label {
                                    text: "Paid by " + modelData.paid_by_name + " · " + modelData.date
                                    fontSize: "x-small"
                                    color: Theme.gray500
                                }
                            }

                            ColumnLayout {
                                spacing: 2

                                Label {
                                    text: Theme.formatCurrency(modelData.amount, currencyCode)
                                    fontSize: "large"
                                    font.weight: Font.Bold
                                    color: Theme.gray900
                                    horizontalAlignment: Text.AlignRight
                                    Layout.alignment: Qt.AlignRight
                                }

                                // Delete button
                                Icon {
                                    name: "delete"
                                    width: units.gu(2)
                                    height: units.gu(2)
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
                Layout.topMargin: units.gu(3)
                visible: expenses.length === 0
                iconName: "payment"
                title: "No Expenses Yet"
                subtitle: "Add the first shared expense"
                actionText: "Add Expense"
                onActionClicked: splitGroupDetailPage.addExpenseRequested(groupId, members)
            }

            Item { Layout.preferredHeight: units.gu(10) }
        }
    }

    // FAB: Add expense
    LomiriShape {
        anchors {
            right: parent.right
            bottom: parent.bottom
            rightMargin: units.gu(2)
            bottomMargin: units.gu(2)
        }
        width: units.gu(7)
        height: units.gu(7)
        aspect: LomiriShape.Flat
        radius: "large"
        relativeRadius: 0.5
        backgroundColor: Theme.primary

        Icon {
            anchors.centerIn: parent
            width: units.gu(3.5)
            height: units.gu(3.5)
            name: "add"
            color: Theme.white
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: splitGroupDetailPage.addExpenseRequested(groupId, members)
        }
    }
}
