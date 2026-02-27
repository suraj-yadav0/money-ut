import QtQuick 2.7
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3
import ".."
import "../components"

Page {
    id: budgetPage

    property string currencyCode: "INR"
    property var budgetStats: null
    property int currentMonth: new Date().getMonth() + 1
    property int currentYear: new Date().getFullYear()

    header: PageHeader {
        id: header
        title: "Budget"
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

            // Budget summary card
            GlassCard {
                Layout.fillWidth: true
                visible: budgetStats && budgetStats.totalBudget > 0

                ColumnLayout {
                    spacing: Theme.spacingMD

                    RowLayout {
                        Layout.fillWidth: true

                        // Status icon
                        Rectangle {
                            width: 44
                            height: 44
                            radius: 22
                            color: Qt.rgba(getBudgetStatusColor().r, getBudgetStatusColor().g, getBudgetStatusColor().b, 0.15)

                            Text {
                                anchors.centerIn: parent
                                text: getBudgetStatusIcon()
                                font.pixelSize: 20
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: Theme.formatCurrency(budgetStats ? budgetStats.totalSpent : 0, currencyCode) + " spent"
                                font.pixelSize: Theme.fontSizeLG
                                font.weight: Font.SemiBold
                                color: Theme.gray900
                            }

                            Text {
                                text: "of " + Theme.formatCurrency(budgetStats ? budgetStats.totalBudget : 0, currencyCode) + " budget"
                                font.pixelSize: Theme.fontSizeSM
                                color: Theme.gray500
                            }
                        }
                    }

                    // Progress bar
                    ProgressBar {
                        Layout.fillWidth: true
                        barHeight: 12
                        value: budgetStats ? budgetStats.percentUsed : 0
                        barColor: getBudgetStatusColor()
                    }

                    // Stats row
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacingMD

                        // Remaining
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: "Remaining"
                                font.pixelSize: Theme.fontSizeXS
                                color: Theme.gray500
                            }

                            Text {
                                text: Theme.formatCurrency(budgetStats ? budgetStats.totalRemaining : 0, currencyCode)
                                font.pixelSize: Theme.fontSizeMD
                                font.weight: Font.SemiBold
                                color: (budgetStats && budgetStats.totalRemaining >= 0) ? Theme.income : Theme.expense
                            }
                        }

                        Rectangle { width: 1; height: 30; color: Theme.gray200 }

                        // Daily limit
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: "Daily Limit"
                                font.pixelSize: Theme.fontSizeXS
                                color: Theme.gray500
                            }

                            Text {
                                property int daysLeft: getDaysLeftInMonth()
                                text: Theme.formatCurrency(budgetStats && daysLeft > 0 ? budgetStats.totalRemaining / daysLeft : 0, currencyCode)
                                font.pixelSize: Theme.fontSizeMD
                                font.weight: Font.SemiBold
                                color: Theme.gray900
                            }
                        }

                        Rectangle { width: 1; height: 30; color: Theme.gray200 }

                        // Days left
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: "Days Left"
                                font.pixelSize: Theme.fontSizeXS
                                color: Theme.gray500
                            }

                            Text {
                                text: getDaysLeftInMonth()
                                font.pixelSize: Theme.fontSizeMD
                                font.weight: Font.SemiBold
                                color: Theme.gray900
                            }
                        }
                    }
                }
            }

            // Category budgets header
            Text {
                text: "Category Budgets"
                font.pixelSize: Theme.fontSizeLG
                font.weight: Font.SemiBold
                color: Theme.gray900
                visible: budgetStats && budgetStats.categories.length > 0
            }

            // Category budget cards
            Repeater {
                model: budgetStats ? budgetStats.categories : []

                GlassCard {
                    Layout.fillWidth: true

                    ColumnLayout {
                        spacing: Theme.spacingSM

                        RowLayout {
                            Layout.fillWidth: true

                            // Category icon
                            Rectangle {
                                width: 36
                                height: 36
                                radius: 18
                                color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.15)

                                Text {
                                    anchors.centerIn: parent
                                    text: getCategoryEmoji(modelData.categoryIcon)
                                    font.pixelSize: 16
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0

                                Text {
                                    text: modelData.categoryName
                                    font.pixelSize: Theme.fontSizeMD
                                    font.weight: Font.SemiBold
                                    color: Theme.gray900
                                }

                                Text {
                                    text: Theme.formatCurrency(modelData.spent, currencyCode) + " / " + Theme.formatCurrency(modelData.budget, currencyCode)
                                    font.pixelSize: Theme.fontSizeSM
                                    color: Theme.gray500
                                }
                            }

                            Text {
                                text: Math.round(modelData.percentUsed * 100) + "%"
                                font.pixelSize: Theme.fontSizeMD
                                font.weight: Font.Bold
                                color: Theme.getBudgetColor(modelData.percentUsed)
                            }
                        }

                        ProgressBar {
                            Layout.fillWidth: true
                            barHeight: 6
                            value: modelData.percentUsed
                            barColor: Theme.getBudgetColor(modelData.percentUsed)
                        }
                    }
                }
            }

            // Empty state
            EmptyState {
                Layout.fillWidth: true
                Layout.topMargin: Theme.spacing3XL
                visible: !budgetStats || budgetStats.categories.length === 0
                emoji: "💰"
                title: "No Budgets Set"
                subtitle: "Set budgets for your categories to track spending"
                actionText: "Set Budget"
                onActionClicked: openBudgetSettings()
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
            text: "⚙️"
            font.pixelSize: 24
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: openBudgetSettings()
        }
    }

    // Budget settings dialog
    property bool showBudgetSettings: false

    Rectangle {
        id: budgetSettingsOverlay
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.5)
        visible: showBudgetSettings
        opacity: showBudgetSettings ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: Theme.animationNormal }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: showBudgetSettings = false
        }

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: parent.height * 0.7
            radius: Theme.radiusXL
            color: Theme.white

            ColumnLayout {
                anchors {
                    fill: parent
                    margins: Theme.spacingLG
                }
                spacing: Theme.spacingMD

                // Header
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Set Budgets"
                        font.pixelSize: Theme.fontSizeXL
                        font.weight: Font.Bold
                        color: Theme.gray900
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: "✕"
                        font.pixelSize: 20
                        color: Theme.gray500

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: showBudgetSettings = false
                        }
                    }
                }

                // Categories list
                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentHeight: categoriesList.height
                    clip: true

                    Column {
                        id: categoriesList
                        width: parent.width
                        spacing: Theme.spacingSM

                        Repeater {
                            model: Database.getCategories("expense")

                            Rectangle {
                                width: parent.width
                                height: 60
                                radius: Theme.radiusMD
                                color: budgetInput.activeFocus ? Theme.gray50 : "transparent"

                                RowLayout {
                                    anchors {
                                        fill: parent
                                        margins: Theme.spacingSM
                                    }
                                    spacing: Theme.spacingSM

                                    Text {
                                        text: getCategoryEmoji(modelData.icon)
                                        font.pixelSize: 20
                                    }

                                    Text {
                                        text: modelData.name
                                        font.pixelSize: Theme.fontSizeMD
                                        color: Theme.gray900
                                        Layout.fillWidth: true
                                    }

                                    TextField {
                                        id: budgetInput
                                        Layout.preferredWidth: 100
                                        placeholderText: modelData.monthly_budget ? modelData.monthly_budget.toString() : "No budget"
                                        text: modelData.monthly_budget ? modelData.monthly_budget.toString() : ""
                                        inputMethodHints: Qt.ImhDigitsOnly

                                        onAccepted: {
                                            var value = parseFloat(text);
                                            if (value > 0) {
                                                Database.updateCategoryBudget(modelData.id, value);
                                            } else {
                                                Database.clearCategoryBudget(modelData.id);
                                            }
                                            refreshData();
                                        }

                                        onFocusChanged: {
                                            if (!focus && text !== "") {
                                                var value = parseFloat(text);
                                                if (value > 0) {
                                                    Database.updateCategoryBudget(modelData.id, value);
                                                } else {
                                                    Database.clearCategoryBudget(modelData.id);
                                                }
                                                refreshData();
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function openBudgetSettings() {
        showBudgetSettings = true;
    }

    function refreshData() {
        var settings = Database.getUserSettings();
        if (settings) {
            currencyCode = settings.currency || "INR";
        }
        budgetStats = Database.getBudgetStats(currentMonth, currentYear);
    }

    function getDaysLeftInMonth() {
        var now = new Date();
        var lastDay = new Date(currentYear, currentMonth, 0).getDate();
        return lastDay - now.getDate() + 1;
    }

    function getBudgetStatusColor() {
        if (!budgetStats) return Theme.primary;
        return Theme.getBudgetColor(budgetStats.percentUsed);
    }

    function getBudgetStatusIcon() {
        if (!budgetStats) return "✓";
        if (budgetStats.percentUsed >= 1) return "⚠️";
        if (budgetStats.percentUsed >= 0.8) return "⚡";
        return "✓";
    }

    function getCategoryEmoji(icon) {
        var emojiMap = {
            "restaurant": "🍽️", "directions_car": "🚗", "shopping_bag": "🛍️",
            "movie": "🎬", "receipt_long": "📄", "local_hospital": "🏥",
            "school": "🎓", "spa": "💆", "local_grocery_store": "🛒",
            "card_giftcard": "🎁", "savings": "💰", "show_chart": "📊",
            "family_restroom": "👨‍👩‍👧", "more_horiz": "⋯"
        };
        return emojiMap[icon] || "📝";
    }

    Component.onCompleted: {
        refreshData();
    }
}
