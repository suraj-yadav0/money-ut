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
    property var currentSplitDetailPage: null

    // Convergent layout: side rail on wide/desktop, bottom nav on phone
    property bool isWideLayout: root.width >= units.gu(90)

    // Signal emitted when transaction data changes so active tabs can refresh
    signal transactionDataChanged()

    // Navigation helpers
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
                        case 4: splitPage.refreshData(); break;
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
                        topMargin: units.gu(2)
                    }
                    spacing: units.gu(0.5)

                    Repeater {
                        model: [
                            { icon: "home", label: "Home", tab: 0 },
                            { icon: "tag", label: "Budget", tab: 1 },
                            { icon: "view-grid-symbolic", label: "Worth", tab: 2 },
                            { icon: "starred", label: "Goals", tab: 3 },
                            { icon: "contact-group", label: "Split", tab: 4 }
                        ]

                        Item {
                            width: sideNavItems.width
                            height: units.gu(7)

                            Column {
                                anchors.centerIn: parent
                                spacing: units.dp(2)

                                Icon {
                                    width: units.gu(3)
                                    height: units.gu(3)
                                    name: modelData.icon
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    color: currentTab === modelData.tab ? Theme.primary : Theme.gray500
                                }

                                Label {
                                    text: modelData.label
                                    fontSize: "x-small"
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
                                radius: units.dp(2)
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: switchTab(modelData.tab)
                            }
                        }
                    }
                }

                // Add transaction button at bottom of side nav
                LomiriShape {
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        bottom: parent.bottom
                        bottomMargin: units.gu(3)
                    }
                    width: units.gu(6)
                    height: units.gu(6)
                    aspect: LomiriShape.Flat
                    radius: "large"
                    relativeRadius: 0.5
                    backgroundColor: Theme.primary

                    Icon {
                        anchors.centerIn: parent
                        width: units.gu(3)
                        height: units.gu(3)
                        name: "add"
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

                SplitPage {
                    id: splitPage
                    anchors.fill: parent
                    visible: currentTab === 4
                    onOpenGroupDetail: {
                        var pg = splitGroupDetailPageComponent.createObject(null);
                        pg.groupId = group.id;
                        pg.groupName = group.name;
                        pg.refreshData();
                        root.navigateTo(pg);
                    }
                }
            }

            // ---- FAB: Add Transaction (phone layout only) ----
            LomiriShape {
                id: fab
                visible: !root.isWideLayout
                z: 10
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: bottomNav.top
                    bottomMargin: -height / 2
                }
                width: units.gu(7)
                height: units.gu(7)
                aspect: LomiriShape.Flat
                radius: "large"
                relativeRadius: 0.5
                backgroundColor: Theme.primary

                Icon {
                    anchors.centerIn: parent
                    width: units.gu(3.5)
                    height: units.gu(3.5)
                    name: "add"
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
                    width: parent.width + units.gu(1)
                    height: parent.height + units.gu(1)
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
                height: units.gu(8)
                color: Theme.white

                Rectangle {
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                    }
                    height: units.dp(1)
                    color: Theme.gray200
                }

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: units.gu(1)
                        rightMargin: units.gu(1)
                    }
                    spacing: 0

                    // Home tab
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: units.dp(4)

                            Icon {
                                width: units.gu(3)
                                height: units.gu(3)
                                name: "home"
                                Layout.alignment: Qt.AlignHCenter
                                color: currentTab === 0 ? Theme.primary : Theme.gray500
                            }

                            Label {
                                text: "Home"
                                fontSize: "x-small"
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
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: units.dp(4)

                            Icon {
                                width: units.gu(3)
                                height: units.gu(3)
                                name: "tag"
                                Layout.alignment: Qt.AlignHCenter
                                color: currentTab === 1 ? Theme.primary : Theme.gray500
                            }

                            Label {
                                text: "Budget"
                                fontSize: "x-small"
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
                        Layout.preferredWidth: units.gu(8)
                        Layout.fillHeight: true
                    }

                    // Net Worth tab
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: units.dp(4)

                            Icon {
                                width: units.gu(3)
                                height: units.gu(3)
                                name: "view-grid-symbolic"
                                Layout.alignment: Qt.AlignHCenter
                                color: currentTab === 2 ? Theme.primary : Theme.gray500
                            }

                            Label {
                                text: "Worth"
                                fontSize: "x-small"
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
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: units.dp(4)

                            Icon {
                                width: units.gu(3)
                                height: units.gu(3)
                                name: "starred"
                                Layout.alignment: Qt.AlignHCenter
                                color: currentTab === 3 ? Theme.primary : Theme.gray500
                            }

                            Label {
                                text: "Goals"
                                fontSize: "x-small"
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

                    // Split tab
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: units.dp(4)

                            Icon {
                                width: units.gu(3)
                                height: units.gu(3)
                                name: "contact-group"
                                Layout.alignment: Qt.AlignHCenter
                                color: currentTab === 4 ? Theme.primary : Theme.gray500
                            }

                            Label {
                                text: "Split"
                                fontSize: "x-small"
                                color: currentTab === 4 ? Theme.primary : Theme.gray500
                                font.weight: currentTab === 4 ? Font.DemiBold : Font.Normal
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: switchTab(4)
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
                    case 4: splitPage.refreshData(); break;
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

    Component {
        id: splitGroupDetailPageComponent

        SplitGroupDetailPage {
            id: detailPg
            Component.onCompleted: root.currentSplitDetailPage = detailPg
            onAddExpenseRequested: {
                var pg = addSplitExpensePageComponent.createObject(null);
                pg.loadGroup(gid, mems);
                root.navigateTo(pg);
            }
        }
    }

    Component {
        id: addSplitExpensePageComponent

        AddSplitExpensePage {
            onExpenseSaved: {
                root.navigateBack();
                if (root.currentSplitDetailPage) {
                    root.currentSplitDetailPage.refreshData();
                }
            }
            onCancelled: {
                root.navigateBack();
            }
        }
    }
}
