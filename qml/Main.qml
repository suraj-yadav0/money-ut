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

    // Convergent layout: side rail on wide/desktop, bottom nav on phone
    property bool isWideLayout: root.width >= units.gu(90)

    // Signal emitted when transaction data changes so active tabs can refresh
    signal transactionDataChanged()

    // Navigation helpers — avoids Lomiri Page.pageStack property shadowing
    // the PageStack id when pages are embedded rather than pushed.
    function navigateTo(page) { pageStack.push(page); }
    function navigateBack()   { pageStack.pop(); }

    Component.onCompleted: {
        Database.ensureInitialized();
        isOnboarded = Database.isOnboarded();
        Database.processRecurringTransactions();
    }

    PageStack {
        id: pageStack
        anchors.fill: parent

        Component.onCompleted: {
            if (root.isOnboarded) {
                push(appShell);
            } else {
                push(onboardingPage);
            }
        }
    }

    // ---- Onboarding ----
    Component {
        id: onboardingPage

        OnboardingPage {
            onOnboardingComplete: {
                root.isOnboarded = true;
                pageStack.clear();
                root.navigateTo(appShell);
            }
        }
    }

    // ---- Main App Shell (convergent layout) ----
    Component {
        id: appShell

        Page {
            id: mainShell

            header: PageHeader {
                visible: false
                height: 0
            }

            // Refresh the active tab when transaction data changes
            Connections {
                target: root
                onTransactionDataChanged: {
                    switch (currentTab) {
                        case 0: dashboardPage.refreshData(); break;
                        case 1: budgetPage.refreshData(); break;
                        case 2: netWorthPage.refreshData(); break;
                        case 3: goalsPage.refreshData(); break;
                    }
                }
            }

            // Background gradient
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Theme.lightBg1 }
                    GradientStop { position: 0.5; color: Theme.lightBg2 }
                    GradientStop { position: 1.0; color: Theme.lightBg3 }
                }
            }

            // ---- Convergent: Side navigation rail (wide/desktop screens) ----
            Rectangle {
                id: sideNav
                visible: root.isWideLayout
                z: 2
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: parent.left
                }
                width: units.gu(10)
                color: Theme.white

                // Right-edge separator
                Rectangle {
                    anchors {
                        top: parent.top
                        right: parent.right
                        bottom: parent.bottom
                    }
                    width: units.dp(1)
                    color: Theme.gray200
                }

                Column {
                    id: sideNavItems
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        topMargin: Theme.spacingLG
                    }
                    spacing: Theme.spacingXS

                    Repeater {
                        model: [
                            { emoji: "🏠", label: "Home", tab: 0 },
                            { emoji: "💰", label: "Budget", tab: 1 },
                            { emoji: "📊", label: "Worth", tab: 2 },
                            { emoji: "🎯", label: "Goals", tab: 3 }
                        ]

                        Item {
                            width: sideNavItems.width
                            height: units.gu(7)

                            Column {
                                anchors.centerIn: parent
                                spacing: 2

                                Text {
                                    text: modelData.emoji
                                    font.pixelSize: 24
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    opacity: currentTab === modelData.tab ? 1.0 : 0.5
                                }

                                Text {
                                    text: modelData.label
                                    font.pixelSize: Theme.fontSizeXS
                                    color: currentTab === modelData.tab ? Theme.primary : Theme.gray500
                                    font.weight: currentTab === modelData.tab ? Font.DemiBold : Font.Normal
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }

                            // Active tab indicator
                            Rectangle {
                                visible: currentTab === modelData.tab
                                anchors {
                                    left: parent.left
                                    top: parent.top
                                    bottom: parent.bottom
                                }
                                width: units.dp(3)
                                color: Theme.primary
                                radius: 2
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: switchTab(modelData.tab)
                            }
                        }
                    }
                }

                // Add transaction button at bottom of side nav
                Rectangle {
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        bottom: parent.bottom
                        bottomMargin: Theme.spacing2XL
                    }
                    width: 48
                    height: 48
                    radius: 24
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Theme.primary }
                        GradientStop { position: 1.0; color: Theme.primaryDark }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "+"
                        font.pixelSize: 28
                        font.weight: Font.Light
                        color: Theme.white
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.navigateTo(addTransactionPageComponent)
                    }
                }
            }

            // ---- Content area with direct page instances (no Loaders) ----
            Item {
                id: contentArea
                anchors {
                    top: parent.top
                    left: parent.left
                    leftMargin: root.isWideLayout ? units.gu(10) : 0
                    right: parent.right
                    bottom: parent.bottom
                    bottomMargin: root.isWideLayout ? 0 : bottomNav.height
                }

                DashboardPage {
                    id: dashboardPage
                    anchors.fill: parent
                    visible: currentTab === 0
                    onOpenCalendar: root.navigateTo(calendarPageComponent)
                    onOpenSettings: root.navigateTo(settingsPageComponent)
                    onOpenInsights: root.navigateTo(insightsPageComponent)
                    onOpenAllTransactions: root.navigateTo(allTransactionsPageComponent)
                    onOpenAddTransaction: root.navigateTo(addTransactionPageComponent)
                    onEditTransaction: {
                        var pg = addTransactionPageComponent.createObject(null);
                        pg.loadTransaction(transaction);
                        root.navigateTo(pg);
                    }
                }

                BudgetPage {
                    id: budgetPage
                    anchors.fill: parent
                    visible: currentTab === 1
                }

                NetWorthPage {
                    id: netWorthPage
                    anchors.fill: parent
                    visible: currentTab === 2
                }

                GoalsPage {
                    id: goalsPage
                    anchors.fill: parent
                    visible: currentTab === 3
                }
            }

            // ---- FAB: Add Transaction (phone layout only) ----
            Rectangle {
                id: fab
                visible: !root.isWideLayout
                z: 10
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: bottomNav.top
                    bottomMargin: -height / 2
                }
                width: 56
                height: 56
                radius: 28

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
                    onClicked: root.navigateTo(addTransactionPageComponent)
                }

                // Glow shadow
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width + 8
                    height: parent.height + 8
                    z: -1
                    radius: width / 2
                    color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.3)
                }
            }

            // ---- Bottom navigation (phone layout only) ----
            Rectangle {
                id: bottomNav
                visible: !root.isWideLayout
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
                            onClicked: switchTab(0)
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
                            onClicked: switchTab(1)
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
                            onClicked: switchTab(2)
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
                            onClicked: switchTab(3)
                        }
                    }
                }
            }

            // Tab switching with data refresh
            function switchTab(tab) {
                currentTab = tab;
                switch (tab) {
                    case 0: dashboardPage.refreshData(); break;
                    case 1: budgetPage.refreshData(); break;
                    case 2: netWorthPage.refreshData(); break;
                    case 3: goalsPage.refreshData(); break;
                }
            }
        }
    }

    // ---- Secondary page components for push navigation ----
    Component {
        id: calendarPageComponent

        CalendarPage {
            onDaySelected: {
                var pg = dayTransactionsPageComponent.createObject(null);
                pg.selectedDate = selectedDate;
                pg.refreshData();
                root.navigateTo(pg);
            }
        }
    }

    Component {
        id: dayTransactionsPageComponent

        DayTransactionsPage {
            onEditTransaction: {
                var pg = addTransactionPageComponent.createObject(null);
                pg.loadTransaction(transaction);
                root.navigateTo(pg);
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
                root.navigateBack();
                currentTab = 1;
            }
            onNavigateToTransactions: {
                root.navigateBack();
                root.navigateTo(allTransactionsPageComponent);
            }
        }
    }

    Component {
        id: allTransactionsPageComponent

        AllTransactionsPage {
            onEditTransaction: {
                var pg = addTransactionPageComponent.createObject(null);
                pg.loadTransaction(transaction);
                root.navigateTo(pg);
            }
        }
    }

    Component {
        id: addTransactionPageComponent

        AddTransactionPage {
            onTransactionSaved: {
                root.navigateBack();
                root.transactionDataChanged();
            }
            onCancelled: {
                root.navigateBack();
            }
        }
    }
}
