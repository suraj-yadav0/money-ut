import QtQuick 2.7
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3
import ".."
import "../components"

Page {
    id: dashboardPage

    property string currencyCode: "INR"
    property var settings: null
    property var stats: null
    property string selectedFilter: "thisMonth"
    property string chartType: "pie"  // pie, bar, trend
    property string dataMode: "expense"  // expense, income

    signal openCalendar()
    signal openSettings()
    signal openInsights()
    signal openAllTransactions()
    signal openAddTransaction()
    signal editTransaction(var transaction)

    header: PageHeader {
        id: header
        title: "Quantro"

        trailingActionBar.actions: [
            Action {
                iconName: "notification"
                text: "Insights"
                onTriggered: openInsights()
            },
            Action {
                iconName: "settings"
                text: "Settings"
                onTriggered: openSettings()
            },
            Action {
                iconName: "calendar"
                text: "Calendar"
                onTriggered: openCalendar()
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
        id: scrollView
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
            spacing: Theme.spacingLG

            Item { Layout.preferredHeight: Theme.spacingSM }

            // Date filter bar
            DateFilterBar {
                id: dateFilter
                Layout.fillWidth: true
                selectedFilter: dashboardPage.selectedFilter

                onFilterChanged: {
                    dashboardPage.selectedFilter = filterKey;
                    refreshData();
                }
            }

            // Balance card
            BalanceCard {
                id: balanceCard
                Layout.fillWidth: true
                totalIncome: stats ? stats.totalIncome : 0
                totalExpenses: stats ? stats.totalExpenses : 0
                currencyCode: dashboardPage.currencyCode
            }

            // Expense/Income toggle
            SegmentedButton {
                id: dataModeToggle
                Layout.alignment: Qt.AlignHCenter
                segments: [
                    { key: "expense", label: "Expenses" },
                    { key: "income", label: "Income" }
                ]
                selectedKey: dataMode
                activeColor: dataMode === "expense" ? Theme.expense : Theme.income

                onSelectionChanged: {
                    dataMode = key;
                }
            }

            // Chart type toggle
            SegmentedButton {
                id: chartTypeToggle
                Layout.alignment: Qt.AlignHCenter
                segments: [
                    { key: "pie", label: "Pie" },
                    { key: "bar", label: "Bar" },
                    { key: "trend", label: "Trend" }
                ]
                selectedKey: chartType

                onSelectionChanged: {
                    chartType = key;
                }
            }

            // Chart container
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 260
                color: Qt.rgba(1, 1, 1, 0.7)
                radius: Theme.radiusLG

                // Pie chart
                PieChart {
                    anchors.centerIn: parent
                    visible: chartType === "pie"
                    width: parent.width - Theme.spacingLG * 2
                    data: getChartData()
                }

                // Bar chart
                Flickable {
                    anchors.fill: parent
                    anchors.margins: Theme.spacingSM
                    visible: chartType === "bar"
                    contentWidth: barChart.width
                    clip: true

                    BarChart {
                        id: barChart
                        height: parent.height - Theme.spacingMD
                        data: getChartData()
                        currencyCode: dashboardPage.currencyCode
                    }
                }

                // Line chart
                Flickable {
                    anchors.fill: parent
                    anchors.margins: Theme.spacingSM
                    visible: chartType === "trend"
                    contentWidth: lineChart.width
                    clip: true

                    LineChart {
                        id: lineChart
                        height: parent.height - Theme.spacingMD
                        data: getTrendData()
                        currencyCode: dashboardPage.currencyCode
                        lineColor: dataMode === "expense" ? Theme.expense : Theme.income
                    }
                }

                // Empty state
                EmptyState {
                    anchors.centerIn: parent
                    visible: (!stats || stats.categoryBreakdown.length === 0) && chartType !== "trend"
                    emoji: "📊"
                    title: "No Data Yet"
                    subtitle: "Add some transactions to see your charts"
                }
            }

            // Recent Transactions header
            RowLayout {
                Layout.fillWidth: true

                Label {
                    text: "Recent Transactions"
                    font.pixelSize: Theme.fontSizeLG
                    font.weight: Font.DemiBold
                    color: Theme.gray900
                }

                Item { Layout.fillWidth: true }

                AbstractButton {
                    width: seeAllLabel.width
                    height: seeAllLabel.height
                    onClicked: openAllTransactions()

                    Label {
                        id: seeAllLabel
                        text: "See All →"
                        font.pixelSize: Theme.fontSizeMD
                        color: Theme.primary
                    }
                }
            }

            // Recent transactions list
            GlassCard {
                Layout.fillWidth: true
                implicitHeight: recentList.height + Theme.spacingLG * 2
                visible: recentTransactions.length > 0

                Column {
                    id: recentList
                    width: parent.width
                    spacing: 1

                    Repeater {
                        model: recentTransactions

                        TransactionItem {
                            width: parent.width
                            transaction: modelData
                            currencyCode: dashboardPage.currencyCode

                            onEditRequested: editTransaction(modelData)
                            onDeleteRequested: {
                                Database.deleteTransaction(modelData.id);
                                refreshData();
                            }
                        }
                    }
                }
            }

            // Empty state for transactions
            EmptyState {
                Layout.fillWidth: true
                Layout.topMargin: Theme.spacing2XL
                visible: recentTransactions.length === 0
                emoji: "💸"
                title: "No Transactions Yet"
                subtitle: "Tap the + button to add your first transaction"
                actionText: "Add Transaction"
                onActionClicked: openAddTransaction()
            }

            Item { Layout.preferredHeight: Theme.spacing3XL }
        }
    }

    property var recentTransactions: []

    function refreshData() {
        settings = Database.getUserSettings();
        if (settings) {
            currencyCode = settings.currency || "INR";
        }

        var dateRange = dateFilter.getDateRange();
        stats = Database.getDashboardStats(dateRange.startDate, dateRange.endDate);
        recentTransactions = Database.getRecentTransactions(5);
    }

    function getChartData() {
        if (!stats || !stats.categoryBreakdown) return [];

        var filtered = stats.categoryBreakdown.filter(function(item) {
            return item.amount > 0;
        });

        // Limit to top 5 for readability
        var top5 = filtered.slice(0, 5);

        return top5.map(function(item, index) {
            return {
                label: item.categoryName,
                value: item.amount,
                percentage: item.percentage,
                color: Theme.chartColors[index % Theme.chartColors.length]
            };
        });
    }

    function getTrendData() {
        if (!stats || !stats.dailyData) return [];

        return stats.dailyData.map(function(item) {
            return {
                date: item.date,
                label: Qt.formatDate(new Date(item.date), "MMM d"),
                value: dataMode === "expense" ? item.expense : item.income
            };
        });
    }

    Component.onCompleted: {
        refreshData();
    }
}
