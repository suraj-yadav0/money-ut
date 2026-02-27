import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import "."
import "pages"
import "components"

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'money-ut.surajyadav'
    automaticOrientation: true

    width: units.gu(45)
    height: units.gu(75)

    property bool isOnboarded: false
    property int currentTab: 0

    // Check onboarding status on start
    Component.onCompleted: {
        isOnboarded = Database.isOnboarded();
        Database.processRecurringTransactions();
    }

    PageStack {
        id: pageStack
        anchors.fill: parent

        Component.onCompleted: {
            if (isOnboarded) {
                push(appShell);
            } else {
                push(onboardingPage);
            }
        }
    }

    // Onboarding page component
    Component {
        id: onboardingPage

        OnboardingPage {
            onOnboardingComplete: {
                isOnboarded = true;
                pageStack.clear();
                pageStack.push(appShell);
            }
        }
    }

    // Main app shell component
    Component {
        id: appShell

        Page {
            id: mainShell

            header: PageHeader {
                visible: false
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

            // Tab content using Loader to preserve state
            Item {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    bottom: bottomNav.top
                }

                // Dashboard
                Loader {
                    id: dashboardLoader
                    anchors.fill: parent
                    active: true
                    visible: currentTab === 0
                    sourceComponent: DashboardPage {
                        onOpenCalendar: pageStack.push(calendarPageComponent)
                        onOpenSettings: pageStack.push(settingsPageComponent)
                        onOpenInsights: pageStack.push(insightsPageComponent)
                        onOpenAllTransactions: pageStack.push(allTransactionsPageComponent)
                        onOpenAddTransaction: pageStack.push(addTransactionPageComponent)
                        onEditTransaction: {
                            var page = addTransactionPageComponent.createObject(pageStack);
                            page.loadTransaction(transaction);
                            pageStack.push(page);
                        }
                    }
                }

                // Budget
                Loader {
                    id: budgetLoader
                    anchors.fill: parent
                    active: currentTab === 1
                    visible: currentTab === 1
                    sourceComponent: BudgetPage {}
                }

                // Net Worth
                Loader {
                    id: netWorthLoader
                    anchors.fill: parent
                    active: currentTab === 2
                    visible: currentTab === 2
                    sourceComponent: NetWorthPage {}
                }

                // Goals
                Loader {
                    id: goalsLoader
                    anchors.fill: parent
                    active: currentTab === 3
                    visible: currentTab === 3
                    sourceComponent: GoalsPage {}
                }
            }

            // Center FAB
            Rectangle {
                id: fab
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: bottomNav.top
                    bottomMargin: -height / 2
                }
                z: 10
                width: 56
                height: 56
                radius: 28
                color: Theme.primary

                gradient: Gradient {
                    GradientStop { position: 0.0; color: Theme.primary }
                    GradientStop { position: 1.0; color: Theme.primaryDark }
                }

                Text {
                    anchors.centerIn: parent
                    text: "+"
                    font.pixelSize: 32
                    font.weight: Font.Light
                    color: Theme.white
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: pageStack.push(addTransactionPageComponent)
                }

                // Shadow effect
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -4
                    z: -1
                    radius: 32
                    color: "transparent"
                    border.width: 0

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width
                        height: parent.height
                        radius: parent.width / 2
                        color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.3)
                        z: -1
                    }
                }
            }

            // Bottom navigation
            Rectangle {
                id: bottomNav
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                height: 70
                color: Theme.white

                Rectangle {
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                    }
                    height: 1
                    color: Theme.gray200
                }

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: Theme.spacingSM
                        rightMargin: Theme.spacingSM
                    }
                    spacing: 0

                    // Home tab
                    Item {
                        Layout.preferredWidth: (parent.width - 60) / 4
                        Layout.fillHeight: true

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 4

                            Text {
                                text: "🏠"
                                font.pixelSize: 22
                                Layout.alignment: Qt.AlignHCenter
                                opacity: currentTab === 0 ? 1 : 0.5
                            }

                            Text {
                                text: "Home"
                                font.pixelSize: Theme.fontSizeXS
                                color: currentTab === 0 ? Theme.primary : Theme.gray500
                                font.weight: currentTab === 0 ? Font.DemiBold : Font.Normal
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                currentTab = 0;
                                if (dashboardLoader.item) {
                                    dashboardLoader.item.refreshData();
                                }
                            }
                        }
                    }

                    // Budget tab
                    Item {
                        Layout.preferredWidth: (parent.width - 60) / 4
                        Layout.fillHeight: true

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 4

                            Text {
                                text: "💰"
                                font.pixelSize: 22
                                Layout.alignment: Qt.AlignHCenter
                                opacity: currentTab === 1 ? 1 : 0.5
                            }

                            Text {
                                text: "Budget"
                                font.pixelSize: Theme.fontSizeXS
                                color: currentTab === 1 ? Theme.primary : Theme.gray500
                                font.weight: currentTab === 1 ? Font.DemiBold : Font.Normal
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                currentTab = 1;
                                if (budgetLoader.item) {
                                    budgetLoader.item.refreshData();
                                }
                            }
                        }
                    }

                    // Center spacer for FAB
                    Item {
                        Layout.preferredWidth: 60
                        Layout.fillHeight: true
                    }

                    // Net Worth tab
                    Item {
                        Layout.preferredWidth: (parent.width - 60) / 4
                        Layout.fillHeight: true

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 4

                            Text {
                                text: "📊"
                                font.pixelSize: 22
                                Layout.alignment: Qt.AlignHCenter
                                opacity: currentTab === 2 ? 1 : 0.5
                            }

                            Text {
                                text: "Worth"
                                font.pixelSize: Theme.fontSizeXS
                                color: currentTab === 2 ? Theme.primary : Theme.gray500
                                font.weight: currentTab === 2 ? Font.DemiBold : Font.Normal
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                currentTab = 2;
                                if (netWorthLoader.item) {
                                    netWorthLoader.item.refreshData();
                                }
                            }
                        }
                    }

                    // Goals tab
                    Item {
                        Layout.preferredWidth: (parent.width - 60) / 4
                        Layout.fillHeight: true

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 4

                            Text {
                                text: "🎯"
                                font.pixelSize: 22
                                Layout.alignment: Qt.AlignHCenter
                                opacity: currentTab === 3 ? 1 : 0.5
                            }

                            Text {
                                text: "Goals"
                                font.pixelSize: Theme.fontSizeXS
                                color: currentTab === 3 ? Theme.primary : Theme.gray500
                                font.weight: currentTab === 3 ? Font.DemiBold : Font.Normal
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                currentTab = 3;
                                if (goalsLoader.item) {
                                    goalsLoader.item.refreshData();
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Page components for navigation
    Component {
        id: calendarPageComponent

        CalendarPage {
            onDaySelected: {
                var page = dayTransactionsPageComponent.createObject(pageStack);
                page.selectedDate = selectedDate;
                page.refreshData();
                pageStack.push(page);
            }
        }
    }

    Component {
        id: dayTransactionsPageComponent

        DayTransactionsPage {
            onEditTransaction: {
                var page = addTransactionPageComponent.createObject(pageStack);
                page.loadTransaction(transaction);
                pageStack.push(page);
            }
        }
    }

    Component {
        id: settingsPageComponent
        SettingsPage {}
    }

    Component {
        id: insightsPageComponent

        InsightsPage {
            onNavigateToBudget: {
                pageStack.pop();
                currentTab = 1;
            }
            onNavigateToTransactions: {
                pageStack.pop();
                pageStack.push(allTransactionsPageComponent);
            }
        }
    }

    Component {
        id: allTransactionsPageComponent

        AllTransactionsPage {
            onEditTransaction: {
                var page = addTransactionPageComponent.createObject(pageStack);
                page.loadTransaction(transaction);
                pageStack.push(page);
            }
        }
    }

    Component {
        id: addTransactionPageComponent

        AddTransactionPage {
            onTransactionSaved: {
                pageStack.pop();
                // Refresh dashboard if visible
                if (currentTab === 0 && dashboardLoader.item) {
                    dashboardLoader.item.refreshData();
                }
            }
            onCancelled: {
                pageStack.pop();
            }
        }
    }
}
