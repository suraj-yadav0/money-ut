import QtQuick 2.7
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3
import ".."
import "../components"

Page {
    id: calendarPage

    property string currencyCode: "INR"
    property int currentMonth: new Date().getMonth() + 1
    property int currentYear: new Date().getFullYear()
    property var calendarData: ({})
    property var monthTotals: ({ income: 0, expenses: 0, net: 0 })

    signal daySelected(date selectedDate)

    header: PageHeader {
        id: header
        title: Theme.formatMonthYear(new Date(currentYear, currentMonth - 1, 1))

        leadingActionBar.actions: [
            Action {
                iconName: "back"
                text: "Back"
                onTriggered: pageStack.pop()
            }
        ]

        trailingActionBar.actions: [
            Action {
                iconName: "go-previous"
                text: "Previous"
                onTriggered: previousMonth()
            },
            Action {
                iconName: "go-next"
                text: "Next"
                onTriggered: nextMonth()
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

            // Month totals card
            GlassCard {
                Layout.fillWidth: true

                RowLayout {
                    spacing: units.gu(1.5)

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: units.dp(2)

                        Label {
                            text: "Income"
                            fontSize: "x-small"
                            color: Theme.gray500
                        }

                        Label {
                            text: Theme.formatCurrency(monthTotals.income, currencyCode)
                            fontSize: "medium"
                            font.weight: Font.DemiBold
                            color: Theme.income
                        }
                    }

                    Rectangle { width: units.dp(1); height: units.gu(4); color: Theme.gray200 }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: units.dp(2)

                        Label {
                            text: "Expenses"
                            fontSize: "x-small"
                            color: Theme.gray500
                        }

                        Label {
                            text: Theme.formatCurrency(monthTotals.expenses, currencyCode)
                            fontSize: "medium"
                            font.weight: Font.DemiBold
                            color: Theme.expense
                        }
                    }

                    Rectangle { width: units.dp(1); height: units.gu(4); color: Theme.gray200 }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: units.dp(2)

                        Label {
                            text: "Net"
                            fontSize: "x-small"
                            color: Theme.gray500
                        }

                        Label {
                            text: Theme.formatCurrency(monthTotals.net, currencyCode)
                            fontSize: "medium"
                            font.weight: Font.DemiBold
                            color: monthTotals.net >= 0 ? Theme.income : Theme.expense
                        }
                    }
                }
            }

            // Calendar header (day names)
            Row {
                Layout.fillWidth: true
                spacing: 0

                Repeater {
                    model: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

                    Label {
                        width: (parent.width) / 7
                        text: modelData
                        fontSize: "small"
                        font.weight: Font.DemiBold
                        color: index === 0 ? Theme.expense : (index === 6 ? Theme.income : Theme.gray600)
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            // Calendar grid
            Grid {
                Layout.fillWidth: true
                columns: 7
                spacing: units.dp(2)

                Repeater {
                    model: getCalendarDays()

                    Rectangle {
                        width: (parent.width - units.dp(12)) / 7
                        height: units.gu(8)
                        radius: units.gu(1)
                        color: modelData.isToday ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.15) :
                               modelData.isCurrentMonth ? Theme.white : Theme.gray50

                        border.width: modelData.isToday ? units.dp(2) : 0
                        border.color: Theme.primary

                        ColumnLayout {
                            anchors {
                                fill: parent
                                margins: units.dp(4)
                            }
                            spacing: units.dp(2)

                            Label {
                                text: modelData.day
                                fontSize: "small"
                                font.weight: modelData.isToday ? Font.Bold : Font.Normal
                                color: !modelData.isCurrentMonth ? Theme.gray400 :
                                       modelData.dayOfWeek === 0 ? Theme.expense :
                                       modelData.dayOfWeek === 6 ? Theme.income :
                                       Theme.gray900
                                Layout.alignment: Qt.AlignHCenter
                            }

                            // Income
                            Label {
                                text: modelData.income > 0 ? "+" + Theme.formatCompactCurrency(modelData.income, currencyCode) : ""
                                fontSize: "xx-small"
                                color: Theme.income
                                Layout.alignment: Qt.AlignHCenter
                                visible: modelData.income > 0
                            }

                            // Expense
                            Label {
                                text: modelData.expense > 0 ? "-" + Theme.formatCompactCurrency(modelData.expense, currencyCode) : ""
                                fontSize: "xx-small"
                                color: Theme.expense
                                Layout.alignment: Qt.AlignHCenter
                                visible: modelData.expense > 0
                            }

                            Item { Layout.fillHeight: true }
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: modelData.isCurrentMonth
                            onClicked: {
                                if (modelData.isCurrentMonth) {
                                    daySelected(new Date(currentYear, currentMonth - 1, modelData.day));
                                }
                            }
                        }
                    }
                }
            }

            Item { Layout.preferredHeight: units.gu(3) }
        }
    }

    function previousMonth() {
        if (currentMonth === 1) {
            currentMonth = 12;
            currentYear--;
        } else {
            currentMonth--;
        }
        refreshData();
    }

    function nextMonth() {
        if (currentMonth === 12) {
            currentMonth = 1;
            currentYear++;
        } else {
            currentMonth++;
        }
        refreshData();
    }

    function getCalendarDays() {
        var days = [];
        var firstDay = new Date(currentYear, currentMonth - 1, 1);
        var lastDay = new Date(currentYear, currentMonth, 0);
        var startDayOfWeek = firstDay.getDay();
        var daysInMonth = lastDay.getDate();

        var today = new Date();
        var isCurrentMonthNow = today.getMonth() + 1 === currentMonth && today.getFullYear() === currentYear;

        // Previous month days
        var prevMonthLastDay = new Date(currentYear, currentMonth - 1, 0).getDate();
        for (var i = startDayOfWeek - 1; i >= 0; i--) {
            days.push({
                day: prevMonthLastDay - i,
                isCurrentMonth: false,
                isToday: false,
                dayOfWeek: startDayOfWeek - 1 - i,
                income: 0,
                expense: 0
            });
        }

        // Current month days
        for (var d = 1; d <= daysInMonth; d++) {
            var dateKey = currentYear + "-" + String(currentMonth).padStart(2, '0') + "-" + String(d).padStart(2, '0');
            var dayData = calendarData[dateKey] || { income: 0, expense: 0 };

            days.push({
                day: d,
                isCurrentMonth: true,
                isToday: isCurrentMonthNow && d === today.getDate(),
                dayOfWeek: (startDayOfWeek + d - 1) % 7,
                income: dayData.income,
                expense: dayData.expense
            });
        }

        // Next month days (fill to complete 6 rows = 42 cells)
        var remaining = 42 - days.length;
        for (var n = 1; n <= remaining; n++) {
            days.push({
                day: n,
                isCurrentMonth: false,
                isToday: false,
                dayOfWeek: (days.length) % 7,
                income: 0,
                expense: 0
            });
        }

        return days;
    }

    function refreshData() {
        var settings = Database.getUserSettings();
        if (settings) {
            currencyCode = settings.currency || "INR";
        }

        calendarData = Database.getCalendarData(currentMonth, currentYear);
        monthTotals = Database.getMonthTotals(currentMonth, currentYear);
    }

    Component.onCompleted: {
        refreshData();
    }
}
