import QtQuick 2.7
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3
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

            // Goals list
            Repeater {
                model: goals

                GlassCard {
                    Layout.fillWidth: true

                    contentItem: ColumnLayout {
                        spacing: Theme.spacingMD

                        // Header row
                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text: "🎯"
                                font.pixelSize: 24
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0

                                Text {
                                    text: modelData.name
                                    font.pixelSize: Theme.fontSizeLG
                                    font.weight: Font.SemiBold
                                    color: Theme.gray900
                                }

                                Text {
                                    text: getGoalStatus(modelData)
                                    font.pixelSize: Theme.fontSizeSM
                                    color: getGoalStatusColor(modelData)
                                }
                            }

                            // Menu button
                            Text {
                                text: "⋮"
                                font.pixelSize: 20
                                color: Theme.gray500

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: openGoalMenu(modelData)
                                }
                            }
                        }

                        // Amount row
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Theme.spacingSM

                            Text {
                                text: Theme.formatCurrency(modelData.saved_amount, currencyCode)
                                font.pixelSize: Theme.fontSize2XL
                                font.weight: Font.Bold
                                color: Theme.gray900
                            }

                            Text {
                                text: "/ " + Theme.formatCurrency(modelData.target_amount, currencyCode)
                                font.pixelSize: Theme.fontSizeMD
                                color: Theme.gray500
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                text: Math.round(modelData.percentComplete) + "%"
                                font.pixelSize: Theme.fontSizeLG
                                font.weight: Font.Bold
                                color: Theme.primary
                            }
                        }

                        // Progress bar with milestones
                        ProgressBar {
                            Layout.fillWidth: true
                            barHeight: 12
                            value: modelData.saved_amount
                            maxValue: modelData.target_amount
                            barColor: modelData.is_completed ? Theme.income : Theme.primary
                            showMilestones: true
                        }

                        // Add money button
                        Rectangle {
                            Layout.fillWidth: true
                            height: 44
                            radius: Theme.radiusButton
                            color: Theme.primary
                            visible: !modelData.is_completed

                            Text {
                                anchors.centerIn: parent
                                text: "Add Money"
                                font.pixelSize: Theme.fontSizeMD
                                font.weight: Font.SemiBold
                                color: Theme.white
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: openAddContribution(modelData)
                            }
                        }

                        // Completed badge
                        Rectangle {
                            Layout.fillWidth: true
                            height: 44
                            radius: Theme.radiusButton
                            color: Qt.rgba(Theme.income.r, Theme.income.g, Theme.income.b, 0.15)
                            visible: modelData.is_completed

                            Row {
                                anchors.centerIn: parent
                                spacing: Theme.spacingSM

                                Text {
                                    text: "✓"
                                    font.pixelSize: 18
                                    color: Theme.income
                                }

                                Text {
                                    text: "Goal Completed!"
                                    font.pixelSize: Theme.fontSizeMD
                                    font.weight: Font.SemiBold
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

            // Empty state
            EmptyState {
                Layout.fillWidth: true
                Layout.topMargin: Theme.spacing3XL
                visible: goals.length === 0
                emoji: "🎯"
                title: "No Goals Yet"
                subtitle: "Start saving for something special"
                actionText: "Create Goal"
                onActionClicked: openCreateGoal()
            }

            Item { Layout.preferredHeight: 80 }
        }
    }

    // FAB
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
            onClicked: openCreateGoal()
        }
    }

    // Create/Edit Goal Dialog
    property bool showGoalDialog: false
    property var editingGoal: null

    Rectangle {
        id: goalDialogOverlay
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.5)
        visible: showGoalDialog
        opacity: showGoalDialog ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: Theme.animationNormal }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: showGoalDialog = false
        }

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: 380
            radius: Theme.radiusXL
            color: Theme.white

            ColumnLayout {
                anchors {
                    fill: parent
                    margins: Theme.spacingLG
                }
                spacing: Theme.spacingMD

                Text {
                    text: editingGoal ? "Edit Goal" : "Create Goal"
                    font.pixelSize: Theme.fontSizeXL
                    font.weight: Font.Bold
                    color: Theme.gray900
                }

                // Name
                TextField {
                    id: goalNameInput
                    Layout.fillWidth: true
                    placeholderText: "Goal name (e.g., Emergency Fund)"
                }

                // Target amount
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingSM

                    Text {
                        text: Theme.getCurrencySymbol(currencyCode)
                        font.pixelSize: Theme.fontSizeLG
                        color: Theme.gray500
                    }

                    TextField {
                        id: goalTargetInput
                        Layout.fillWidth: true
                        placeholderText: "Target amount"
                        inputMethodHints: Qt.ImhDigitsOnly
                    }
                }

                // Deadline
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingSM

                    Text {
                        text: "Deadline:"
                        font.pixelSize: Theme.fontSizeMD
                        color: Theme.gray700
                    }

                    TextField {
                        id: goalDeadlineInput
                        Layout.fillWidth: true
                        text: Qt.formatDate(new Date(Date.now() + 90 * 24 * 60 * 60 * 1000), "yyyy-MM-dd")
                        inputMethodHints: Qt.ImhDate
                    }
                }

                Item { Layout.fillHeight: true }

                // Buttons
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingSM

                    Rectangle {
                        visible: editingGoal !== null
                        Layout.fillWidth: true
                        height: 48
                        radius: Theme.radiusButton
                        color: Theme.expense

                        Text {
                            anchors.centerIn: parent
                            text: "Delete"
                            font.pixelSize: Theme.fontSizeMD
                            font.weight: Font.SemiBold
                            color: Theme.white
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: deleteGoal()
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 48
                        radius: Theme.radiusButton
                        color: Theme.primary

                        Text {
                            anchors.centerIn: parent
                            text: editingGoal ? "Update" : "Create Goal"
                            font.pixelSize: Theme.fontSizeMD
                            font.weight: Font.SemiBold
                            color: Theme.white
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: saveGoal()
                        }
                    }
                }
            }
        }
    }

    // Add Contribution Dialog
    property bool showContributionDialog: false
    property var selectedGoal: null

    Rectangle {
        id: contributionDialogOverlay
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.5)
        visible: showContributionDialog
        opacity: showContributionDialog ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: Theme.animationNormal }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: showContributionDialog = false
        }

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: 300
            radius: Theme.radiusXL
            color: Theme.white

            ColumnLayout {
                anchors {
                    fill: parent
                    margins: Theme.spacingLG
                }
                spacing: Theme.spacingMD

                Text {
                    text: "Add Money to " + (selectedGoal ? selectedGoal.name : "")
                    font.pixelSize: Theme.fontSizeXL
                    font.weight: Font.Bold
                    color: Theme.gray900
                }

                // Amount
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingSM

                    Text {
                        text: Theme.getCurrencySymbol(currencyCode)
                        font.pixelSize: Theme.fontSize2XL
                        color: Theme.gray500
                    }

                    TextField {
                        id: contributionAmountInput
                        Layout.fillWidth: true
                        placeholderText: "Amount"
                        inputMethodHints: Qt.ImhDigitsOnly
                        font.pixelSize: Theme.fontSize2XL
                    }
                }

                // Note
                TextField {
                    id: contributionNoteInput
                    Layout.fillWidth: true
                    placeholderText: "Note (optional)"
                }

                Item { Layout.fillHeight: true }

                Rectangle {
                    Layout.fillWidth: true
                    height: 48
                    radius: Theme.radiusButton
                    color: Theme.primary

                    Text {
                        anchors.centerIn: parent
                        text: "Add"
                        font.pixelSize: Theme.fontSizeMD
                        font.weight: Font.SemiBold
                        color: Theme.white
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: saveContribution()
                    }
                }
            }
        }
    }

    // Goal Completion Celebration Dialog
    property bool showCelebration: false
    property var completedGoal: null

    Rectangle {
        id: celebrationOverlay
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.7)
        visible: showCelebration
        opacity: showCelebration ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: Theme.animationNormal }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: showCelebration = false
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: Theme.spacingXL

            Text {
                text: "🎉"
                font.pixelSize: 80
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "Congratulations!"
                font.pixelSize: Theme.fontSize3XL
                font.weight: Font.Bold
                color: Theme.white
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "You've completed your goal:\n" + (completedGoal ? completedGoal.name : "")
                font.pixelSize: Theme.fontSizeLG
                color: Theme.gray200
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
            }

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 120
                height: 48
                radius: Theme.radiusButton
                color: Theme.income

                Row {
                    anchors.centerIn: parent
                    spacing: Theme.spacingSM

                    Text {
                        text: "✓"
                        font.pixelSize: 20
                        color: Theme.white
                    }

                    Text {
                        text: "Done"
                        font.pixelSize: Theme.fontSizeMD
                        font.weight: Font.SemiBold
                        color: Theme.white
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: showCelebration = false
                }
            }
        }
    }

    function openCreateGoal() {
        editingGoal = null;
        goalNameInput.text = "";
        goalTargetInput.text = "";
        goalDeadlineInput.text = Qt.formatDate(new Date(Date.now() + 90 * 24 * 60 * 60 * 1000), "yyyy-MM-dd");
        showGoalDialog = true;
    }

    function openEditGoal(goal) {
        editingGoal = goal;
        goalNameInput.text = goal.name;
        goalTargetInput.text = goal.target_amount.toString();
        goalDeadlineInput.text = Qt.formatDate(new Date(goal.deadline), "yyyy-MM-dd");
        showGoalDialog = true;
    }

    function saveGoal() {
        var name = goalNameInput.text.trim();
        var target = parseFloat(goalTargetInput.text) || 0;
        var deadline = goalDeadlineInput.text;

        if (name === "" || target <= 0) return;

        if (editingGoal) {
            Database.updateGoal(editingGoal.id, name, target, deadline);
        } else {
            Database.addGoal(name, target, deadline);
        }

        showGoalDialog = false;
        refreshData();
    }

    function deleteGoal() {
        if (editingGoal) {
            Database.deleteGoal(editingGoal.id);
            showGoalDialog = false;
            refreshData();
        }
    }

    function openAddContribution(goal) {
        selectedGoal = goal;
        contributionAmountInput.text = "";
        contributionNoteInput.text = "";
        showContributionDialog = true;
    }

    function saveContribution() {
        if (!selectedGoal) return;

        var amount = parseFloat(contributionAmountInput.text) || 0;
        var note = contributionNoteInput.text.trim();

        if (amount <= 0) return;

        var wasCompleted = selectedGoal.is_completed;
        Database.addContribution(selectedGoal.id, amount, note);

        showContributionDialog = false;
        refreshData();

        // Check if goal just got completed
        var updatedGoal = Database.getGoalById(selectedGoal.id);
        if (updatedGoal && updatedGoal.is_completed && !wasCompleted) {
            completedGoal = updatedGoal;
            showCelebration = true;
        }
    }

    function openGoalDetails(goal) {
        // Could navigate to details page or show a sheet
        openEditGoal(goal);
    }

    function openGoalMenu(goal) {
        openEditGoal(goal);
    }

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
        if (settings) {
            currencyCode = settings.currency || "INR";
        }
        goals = Database.getGoals(false);
    }

    Component.onCompleted: {
        refreshData();
    }
}
