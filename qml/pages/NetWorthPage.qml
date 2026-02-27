import QtQuick 2.7
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
import ".."
import "../components"

Page {
    id: netWorthPage

    property string currencyCode: "INR"
    property var netWorthData: null
    property var monthlyData: []
    property var assets: []
    property string assetFilter: "all"
    property var editingAsset: null

    header: PageHeader {
        id: header
        title: "Net Worth"

        trailingActionBar.actions: [
            Action {
                iconName: "add"
                text: "Add Asset"
                onTriggered: openAddAsset()
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

            // Net Worth Card
            GlassContainer {
                Layout.fillWidth: true
                height: units.gu(15)
                glassOpacity: 0.8
                backgroundColor: netWorthData && netWorthData.netWorth >= 0 ?
                    Qt.rgba(Theme.income.r, Theme.income.g, Theme.income.b, 0.15) :
                    Qt.rgba(Theme.expense.r, Theme.expense.g, Theme.expense.b, 0.15)
                secondaryBackgroundColor: Qt.rgba(1, 1, 1, 0.8)

                ColumnLayout {
                    anchors {
                        fill: parent
                        margins: units.gu(2)
                    }
                    spacing: units.gu(0.5)

                    Label {
                        text: "Total Net Worth"
                        fontSize: "medium"
                        color: Theme.gray500
                    }

                    Label {
                        text: Theme.formatFullCurrency(netWorthData ? netWorthData.netWorth : 0, currencyCode)
                        font.pixelSize: units.gu(4)
                        font.weight: Font.Bold
                        color: netWorthData && netWorthData.netWorth >= 0 ? Theme.income : Theme.expense
                    }
                }
            }

            // Breakdown row
            RowLayout {
                Layout.fillWidth: true
                spacing: units.gu(1)

                GlassCard {
                    Layout.fillWidth: true
                    implicitHeight: units.gu(8)

                    ColumnLayout {
                        spacing: 2

                        Label {
                            text: "Assets"
                            fontSize: "x-small"
                            color: Theme.gray500
                        }

                        Label {
                            text: Theme.formatCompactCurrency(netWorthData ? netWorthData.totalAssets : 0, currencyCode)
                            fontSize: "medium"
                            font.weight: Font.DemiBold
                            color: Theme.income
                        }
                    }
                }

                GlassCard {
                    Layout.fillWidth: true
                    implicitHeight: units.gu(8)

                    ColumnLayout {
                        spacing: 2

                        Label {
                            text: "Liabilities"
                            fontSize: "x-small"
                            color: Theme.gray500
                        }

                        Label {
                            text: Theme.formatCompactCurrency(netWorthData ? netWorthData.totalLiabilities : 0, currencyCode)
                            fontSize: "medium"
                            font.weight: Font.DemiBold
                            color: Theme.expense
                        }
                    }
                }

                GlassCard {
                    Layout.fillWidth: true
                    implicitHeight: units.gu(8)

                    ColumnLayout {
                        spacing: 2

                        Label {
                            text: "Goals"
                            fontSize: "x-small"
                            color: Theme.gray500
                        }

                        Label {
                            text: Theme.formatCompactCurrency(netWorthData ? netWorthData.goalSavings : 0, currencyCode)
                            fontSize: "medium"
                            font.weight: Font.DemiBold
                            color: Theme.primary
                        }
                    }
                }
            }

            // Asset type filter
            ListView {
                Layout.fillWidth: true
                height: units.gu(5)
                orientation: ListView.Horizontal
                spacing: units.gu(1)
                clip: true

                model: [
                    { key: "all", label: "All" },
                    { key: "savings", label: "Savings" },
                    { key: "investment", label: "Investment" },
                    { key: "property", label: "Property" },
                    { key: "gold", label: "Gold" },
                    { key: "loan", label: "Loan" },
                    { key: "other", label: "Other" }
                ]

                delegate: CategoryChip {
                    text: modelData.label
                    selected: assetFilter === modelData.key
                    onClicked: {
                        assetFilter = modelData.key;
                        loadAssets();
                    }
                }
            }

            // Assets header
            RowLayout {
                Layout.fillWidth: true
                visible: assets.length > 0

                Label {
                    text: "Your Assets"
                    fontSize: "large"
                    font.weight: Font.DemiBold
                    color: Theme.gray900
                }

                Item { Layout.fillWidth: true }

                Label {
                    text: assets.length + " items"
                    fontSize: "small"
                    color: Theme.gray500
                }
            }

            // Assets list
            Repeater {
                model: assets

                GlassCard {
                    Layout.fillWidth: true

                    RowLayout {
                        spacing: units.gu(1.5)

                        LomiriShape {
                            width: units.gu(5)
                            height: units.gu(5)
                            aspect: LomiriShape.Flat
                            radius: "large"
                            backgroundColor: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.15)

                            Icon {
                                anchors.centerIn: parent
                                width: units.gu(2.5)
                                height: units.gu(2.5)
                                name: getAssetIcon(modelData.type)
                                color: Theme.primary
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Label {
                                text: modelData.name
                                fontSize: "medium"
                                font.weight: Font.DemiBold
                                color: Theme.gray900
                            }

                            Row {
                                spacing: units.gu(1)

                                Label {
                                    text: getAssetTypeName(modelData.type)
                                    fontSize: "small"
                                    color: Theme.gray500
                                }

                                LomiriShape {
                                    visible: modelData.is_liability === 1
                                    width: liabilityLabel.width + units.gu(1)
                                    height: liabilityLabel.height + units.dp(4)
                                    aspect: LomiriShape.Flat
                                    radius: "small"
                                    backgroundColor: Qt.rgba(Theme.expense.r, Theme.expense.g, Theme.expense.b, 0.15)

                                    Label {
                                        id: liabilityLabel
                                        anchors.centerIn: parent
                                        text: "Liability"
                                        fontSize: "x-small"
                                        color: Theme.expense
                                    }
                                }
                            }
                        }

                        Label {
                            text: (modelData.is_liability === 1 ? "-" : "+") + Theme.formatCurrency(modelData.value, currencyCode)
                            fontSize: "medium"
                            font.weight: Font.DemiBold
                            color: modelData.is_liability === 1 ? Theme.expense : Theme.income
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: openEditAsset(modelData)
                        z: -1
                    }
                }
            }

            // Empty state
            EmptyState {
                Layout.fillWidth: true
                Layout.topMargin: units.gu(3)
                visible: assets.length === 0
                iconName: "stock_store"
                title: "No Assets Yet"
                subtitle: "Add your assets and liabilities to track net worth"
                actionText: "Add Asset"
                onActionClicked: openAddAsset()
            }

            // Net Worth Chart
            GlassCard {
                Layout.fillWidth: true
                Layout.topMargin: units.gu(2)
                implicitHeight: units.gu(30)
                visible: monthlyData.length > 1

                ColumnLayout {
                    spacing: units.gu(1)

                    Label {
                        text: "Net Worth Trend"
                        fontSize: "medium"
                        font.weight: Font.DemiBold
                        color: Theme.gray900
                    }

                    Flickable {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        contentWidth: trendChart.width
                        clip: true

                        LineChart {
                            id: trendChart
                            height: parent.height
                            data: monthlyData.map(function(m) {
                                return {
                                    label: m.month.substring(5),
                                    value: m.cumulativeNetWorth
                                };
                            })
                            currencyCode: netWorthPage.currencyCode
                            lineColor: Theme.primary
                        }
                    }
                }
            }

            Item { Layout.preferredHeight: units.gu(10) }
        }
    }

    // Add/Edit Asset Dialog
    Component {
        id: assetDialogComponent

        Dialog {
            id: assetDialog
            title: netWorthPage.editingAsset ? "Edit Asset" : "Add Asset"

            TextField {
                id: assetNameInput
                placeholderText: "Asset name"
                text: netWorthPage.editingAsset ? netWorthPage.editingAsset.name : ""
            }

            Label {
                text: "Type"
                fontSize: "small"
                color: Theme.gray500
            }

            Flow {
                width: parent.width
                spacing: units.gu(1)

                Repeater {
                    model: Theme.assetTypes

                    CategoryChip {
                        text: modelData.name
                        selected: assetTypeTracker.text === modelData.type
                        onClicked: {
                            assetTypeTracker.text = modelData.type;
                            if (modelData.type === "loan") {
                                isLiabilitySwitch.checked = true;
                            }
                        }
                    }
                }
            }

            // Hidden type tracker
            TextField {
                id: assetTypeTracker
                visible: false
                text: netWorthPage.editingAsset ? netWorthPage.editingAsset.type : "savings"
            }

            RowLayout {
                width: parent.width
                spacing: units.gu(1)

                Label {
                    text: Theme.getCurrencySymbol(netWorthPage.currencyCode)
                    fontSize: "large"
                    color: Theme.gray500
                }

                TextField {
                    id: assetValueInput
                    Layout.fillWidth: true
                    placeholderText: "Value"
                    inputMethodHints: Qt.ImhDigitsOnly
                    text: netWorthPage.editingAsset ? netWorthPage.editingAsset.value.toString() : ""
                }
            }

            RowLayout {
                width: parent.width

                Label {
                    text: "Is this a liability?"
                    fontSize: "medium"
                    color: Theme.gray700
                }

                Item { Layout.fillWidth: true }

                Switch {
                    id: isLiabilitySwitch
                    checked: netWorthPage.editingAsset ? netWorthPage.editingAsset.is_liability === 1 : false
                }
            }

            TextField {
                id: assetNoteInput
                placeholderText: "Note (optional)"
                text: netWorthPage.editingAsset ? (netWorthPage.editingAsset.note || "") : ""
            }

            Button {
                text: netWorthPage.editingAsset ? "Update" : "Add Asset"
                color: Theme.primary
                onClicked: {
                    var name = assetNameInput.text.trim();
                    var type = assetTypeTracker.text;
                    var value = parseFloat(assetValueInput.text) || 0;
                    var isLiability = isLiabilitySwitch.checked;
                    var note = assetNoteInput.text.trim();

                    if (name === "" || value <= 0) return;

                    if (netWorthPage.editingAsset) {
                        Database.updateAsset(netWorthPage.editingAsset.id, name, type, value, isLiability, note);
                    } else {
                        Database.addAsset(name, type, value, isLiability, note);
                    }
                    PopupUtils.close(assetDialog);
                    netWorthPage.refreshData();
                }
            }

            Button {
                text: "Delete"
                color: Theme.expense
                visible: netWorthPage.editingAsset !== null
                onClicked: {
                    if (netWorthPage.editingAsset) {
                        Database.deleteAsset(netWorthPage.editingAsset.id);
                    }
                    PopupUtils.close(assetDialog);
                    netWorthPage.refreshData();
                }
            }

            Button {
                text: "Cancel"
                onClicked: PopupUtils.close(assetDialog)
            }
        }
    }

    function openAddAsset() {
        editingAsset = null;
        PopupUtils.open(assetDialogComponent);
    }

    function openEditAsset(asset) {
        editingAsset = asset;
        PopupUtils.open(assetDialogComponent);
    }

    function loadAssets() {
        if (assetFilter === "all") {
            assets = Database.getAssets();
        } else {
            assets = Database.getAssets(assetFilter);
        }
    }

    function refreshData() {
        var settings = Database.getUserSettings();
        if (settings) {
            currencyCode = settings.currency || "INR";
        }

        netWorthData = Database.getNetWorthData();
        monthlyData = Database.getMonthlyNetWorth();
        loadAssets();
    }

    function getAssetIcon(type) {
        for (var i = 0; i < Theme.assetTypes.length; i++) {
            if (Theme.assetTypes[i].type === type) {
                return Theme.assetTypes[i].icon;
            }
        }
        return "other-actions";
    }

    function getAssetTypeName(type) {
        for (var i = 0; i < Theme.assetTypes.length; i++) {
            if (Theme.assetTypes[i].type === type) {
                return Theme.assetTypes[i].name;
            }
        }
        return "Other";
    }

    Component.onCompleted: {
        refreshData();
    }
}
