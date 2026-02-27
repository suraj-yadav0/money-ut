import QtQuick 2.7
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3
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
        contentHeight: contentColumn.height + Theme.spacing3XL
        clip: true

        ColumnLayout {
            id: contentColumn
            width: parent.width - Theme.spacingLG * 2
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.spacingLG

            Item { Layout.preferredHeight: Theme.spacingSM }

            // Type toggle
            Rectangle {
                Layout.fillWidth: true
                height: 56
                radius: Theme.radiusLG
                color: transactionType === "expense" ?
                       Qt.rgba(Theme.expense.r, Theme.expense.g, Theme.expense.b, 0.15) :
                       Qt.rgba(Theme.income.r, Theme.income.g, Theme.income.b, 0.15)

                Behavior on color {
                    ColorAnimation { duration: Theme.animationNormal }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 4
                    spacing: 4

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: Theme.radiusMD
                        color: transactionType === "expense" ? Theme.expense : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "Expense"
                            font.pixelSize: Theme.fontSizeMD
                            font.weight: transactionType === "expense" ? Font.SemiBold : Font.Normal
                            color: transactionType === "expense" ? Theme.white : Theme.gray600
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                transactionType = "expense";
                                selectedCategoryId = -1;
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: Theme.radiusMD
                        color: transactionType === "income" ? Theme.income : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "Income"
                            font.pixelSize: Theme.fontSizeMD
                            font.weight: transactionType === "income" ? Font.SemiBold : Font.Normal
                            color: transactionType === "income" ? Theme.white : Theme.gray600
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                transactionType = "income";
                                selectedCategoryId = -1;
                                selectedGoalId = -1;
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
                    spacing: Theme.spacingSM

                    Text {
                        text: Theme.getCurrencySymbol(currencyCode)
                        font.pixelSize: Theme.fontSize3XL
                        font.weight: Font.Bold
                        color: Theme.gray400
                    }

                    TextField {
                        id: amountInput
                        Layout.fillWidth: true
                        font.pixelSize: Theme.fontSize2XL
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

            // Auto-categorization timer
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
            Text {
                text: "Category"
                font.pixelSize: Theme.fontSizeMD
                font.weight: Font.SemiBold
                color: Theme.gray700
            }

            Flow {
                Layout.fillWidth: true
                spacing: Theme.spacingSM

                Repeater {
                    model: Database.getCategories(transactionType)

                    CategoryChip {
                        text: getCategoryEmoji(modelData.icon) + " " + modelData.name
                        selected: selectedCategoryId === modelData.id
                        onClicked: selectedCategoryId = modelData.id
                    }
                }
            }

            // Goal linking (expense only)
            Text {
                text: "Link to Goal"
                font.pixelSize: Theme.fontSizeMD
                font.weight: Font.SemiBold
                color: Theme.gray700
                visible: transactionType === "expense"
            }

            Column {
                Layout.fillWidth: true
                spacing: Theme.spacingSM
                visible: transactionType === "expense"

                Repeater {
                    model: Database.getGoals(true)

                    Rectangle {
                        width: parent.width
                        height: 60
                        radius: Theme.radiusMD
                        border.width: selectedGoalId === modelData.id ? 2 : 1
                        border.color: selectedGoalId === modelData.id ? Theme.primary : Theme.gray200
                        color: selectedGoalId === modelData.id ?
                               Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1) : Theme.white

                        RowLayout {
                            anchors {
                                fill: parent
                                margins: Theme.spacingSM
                            }
                            spacing: Theme.spacingSM

                            Text {
                                text: "🎯"
                                font.pixelSize: 20
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0

                                Text {
                                    text: modelData.name
                                    font.pixelSize: Theme.fontSizeMD
                                    color: Theme.gray900
                                }

                                ProgressBar {
                                    Layout.fillWidth: true
                                    barHeight: 4
                                    value: modelData.saved_amount
                                    maxValue: modelData.target_amount
                                    barColor: Theme.primary
                                }
                            }

                            Text {
                                text: Math.round(modelData.percentComplete) + "%"
                                font.pixelSize: Theme.fontSizeSM
                                color: Theme.gray500
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (selectedGoalId === modelData.id) {
                                    selectedGoalId = -1;
                                } else {
                                    selectedGoalId = modelData.id;
                                }
                            }
                        }
                    }
                }
            }

            // Payment mode
            Text {
                text: "Payment Mode"
                font.pixelSize: Theme.fontSizeMD
                font.weight: Font.SemiBold
                color: Theme.gray700
            }

            Flow {
                Layout.fillWidth: true
                spacing: Theme.spacingSM

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
            Text {
                text: "Date"
                font.pixelSize: Theme.fontSizeMD
                font.weight: Font.SemiBold
                color: Theme.gray700
            }

            GlassCard {
                Layout.fillWidth: true

                RowLayout {
                    spacing: Theme.spacingSM

                    Text {
                        text: "📅"
                        font.pixelSize: 20
                    }

                    Text {
                        text: Qt.formatDate(selectedDate, "dddd, MMMM d, yyyy")
                        font.pixelSize: Theme.fontSizeMD
                        color: Theme.gray900
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "Change"
                        font.pixelSize: Theme.fontSizeSM
                        color: Theme.primary

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: showDatePicker = true
                        }
                    }
                }
            }

            // Save button
            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: Theme.spacingLG
                height: 56
                radius: Theme.radiusButton
                color: canSave() ? Theme.primary : Theme.gray300

                Text {
                    anchors.centerIn: parent
                    text: isEditing ? "Update Transaction" : "Add Transaction"
                    font.pixelSize: Theme.fontSizeLG
                    font.weight: Font.SemiBold
                    color: canSave() ? Theme.white : Theme.gray500
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: canSave() ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        if (canSave()) {
                            saveTransaction();
                        }
                    }
                }
            }

            // Delete button (edit mode only)
            Rectangle {
                Layout.fillWidth: true
                height: 56
                radius: Theme.radiusButton
                color: "transparent"
                border.width: 1
                border.color: Theme.expense
                visible: isEditing

                Text {
                    anchors.centerIn: parent
                    text: "Delete Transaction"
                    font.pixelSize: Theme.fontSizeLG
                    font.weight: Font.SemiBold
                    color: Theme.expense
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: deleteTransaction()
                }
            }

            Item { Layout.preferredHeight: Theme.spacing3XL }
        }
    }

    // Date picker dialog
    property bool showDatePicker: false

    Rectangle {
        id: datePickerOverlay
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.5)
        visible: showDatePicker
        opacity: showDatePicker ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: Theme.animationNormal }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: showDatePicker = false
        }

        Rectangle {
            anchors.centerIn: parent
            width: parent.width * 0.9
            height: 400
            radius: Theme.radiusXL
            color: Theme.white

            ColumnLayout {
                anchors {
                    fill: parent
                    margins: Theme.spacingLG
                }
                spacing: Theme.spacingMD

                Text {
                    text: "Select Date"
                    font.pixelSize: Theme.fontSizeXL
                    font.weight: Font.Bold
                    color: Theme.gray900
                }

                // Simple date input
                TextField {
                    id: dateInput
                    Layout.fillWidth: true
                    text: Qt.formatDate(selectedDate, "yyyy-MM-dd")
                    placeholderText: "YYYY-MM-DD"
                }

                // Quick date buttons
                Flow {
                    Layout.fillWidth: true
                    spacing: Theme.spacingSM

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

                Item { Layout.fillHeight: true }

                Rectangle {
                    Layout.fillWidth: true
                    height: 48
                    radius: Theme.radiusButton
                    color: Theme.primary

                    Text {
                        anchors.centerIn: parent
                        text: "Confirm"
                        font.pixelSize: Theme.fontSizeMD
                        font.weight: Font.SemiBold
                        color: Theme.white
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            selectedDate = new Date(dateInput.text);
                            showDatePicker = false;
                        }
                    }
                }
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
                null // receipt path
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
                null, // receipt path
                false // is recurring
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

    function getCategoryEmoji(icon) {
        var emojiMap = {
            "restaurant": "🍽️", "directions_car": "🚗", "shopping_bag": "🛍️",
            "movie": "🎬", "receipt_long": "📄", "local_hospital": "🏥",
            "school": "🎓", "spa": "💆", "local_grocery_store": "🛒",
            "card_giftcard": "🎁", "savings": "💰", "show_chart": "📊",
            "family_restroom": "👨‍👩‍👧", "more_horiz": "⋯", "work": "💼",
            "laptop": "💻", "trending_up": "📈", "attach_money": "💵"
        };
        return emojiMap[icon] || "📝";
    }

    Component.onCompleted: {
        var settings = Database.getUserSettings();
        if (settings) {
            currencyCode = settings.currency || "INR";
        }
    }
}
