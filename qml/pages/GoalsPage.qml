import QtQuick 2.7
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
import ".."
import "../components"

Page {
    id: goalsPage

    property string currencyCode: "INR"
    property var goals: []

    signal goalCompleted(var goal)

    header: PageHeader {
        id: header
        title: "Savings Goals"

        trailingActionBar.actions: [
            Action {
                iconName: "add"
                text: "New Goal"
                onTriggered: openCreateGoal()
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

            Repeater {
                model: goals

                GlassCard {
                    Layout.fillWidth: true

                    ColumnLayout {
                        spacing: units.gu(1.5)

                        // Header row
                        RowLayout {
                            Layout.fillWidth: true

                            Label {
                                text: "🎯"
                                font.pixelSize: units.gu(3)
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0

                                Label {
                                    text: modelData.name
                                    fontSize: "large"
                                    font.weight: Font.DemiBold
                                    color: Theme.gray900
                                }

                                Label {
                                    text: getGoalStatus(modelData)
                                    fontSize: "small"
                                    color: getGoalStatusColor(modelData)
                                }
                            }

                            Icon {
                                width: units.gu(2.5)
                                height: units.gu(2.5)
                                name: "navigation-menu"
                                color: Theme.gray500

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: openGoalMenu(modelData)
                                }
                            }
                        }

                        // Amount row
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: units.gu(1)

                            Label {
                                text: Theme.formatCurrency(modelData.saved_amount, currencyCode)
                                fontSize: "x-large"
                                font.weight: Font.Bold
                                color: Theme.gray900
                            }

                            Label {
                                text: "/ " + Theme.formatCurrency(modelData.target_amount, currencyCode)
                                fontSize: "medium"
                                color: Theme.gray500
                            }

                            Item { Layout.fillWidth: true }

                            Label {
                                text: Math.round(modelData.percentComplete) + "%"
                                fontSize: "large"
                                font.weight: Font.Bold
                                color: Theme.primary
                            }
                        }

                        // Progress bar
                        ProgressBar {
                            Layout.fillWidth: true
                            barHeight: units.gu(1.5)
                            value: modelData.saved_amount
                            maxValue: modelData.target_amount
                            barColor: modelData.is_completed ? Theme.income : Theme.primary
                            showMilestones: true
                        }

                        // Action button
                        Button {
                            Layout.fillWidth: true
                            text: "Add Money"
                            color: Theme.primary
                            visible: !modelData.is_completed
                            onClicked: openAddContribution(modelData)
                        }

                        // Completed badge
                        LomiriShape {
                            Layout.fillWidth: true
                            Layout.preferredHeight: units.gu(5)
                            aspect: LomiriShape.Flat
                            backgroundColor: Qt.rgba(Theme.income.r, Theme.income.g, Theme.income.b, 0.15)
                            radius: "medium"
                            visible: modelData.is_completed

                            Row {
                                anchors.centerIn: parent
                                spacing: units.gu(1)

                                Icon {
                                    width: units.gu(2)
                                    height: units.gu(2)
                                    name: "tick"
                                    color: Theme.income
                                }

                                Label {
                                    text: "Goal Completed!"
                                    fontSize: "medium"
                                    font.weight: Font.DemiBold
                                    color: Theme.income
                                }
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: openGoalDetails(modelData)
                        z: -1
                    }
                }
            }

            EmptyState {
                Layout.fillWidth: true
                Layout.topMargin: units.gu(4)
                visible: goals.length === 0
                emoji: "🎯"
                title: "No Goals Yet"
                subtitle: "Start saving for something special"
                actionText: "Create Goal"
                onActionClicked: openCreateGoal()
            }

            Item { Layout.preferredHeight: units.gu(10) }
        }
    }

    // ---- Lomiri Dialogs ----
    property var editingGoal: null
    property var selectedGoal: null

    // Create/Edit Goal Dialog
    Component {
        id: goalDialogComponent

        Dialog {
            id: goalDialog
            title: goalsPage.editingGoal ? "Edit Goal" : "Create Goal"

            TextField {
                id: goalNameInput
                placeholderText: "Goal name (e.g., Emergency Fund)"
                text: goalsPage.editingGoal ? goalsPage.editingGoal.name : ""
            }

            TextField {
                id: goalTargetInput
                placeholderText: "Target amount"
                inputMethodHints: Qt.ImhDigitsOnly
                text: goalsPage.editingGoal ? goalsPage.editingGoal.target_amount.toString() : ""
            }

            TextField {
                id: goalDeadlineInput
                placeholderText: "Deadline (YYYY-MM-DD)"
                text: goalsPage.editingGoal ?
                    Qt.formatDate(new Date(goalsPage.editingGoal.deadline), "yyyy-MM-dd") :
                    Qt.formatDate(new Date(Date.now() + 90 * 24 * 60 * 60 * 1000), "yyyy-MM-dd")
                inputMethodHints: Qt.ImhDate
            }

            Button {
                text: goalsPage.editingGoal ? "Update" : "Create Goal"
                color: Theme.primary
                onClicked: {
                    var name = goalNameInput.text.trim();
                    var target = parseFloat(goalTargetInput.text) || 0;
                    var deadline = goalDeadlineInput.text;
                    if (name === "" || target <= 0) return;

                    if (goalsPage.editingGoal) {
                        Database.updateGoal(goalsPage.editingGoal.id, name, target, deadline);
                    } else {
                        Database.addGoal(name, target, deadline);
                    }
                    PopupUtils.close(goalDialog);
                    goalsPage.refreshData();
                }
            }

            Button {
                text: "Delete"
                color: Theme.expense
                visible: goalsPage.editingGoal !== null
                onClicked: {
                    if (goalsPage.editingGoal) {
                        Database.deleteGoal(goalsPage.editingGoal.id);
                    }
                    PopupUtils.close(goalDialog);
                    goalsPage.refreshData();
                }
            }

            Button {
                text: "Cancel"
                onClicked: PopupUtils.close(goalDialog)
            }
        }
    }

    // Add Contribution Dialog
    Component {
        id: contributionDialogComponent

        Dialog {
            id: contribDialog
            title: "Add Money to " + (goalsPage.selectedGoal ? goalsPage.selectedGoal.name : "")

            TextField {
                id: contribAmountInput
                placeholderText: "Amount"
                inputMethodHints: Qt.ImhDigitsOnly
            }

            TextField {
                id: contribNoteInput
                placeholderText: "Note (optional)"
            }

            Button {
                text: "Add"
                color: Theme.primary
                onClicked: {
                    if (!goalsPage.selectedGoal) return;
                    var amount = parseFloat(contribAmountInput.text) || 0;
                    var note = contribNoteInput.text.trim();
                    if (amount <= 0) return;

                    var wasCompleted = goalsPage.selectedGoal.is_completed;
                    Database.addContribution(goalsPage.selectedGoal.id, amount, note);
                    PopupUtils.close(contribDialog);
                    goalsPage.refreshData();

                    var updatedGoal = Database.getGoalById(goalsPage.selectedGoal.id);
                    if (updatedGoal && updatedGoal.is_completed && !wasCompleted) {
                        PopupUtils.open(celebrationDialogComponent);
                    }
                }
            }

            Button {
                text: "Cancel"
                onClicked: PopupUtils.close(contribDialog)
            }
        }
    }

    // Celebration Dialog
    Component {
        id: celebrationDialogComponent

        Dialog {
            id: celebDialog
            title: "🎉 Congratulations!"
            text: "You've completed your savings goal!"

            Button {
                text: "Awesome!"
                color: Theme.income
                onClicked: PopupUtils.close(celebDialog)
            }
        }
    }

    function openCreateGoal() {
        editingGoal = null;
        PopupUtils.open(goalDialogComponent);
    }

    function openEditGoal(goal) {
        editingGoal = goal;
        PopupUtils.open(goalDialogComponent);
    }

    function openAddContribution(goal) {
        selectedGoal = goal;
        PopupUtils.open(contributionDialogComponent);
    }

    function openGoalDetails(goal) { openEditGoal(goal); }
    function openGoalMenu(goal) { openEditGoal(goal); }

    function getGoalStatus(goal) {
        if (goal.is_completed) return "✓ Completed";
        if (goal.daysLeft < 0) return "Overdue by " + Math.abs(goal.daysLeft) + " days";
        if (goal.daysLeft === 0) return "Due today";
        return goal.daysLeft + " days left";
    }

    function getGoalStatusColor(goal) {
        if (goal.is_completed) return Theme.income;
        if (goal.daysLeft < 0) return Theme.expense;
        if (goal.daysLeft <= 7) return Theme.warning;
        return Theme.gray500;
    }

    function refreshData() {
        var settings = Database.getUserSettings();
        if (settings) { currencyCode = settings.currency || "INR"; }
        goals = Database.getGoals(false);
    }

    Component.onCompleted: { refreshData(); }
}
