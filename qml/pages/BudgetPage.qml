import QtQuick 2.7
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
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

        trailingActionBar.actions: [
            Action {
                iconName: "settings"
                text: "Budget Settings"
                onTriggered: openBudgetSettings()
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

            // Budget summary card
            GlassCard {
                Layout.fillWidth: true
                visible: budgetStats && budgetStats.totalBudget > 0

                ColumnLayout {
                    spacing: units.gu(1.5)

                    RowLayout {
                        Layout.fillWidth: true

                        LomiriShape {
                            width: units.gu(5)
                            height: units.gu(5)
                            aspect: LomiriShape.Flat
                            radius: "large"
                            backgroundColor: Qt.rgba(getBudgetStatusColor().r, getBudgetStatusColor().g, getBudgetStatusColor().b, 0.15)

                            Label {
                                anchors.centerIn: parent
                                text: getBudgetStatusIcon()
                                font.pixelSize: units.gu(2.5)
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Label {
                                text: Theme.formatCurrency(budgetStats ? budgetStats.totalSpent : 0, currencyCode) + " spent"
                                fontSize: "large"
                                font.weight: Font.DemiBold
                                color: Theme.gray900
                            }

                            Label {
                                text: "of " + Theme.formatCurrency(budgetStats ? budgetStats.totalBudget : 0, currencyCode) + " budget"
                                fontSize: "small"
                                color: Theme.gray500
                            }
                        }
                    }

                    ProgressBar {
                        Layout.fillWidth: true
                        barHeight: units.gu(1.5)
                        value: budgetStats ? budgetStats.percentUsed : 0
                        barColor: getBudgetStatusColor()
                    }

                    // Stats row
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: units.gu(1.5)

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Label {
                                text: "Remaining"
                                fontSize: "x-small"
                                color: Theme.gray500
                            }

                            Label {
                                text: Theme.formatCurrency(budgetStats ? budgetStats.totalRemaining : 0, currencyCode)
                                fontSize: "medium"
                                font.weight: Font.DemiBold
                                color: (budgetStats && budgetStats.totalRemaining >= 0) ? Theme.income : Theme.expense
                            }
                        }

                        Rectangle { width: 1; height: units.gu(3); color: Theme.gray200 }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Label {
                                text: "Daily Limit"
                                fontSize: "x-small"
                                color: Theme.gray500
                            }

                            Label {
                                property int daysLeft: getDaysLeftInMonth()
                                text: Theme.formatCurrency(budgetStats && daysLeft > 0 ? budgetStats.totalRemaining / daysLeft : 0, currencyCode)
                                fontSize: "medium"
                                font.weight: Font.DemiBold
                                color: Theme.gray900
                            }
                        }

                        Rectangle { width: 1; height: units.gu(3); color: Theme.gray200 }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Label {
                                text: "Days Left"
                                fontSize: "x-small"
                                color: Theme.gray500
                            }

                            Label {
                                text: getDaysLeftInMonth()
                                fontSize: "medium"
                                font.weight: Font.DemiBold
                                color: Theme.gray900
                            }
                        }
                    }
                }
            }

            // Category budgets header
            Label {
                text: "Category Budgets"
                fontSize: "large"
                font.weight: Font.DemiBold
                color: Theme.gray900
                visible: budgetStats && budgetStats.categories.length > 0
            }

            // Category budget cards
            Repeater {
                model: budgetStats ? budgetStats.categories : []

                GlassCard {
                    Layout.fillWidth: true

                    ColumnLayout {
                        spacing: units.gu(1)

                        RowLayout {
                            Layout.fillWidth: true

                            LomiriShape {
                                width: units.gu(4)
                                height: units.gu(4)
                                aspect: LomiriShape.Flat
                                radius: "large"
                                backgroundColor: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.15)

                                Label {
                                    anchors.centerIn: parent
                                    text: getCategoryEmoji(modelData.categoryIcon)
                                    font.pixelSize: units.gu(2)
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0

                                Label {
                                    text: modelData.categoryName
                                    fontSize: "medium"
                                    font.weight: Font.DemiBold
                                    color: Theme.gray900
                                }

                                Label {
                                    text: Theme.formatCurrency(modelData.spent, currencyCode) + " / " + Theme.formatCurrency(modelData.budget, currencyCode)
                                    fontSize: "small"
                                    color: Theme.gray500
                                }
                            }

                            Label {
                                text: Math.round(modelData.percentUsed * 100) + "%"
                                fontSize: "medium"
                                font.weight: Font.Bold
                                color: Theme.getBudgetColor(modelData.percentUsed)
                            }
                        }

                        ProgressBar {
                            Layout.fillWidth: true
                            barHeight: units.gu(0.75)
                            value: modelData.percentUsed
                            barColor: Theme.getBudgetColor(modelData.percentUsed)
                        }
                    }
                }
            }

            // Empty state
            EmptyState {
                Layout.fillWidth: true
                Layout.topMargin: units.gu(4)
                visible: !budgetStats || budgetStats.categories.length === 0
                emoji: "💰"
                title: "No Budgets Set"
                subtitle: "Set budgets for your categories to track spending"
                actionText: "Set Budget"
                onActionClicked: openBudgetSettings()
            }

            Item { Layout.preferredHeight: units.gu(10) }
        }
    }

    // Budget settings dialog (bottom sheet style via Lomiri Dialog)
    Component {
        id: budgetSettingsDialogComponent

        Dialog {
            id: budgetSettingsDialog
            title: "Set Budgets"

            Flickable {
                width: parent.width
                height: units.gu(40)
                contentHeight: categoriesList.height
                clip: true

                Column {
                    id: categoriesList
                    width: parent.width
                    spacing: units.gu(1)

                    Repeater {
                        model: Database.getCategories("expense")

                        RowLayout {
                            width: parent.width
                            spacing: units.gu(1)

                            Label {
                                text: getCategoryEmoji(modelData.icon)
                                font.pixelSize: units.gu(2.5)
                            }

                            Label {
                                text: modelData.name
                                fontSize: "medium"
                                color: Theme.gray900
                                Layout.fillWidth: true
                            }

                            TextField {
                                id: budgetInput
                                Layout.preferredWidth: units.gu(12)
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
                                    budgetPage.refreshData();
                                }

                                onFocusChanged: {
                                    if (!focus && text !== "") {
                                        var value = parseFloat(text);
                                        if (value > 0) {
                                            Database.updateCategoryBudget(modelData.id, value);
                                        } else {
                                            Database.clearCategoryBudget(modelData.id);
                                        }
                                        budgetPage.refreshData();
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Button {
                text: "Done"
                color: Theme.primary
                onClicked: PopupUtils.close(budgetSettingsDialog)
            }
        }
    }

    function openBudgetSettings() {
        PopupUtils.open(budgetSettingsDialogComponent);
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
