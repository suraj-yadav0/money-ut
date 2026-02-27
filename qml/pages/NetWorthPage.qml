import QtQuick 2.7
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3
import ".."
import "../components"

Page {
    id: netWorthPage

    property string currencyCode: "INR"
    property var netWorthData: null
    property var monthlyData: []
    property var assets: []
    property string assetFilter: "all"

    header: PageHeader {
        id: header
        title: "Net Worth"
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

            // Net Worth Card
            GlassContainer {
                Layout.fillWidth: true
                height: 120
                glassOpacity: 0.8

                gradient: Gradient {
                    GradientStop { position: 0.0; color: netWorthData && netWorthData.netWorth >= 0 ?
                        Qt.rgba(Theme.income.r, Theme.income.g, Theme.income.b, 0.15) :
                        Qt.rgba(Theme.expense.r, Theme.expense.g, Theme.expense.b, 0.15) }
                    GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.8) }
                }

                ColumnLayout {
                    anchors {
                        fill: parent
                        margins: Theme.spacingLG
                    }
                    spacing: Theme.spacingXS

                    Text {
                        text: "Total Net Worth"
                        font.pixelSize: Theme.fontSizeMD
                        color: Theme.gray500
                    }

                    Text {
                        text: Theme.formatFullCurrency(netWorthData ? netWorthData.netWorth : 0, currencyCode)
                        font.pixelSize: Theme.fontSize4XL
                        font.weight: Font.Bold
                        color: netWorthData && netWorthData.netWorth >= 0 ? Theme.income : Theme.expense
                    }
                }
            }

            // Breakdown row
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSM

                // Assets
                GlassCard {
                    Layout.fillWidth: true
                    implicitHeight: 70

                    ColumnLayout {
                        spacing: 2

                        Text {
                            text: "Assets"
                            font.pixelSize: Theme.fontSizeXS
                            color: Theme.gray500
                        }

                        Text {
                            text: Theme.formatCompactCurrency(netWorthData ? netWorthData.totalAssets : 0, currencyCode)
                            font.pixelSize: Theme.fontSizeMD
                            font.weight: Font.DemiBold
                            color: Theme.income
                        }
                    }
                }

                // Liabilities
                GlassCard {
                    Layout.fillWidth: true
                    implicitHeight: 70

                    ColumnLayout {
                        spacing: 2

                        Text {
                            text: "Liabilities"
                            font.pixelSize: Theme.fontSizeXS
                            color: Theme.gray500
                        }

                        Text {
                            text: Theme.formatCompactCurrency(netWorthData ? netWorthData.totalLiabilities : 0, currencyCode)
                            font.pixelSize: Theme.fontSizeMD
                            font.weight: Font.DemiBold
                            color: Theme.expense
                        }
                    }
                }

                // Goals
                GlassCard {
                    Layout.fillWidth: true
                    implicitHeight: 70

                    ColumnLayout {
                        spacing: 2

                        Text {
                            text: "Goals"
                            font.pixelSize: Theme.fontSizeXS
                            color: Theme.gray500
                        }

                        Text {
                            text: Theme.formatCompactCurrency(netWorthData ? netWorthData.goalSavings : 0, currencyCode)
                            font.pixelSize: Theme.fontSizeMD
                            font.weight: Font.DemiBold
                            color: Theme.primary
                        }
                    }
                }
            }

            // Asset type filter
            ListView {
                Layout.fillWidth: true
                height: 44
                orientation: ListView.Horizontal
                spacing: Theme.spacingSM
                clip: true

                model: [
                    { key: "all", label: "All", emoji: "" },
                    { key: "savings", label: "Savings", emoji: "💰" },
                    { key: "investment", label: "Investment", emoji: "📈" },
                    { key: "property", label: "Property", emoji: "🏠" },
                    { key: "gold", label: "Gold", emoji: "🥇" },
                    { key: "loan", label: "Loan", emoji: "🏦" },
                    { key: "other", label: "Other", emoji: "📦" }
                ]

                delegate: CategoryChip {
                    text: modelData.emoji + " " + modelData.label
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

                Text {
                    text: "Your Assets"
                    font.pixelSize: Theme.fontSizeLG
                    font.weight: Font.DemiBold
                    color: Theme.gray900
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: assets.length + " items"
                    font.pixelSize: Theme.fontSizeSM
                    color: Theme.gray500
                }
            }

            // Assets list
            Repeater {
                model: assets

                GlassCard {
                    Layout.fillWidth: true

                    RowLayout {
                        spacing: Theme.spacingMD

                        // Type emoji
                        Rectangle {
                            width: 44
                            height: 44
                            radius: 22
                            color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.15)

                            Text {
                                anchors.centerIn: parent
                                text: getAssetEmoji(modelData.type)
                                font.pixelSize: 20
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: modelData.name
                                font.pixelSize: Theme.fontSizeMD
                                font.weight: Font.DemiBold
                                color: Theme.gray900
                            }

                            Row {
                                spacing: Theme.spacingSM

                                Text {
                                    text: getAssetTypeName(modelData.type)
                                    font.pixelSize: Theme.fontSizeSM
                                    color: Theme.gray500
                                }

                                Rectangle {
                                    visible: modelData.is_liability === 1
                                    width: liabilityLabel.width + 8
                                    height: liabilityLabel.height + 4
                                    radius: 4
                                    color: Qt.rgba(Theme.expense.r, Theme.expense.g, Theme.expense.b, 0.15)

                                    Text {
                                        id: liabilityLabel
                                        anchors.centerIn: parent
                                        text: "Liability"
                                        font.pixelSize: Theme.fontSizeXS
                                        color: Theme.expense
                                    }
                                }
                            }
                        }

                        Text {
                            text: (modelData.is_liability === 1 ? "-" : "+") + Theme.formatCurrency(modelData.value, currencyCode)
                            font.pixelSize: Theme.fontSizeMD
                            font.weight: Font.DemiBold
                            color: modelData.is_liability === 1 ? Theme.expense : Theme.income
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: openEditAsset(modelData)
                    }
                }
            }

            // Empty state
            EmptyState {
                Layout.fillWidth: true
                Layout.topMargin: Theme.spacing2XL
                visible: assets.length === 0
                emoji: "🏦"
                title: "No Assets Yet"
                subtitle: "Add your assets and liabilities to track net worth"
                actionText: "Add Asset"
                onActionClicked: openAddAsset()
            }

            // Net Worth Chart
            GlassCard {
                Layout.fillWidth: true
                Layout.topMargin: Theme.spacingLG
                implicitHeight: 250
                visible: monthlyData.length > 1

                ColumnLayout {
                    spacing: Theme.spacingSM

                    Text {
                        text: "Net Worth Trend"
                        font.pixelSize: Theme.fontSizeMD
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
            text: "+"
            font.pixelSize: 28
            font.weight: Font.Bold
            color: Theme.white
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: openAddAsset()
        }
    }

    // Add/Edit Asset Dialog
    property bool showAssetDialog: false
    property var editingAsset: null

    Rectangle {
        id: assetDialogOverlay
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.5)
        visible: showAssetDialog
        opacity: showAssetDialog ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: Theme.animationNormal }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: showAssetDialog = false
        }

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: parent.height * 0.75
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
                        text: editingAsset ? "Edit Asset" : "Add Asset"
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
                            onClicked: showAssetDialog = false
                        }
                    }
                }

                // Name
                TextField {
                    id: assetNameInput
                    Layout.fillWidth: true
                    placeholderText: "Asset name"
                }

                // Type selector
                Text {
                    text: "Type"
                    font.pixelSize: Theme.fontSizeSM
                    color: Theme.gray500
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: Theme.spacingSM

                    Repeater {
                        model: Theme.assetTypes

                        CategoryChip {
                            text: modelData.emoji + " " + modelData.name
                            selected: assetTypeInput.text === modelData.type
                            onClicked: {
                                assetTypeInput.text = modelData.type;
                                if (modelData.type === "loan") {
                                    isLiabilitySwitch.checked = true;
                                }
                            }
                        }
                    }
                }

                // Hidden type tracker
                TextField {
                    id: assetTypeInput
                    visible: false
                    text: "savings"
                }

                // Value
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingSM

                    Text {
                        text: Theme.getCurrencySymbol(currencyCode)
                        font.pixelSize: Theme.fontSizeLG
                        color: Theme.gray500
                    }

                    TextField {
                        id: assetValueInput
                        Layout.fillWidth: true
                        placeholderText: "Value"
                        inputMethodHints: Qt.ImhDigitsOnly
                    }
                }

                // Liability switch
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Is this a liability?"
                        font.pixelSize: Theme.fontSizeMD
                        color: Theme.gray700
                    }

                    Item { Layout.fillWidth: true }

                    Switch {
                        id: isLiabilitySwitch
                    }
                }

                // Note
                TextField {
                    id: assetNoteInput
                    Layout.fillWidth: true
                    placeholderText: "Note (optional)"
                }

                Item { Layout.fillHeight: true }

                // Buttons
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingSM

                    Rectangle {
                        visible: editingAsset !== null
                        Layout.fillWidth: true
                        height: 48
                        radius: Theme.radiusButton
                        color: Theme.expense

                        Text {
                            anchors.centerIn: parent
                            text: "Delete"
                            font.pixelSize: Theme.fontSizeMD
                            font.weight: Font.DemiBold
                            color: Theme.white
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: deleteAsset()
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 48
                        radius: Theme.radiusButton
                        color: Theme.primary

                        Text {
                            anchors.centerIn: parent
                            text: editingAsset ? "Update" : "Add Asset"
                            font.pixelSize: Theme.fontSizeMD
                            font.weight: Font.DemiBold
                            color: Theme.white
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: saveAsset()
                        }
                    }
                }
            }
        }
    }

    function openAddAsset() {
        editingAsset = null;
        assetNameInput.text = "";
        assetTypeInput.text = "savings";
        assetValueInput.text = "";
        isLiabilitySwitch.checked = false;
        assetNoteInput.text = "";
        showAssetDialog = true;
    }

    function openEditAsset(asset) {
        editingAsset = asset;
        assetNameInput.text = asset.name;
        assetTypeInput.text = asset.type;
        assetValueInput.text = asset.value.toString();
        isLiabilitySwitch.checked = asset.is_liability === 1;
        assetNoteInput.text = asset.note || "";
        showAssetDialog = true;
    }

    function saveAsset() {
        var name = assetNameInput.text.trim();
        var type = assetTypeInput.text;
        var value = parseFloat(assetValueInput.text) || 0;
        var isLiability = isLiabilitySwitch.checked;
        var note = assetNoteInput.text.trim();

        if (name === "" || value <= 0) return;

        if (editingAsset) {
            Database.updateAsset(editingAsset.id, name, type, value, isLiability, note);
        } else {
            Database.addAsset(name, type, value, isLiability, note);
        }

        showAssetDialog = false;
        refreshData();
    }

    function deleteAsset() {
        if (editingAsset) {
            Database.deleteAsset(editingAsset.id);
            showAssetDialog = false;
            refreshData();
        }
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

    function getAssetEmoji(type) {
        for (var i = 0; i < Theme.assetTypes.length; i++) {
            if (Theme.assetTypes[i].type === type) {
                return Theme.assetTypes[i].emoji;
            }
        }
        return "📦";
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
