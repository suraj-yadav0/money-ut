import QtQuick 2.7
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
import ".."
import "../components"

Page {
    id: addTransactionPage

    property string currencyCode: "INR"
    property var editingTransaction: null
    property bool isEditing: editingTransaction !== null

    property string transactionType: "expense"
    property real amount: 0
    property string note: ""
    property int selectedCategoryId: -1
    property int selectedGoalId: -1
    property string paymentMode: ""
    property date selectedDate: new Date()

    signal transactionSaved()
    signal cancelled()

    header: PageHeader {
        id: header
        title: isEditing ? "Edit Transaction" : "Add Transaction"

        leadingActionBar.actions: [
            Action {
                iconName: "close"
                text: "Cancel"
                onTriggered: cancelled()
            }
        ]

        trailingActionBar.actions: [
            Action {
                iconName: "tick"
                text: "Save"
                onTriggered: saveTransaction()
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
        contentHeight: contentColumn.height + units.gu(4)
        clip: true

        ColumnLayout {
            id: contentColumn
            width: parent.width - units.gu(4)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: units.gu(2)

            Item { Layout.preferredHeight: units.gu(1) }

            // Type toggle using SegmentedButton style
            LomiriShape {
                Layout.fillWidth: true
                Layout.preferredHeight: units.gu(7)
                aspect: LomiriShape.Flat
                radius: "large"
                backgroundColor: transactionType === "expense" ?
                    Qt.rgba(Theme.expense.r, Theme.expense.g, Theme.expense.b, 0.15) :
                    Qt.rgba(Theme.income.r, Theme.income.g, Theme.income.b, 0.15)

                Behavior on backgroundColor {
                    ColorAnimation { duration: 200 }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: units.dp(4)
                    spacing: units.dp(4)

                    AbstractButton {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        onClicked: {
                            transactionType = "expense";
                            selectedCategoryId = -1;
                        }

                        LomiriShape {
                            anchors.fill: parent
                            aspect: LomiriShape.Flat
                            radius: "medium"
                            backgroundColor: transactionType === "expense" ? Theme.expense : "transparent"

                            Label {
                                anchors.centerIn: parent
                                text: "Expense"
                                fontSize: "medium"
                                font.weight: transactionType === "expense" ? Font.DemiBold : Font.Normal
                                color: transactionType === "expense" ? Theme.white : Theme.gray600
                            }
                        }
                    }

                    AbstractButton {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        onClicked: {
                            transactionType = "income";
                            selectedCategoryId = -1;
                            selectedGoalId = -1;
                        }

                        LomiriShape {
                            anchors.fill: parent
                            aspect: LomiriShape.Flat
                            radius: "medium"
                            backgroundColor: transactionType === "income" ? Theme.income : "transparent"

                            Label {
                                anchors.centerIn: parent
                                text: "Income"
                                fontSize: "medium"
                                font.weight: transactionType === "income" ? Font.DemiBold : Font.Normal
                                color: transactionType === "income" ? Theme.white : Theme.gray600
                            }
                        }
                    }
                }
            }

            // Amount input
            GlassCard {
                Layout.fillWidth: true

                RowLayout {
                    Layout.fillWidth: true
                    spacing: units.gu(1)

                    Label {
                        text: Theme.getCurrencySymbol(currencyCode)
                        font.pixelSize: units.gu(3.5)
                        font.weight: Font.Bold
                        color: Theme.gray400
                    }

                    TextField {
                        id: amountInput
                        Layout.fillWidth: true
                        font.pixelSize: units.gu(2.5)
                        placeholderText: "0"
                        inputMethodHints: Qt.ImhDigitsOnly
                        text: amount > 0 ? amount.toString() : ""

                        onTextChanged: {
                            amount = parseFloat(text) || 0;
                        }
                    }
                }
            }

            // Note input
            GlassCard {
                Layout.fillWidth: true

                TextField {
                    id: noteInput
                    Layout.fillWidth: true
                    placeholderText: "Add a note..."
                    text: note

                    onTextChanged: {
                        note = text;
                        autoCategorizationTimer.restart();
                    }
                }
            }

            Timer {
                id: autoCategorizationTimer
                interval: 500
                onTriggered: {
                    var suggestion = Database.suggestCategory(note);
                    if (suggestion) {
                        selectedCategoryId = suggestion.categoryId;
                    }
                }
            }

            // Category selection
            Label {
                text: "Category"
                fontSize: "medium"
                font.weight: Font.DemiBold
                color: Theme.gray700
            }

            Flow {
                Layout.fillWidth: true
                spacing: units.gu(1)

                Repeater {
                    model: Database.getCategories(transactionType)

                    CategoryChip {
                        text: modelData.name
                        selected: selectedCategoryId === modelData.id
                        onClicked: selectedCategoryId = modelData.id
                    }
                }
            }

            // Goal linking (expense only)
            Label {
                text: "Link to Goal"
                fontSize: "medium"
                font.weight: Font.DemiBold
                color: Theme.gray700
                visible: transactionType === "expense"
            }

            Column {
                Layout.fillWidth: true
                spacing: units.gu(1)
                visible: transactionType === "expense"

                Repeater {
                    model: Database.getGoals(true)

                    AbstractButton {
                        width: parent.width
                        height: units.gu(7)

                        onClicked: {
                            if (selectedGoalId === modelData.id) {
                                selectedGoalId = -1;
                            } else {
                                selectedGoalId = modelData.id;
                            }
                        }

                        LomiriShape {
                            anchors.fill: parent
                            aspect: LomiriShape.Flat
                            radius: "medium"
                            backgroundColor: selectedGoalId === modelData.id ?
                                Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1) : Theme.white
                            borderSource: selectedGoalId === modelData.id ? "" : "radius_idle.sci"

                            RowLayout {
                                anchors {
                                    fill: parent
                                    margins: units.gu(1)
                                }
                                spacing: units.gu(1)

                                Label {
                                    text: "🎯"
                                    font.pixelSize: units.gu(2.5)
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 0

                                    Label {
                                        text: modelData.name
                                        fontSize: "medium"
                                        color: Theme.gray900
                                    }

                                    ProgressBar {
                                        Layout.fillWidth: true
                                        barHeight: units.dp(4)
                                        value: modelData.saved_amount
                                        maxValue: modelData.target_amount
                                        barColor: Theme.primary
                                    }
                                }

                                Label {
                                    text: Math.round(modelData.percentComplete) + "%"
                                    fontSize: "small"
                                    color: Theme.gray500
                                }
                            }
                        }
                    }
                }
            }

            // Payment mode
            Label {
                text: "Payment Mode"
                fontSize: "medium"
                font.weight: Font.DemiBold
                color: Theme.gray700
            }

            Flow {
                Layout.fillWidth: true
                spacing: units.gu(1)

                Repeater {
                    model: Theme.paymentModes

                    CategoryChip {
                        text: modelData
                        selected: paymentMode === modelData
                        onClicked: {
                            if (paymentMode === modelData) {
                                paymentMode = "";
                            } else {
                                paymentMode = modelData;
                            }
                        }
                    }
                }
            }

            // Date picker
            Label {
                text: "Date"
                fontSize: "medium"
                font.weight: Font.DemiBold
                color: Theme.gray700
            }

            GlassCard {
                Layout.fillWidth: true

                RowLayout {
                    spacing: units.gu(1)

                    Icon {
                        width: units.gu(2.5)
                        height: units.gu(2.5)
                        name: "calendar"
                        color: Theme.primary
                    }

                    Label {
                        text: Qt.formatDate(selectedDate, "dddd, MMMM d, yyyy")
                        fontSize: "medium"
                        color: Theme.gray900
                        Layout.fillWidth: true
                    }

                    Button {
                        text: "Change"
                        strokeColor: Theme.primary
                        onClicked: PopupUtils.open(datePickerDialogComponent)
                    }
                }
            }

            // Save button
            Button {
                Layout.fillWidth: true
                Layout.topMargin: units.gu(2)
                text: isEditing ? "Update Transaction" : "Add Transaction"
                color: canSave() ? Theme.primary : Theme.gray300
                onClicked: {
                    if (canSave()) saveTransaction();
                }
            }

            // Delete button (edit mode only)
            Button {
                Layout.fillWidth: true
                visible: isEditing
                text: "Delete Transaction"
                color: Theme.expense
                onClicked: deleteTransaction()
            }

            Item { Layout.preferredHeight: units.gu(4) }
        }
    }

    // Date picker dialog
    Component {
        id: datePickerDialogComponent

        Dialog {
            id: datePickerDialog
            title: "Select Date"

            TextField {
                id: dateInput
                text: Qt.formatDate(addTransactionPage.selectedDate, "yyyy-MM-dd")
                placeholderText: "YYYY-MM-DD"
            }

            Flow {
                width: parent.width
                spacing: units.gu(1)

                Repeater {
                    model: [
                        { label: "Today", offset: 0 },
                        { label: "Yesterday", offset: -1 },
                        { label: "2 days ago", offset: -2 },
                        { label: "1 week ago", offset: -7 }
                    ]

                    CategoryChip {
                        text: modelData.label
                        onClicked: {
                            var d = new Date();
                            d.setDate(d.getDate() + modelData.offset);
                            dateInput.text = Qt.formatDate(d, "yyyy-MM-dd");
                        }
                    }
                }
            }

            Button {
                text: "Confirm"
                color: Theme.primary
                onClicked: {
                    addTransactionPage.selectedDate = new Date(dateInput.text);
                    PopupUtils.close(datePickerDialog);
                }
            }

            Button {
                text: "Cancel"
                onClicked: PopupUtils.close(datePickerDialog)
            }
        }
    }

    function canSave() {
        return amount > 0 && selectedCategoryId > 0;
    }

    function saveTransaction() {
        if (!canSave()) return;

        var timestamp = selectedDate.toISOString();
        var goalId = selectedGoalId > 0 ? selectedGoalId : null;

        if (isEditing) {
            Database.updateTransaction(
                editingTransaction.id,
                amount,
                transactionType,
                selectedCategoryId,
                note,
                paymentMode,
                timestamp,
                goalId,
                null
            );
        } else {
            Database.addTransaction(
                amount,
                transactionType,
                selectedCategoryId,
                note,
                paymentMode,
                timestamp,
                goalId,
                null,
                false
            );
        }

        transactionSaved();
    }

    function deleteTransaction() {
        if (isEditing && editingTransaction) {
            Database.deleteTransaction(editingTransaction.id);
            transactionSaved();
        }
    }

    function loadTransaction(transaction) {
        editingTransaction = transaction;
        transactionType = transaction.type;
        amount = transaction.amount;
        note = transaction.note || "";
        selectedCategoryId = transaction.category_id;
        selectedGoalId = transaction.goal_id || -1;
        paymentMode = transaction.payment_mode || "";
        selectedDate = new Date(transaction.timestamp);
        amountInput.text = amount.toString();
        noteInput.text = note;
    }

    Component.onCompleted: {
        var settings = Database.getUserSettings();
        if (settings) {
            currencyCode = settings.currency || "INR";
        }
    }
}
