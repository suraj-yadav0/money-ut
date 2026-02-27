import QtQuick 2.7
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3
import ".."
import "../components"

Page {
    id: settingsPage

    property string currencyCode: "INR"
    property real monthlyIncome: 0

    header: PageHeader {
        id: header
        title: "Settings"

        leadingActionBar.actions: [
            Action {
                iconName: "back"
                text: "Back"
                onTriggered: pageStack.pop()
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
        contentHeight: contentColumn.height + Theme.spacing2XL
        clip: true

        ColumnLayout {
            id: contentColumn
            width: parent.width - Theme.spacingLG * 2
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.spacingLG

            Item { Layout.preferredHeight: Theme.spacingSM }

            // Income section
            Text {
                text: "Income"
                font.pixelSize: Theme.fontSizeMD
                font.weight: Font.SemiBold
                color: Theme.gray500
            }

            GlassCard {
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: Theme.spacingMD

                    Text {
                        text: "Monthly Income"
                        font.pixelSize: Theme.fontSizeMD
                        color: Theme.gray700
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacingSM

                        Text {
                            text: Theme.getCurrencySymbol(currencyCode)
                            font.pixelSize: Theme.fontSizeLG
                            color: Theme.gray500
                        }

                        TextField {
                            id: incomeInput
                            Layout.fillWidth: true
                            text: monthlyIncome > 0 ? monthlyIncome.toString() : ""
                            placeholderText: "Enter monthly income"
                            inputMethodHints: Qt.ImhDigitsOnly

                            onAccepted: {
                                var newIncome = parseFloat(text) || 0;
                                if (newIncome !== monthlyIncome) {
                                    monthlyIncome = newIncome;
                                    Database.updateUserSettings(monthlyIncome, currencyCode);
                                    if (monthlyIncome > 0) {
                                        Database.createSalaryTransaction(monthlyIncome);
                                    }
                                }
                            }

                            onFocusChanged: {
                                if (!focus && text !== "") {
                                    var newIncome = parseFloat(text) || 0;
                                    if (newIncome !== monthlyIncome) {
                                        monthlyIncome = newIncome;
                                        Database.updateUserSettings(monthlyIncome, currencyCode);
                                        if (monthlyIncome > 0) {
                                            Database.createSalaryTransaction(monthlyIncome);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Preferences section
            Text {
                text: "Preferences"
                font.pixelSize: Theme.fontSizeMD
                font.weight: Font.SemiBold
                color: Theme.gray500
            }

            GlassCard {
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: Theme.spacingMD

                    Text {
                        text: "Currency"
                        font.pixelSize: Theme.fontSizeMD
                        color: Theme.gray700
                    }

                    Flow {
                        Layout.fillWidth: true
                        spacing: Theme.spacingSM

                        Repeater {
                            model: Theme.currencies

                            Rectangle {
                                width: 80
                                height: 44
                                radius: Theme.radiusSM
                                color: currencyCode === modelData.code ? Theme.primary : Theme.white
                                border.width: currencyCode === modelData.code ? 0 : 1
                                border.color: Theme.gray300

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 2

                                    Text {
                                        text: modelData.symbol
                                        font.pixelSize: Theme.fontSizeLG
                                        font.weight: Font.Bold
                                        color: currencyCode === modelData.code ? Theme.white : Theme.gray700
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }

                                    Text {
                                        text: modelData.code
                                        font.pixelSize: Theme.fontSizeXS
                                        color: currencyCode === modelData.code ? Theme.white : Theme.gray500
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        currencyCode = modelData.code;
                                        Database.updateUserSettings(monthlyIncome, currencyCode);
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // About section
            Text {
                text: "About"
                font.pixelSize: Theme.fontSizeMD
                font.weight: Font.SemiBold
                color: Theme.gray500
            }

            GlassCard {
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: Theme.spacingMD

                    RowLayout {
                        Layout.fillWidth: true

                        Rectangle {
                            width: 56
                            height: 56
                            radius: 14
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: Theme.primary }
                                GradientStop { position: 1.0; color: Theme.primaryDark }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "👛"
                                font.pixelSize: 28
                            }
                        }

                        ColumnLayout {
                            spacing: 2

                            Text {
                                text: "Quantro"
                                font.pixelSize: Theme.fontSizeLG
                                font.weight: Font.Bold
                                color: Theme.gray900
                            }

                            Text {
                                text: "Smart Finance Manager"
                                font.pixelSize: Theme.fontSizeSM
                                color: Theme.gray500
                            }

                            Text {
                                text: "Version 1.0.0"
                                font.pixelSize: Theme.fontSizeXS
                                color: Theme.gray400
                            }
                        }
                    }
                }
            }

            // Data section
            Text {
                text: "Data"
                font.pixelSize: Theme.fontSizeMD
                font.weight: Font.SemiBold
                color: Theme.gray500
            }

            GlassCard {
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: Theme.spacingMD

                    // Export data
                    Rectangle {
                        Layout.fillWidth: true
                        height: 50
                        color: "transparent"

                        RowLayout {
                            anchors.fill: parent
                            spacing: Theme.spacingSM

                            Text {
                                text: "📤"
                                font.pixelSize: 20
                            }

                            Text {
                                text: "Export Data"
                                font.pixelSize: Theme.fontSizeMD
                                color: Theme.gray900
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "Coming Soon"
                                font.pixelSize: Theme.fontSizeSM
                                color: Theme.gray400
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Theme.gray200
                    }

                    // Clear data
                    Rectangle {
                        Layout.fillWidth: true
                        height: 50
                        color: "transparent"

                        RowLayout {
                            anchors.fill: parent
                            spacing: Theme.spacingSM

                            Text {
                                text: "🗑️"
                                font.pixelSize: 20
                            }

                            Text {
                                text: "Clear All Data"
                                font.pixelSize: Theme.fontSizeMD
                                color: Theme.expense
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "→"
                                font.pixelSize: Theme.fontSizeMD
                                color: Theme.gray400
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: showClearConfirmation = true
                        }
                    }
                }
            }

            Item { Layout.preferredHeight: Theme.spacing3XL }
        }
    }

    // Clear data confirmation dialog
    property bool showClearConfirmation: false

    Rectangle {
        id: clearOverlay
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.5)
        visible: showClearConfirmation
        opacity: showClearConfirmation ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: Theme.animationNormal }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: showClearConfirmation = false
        }

        Rectangle {
            anchors.centerIn: parent
            width: parent.width * 0.85
            height: 220
            radius: Theme.radiusXL
            color: Theme.white

            ColumnLayout {
                anchors {
                    fill: parent
                    margins: Theme.spacingLG
                }
                spacing: Theme.spacingMD

                Text {
                    text: "⚠️"
                    font.pixelSize: 40
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "Clear All Data?"
                    font.pixelSize: Theme.fontSizeXL
                    font.weight: Font.Bold
                    color: Theme.gray900
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "This will delete all transactions, goals, assets, and settings. This action cannot be undone."
                    font.pixelSize: Theme.fontSizeSM
                    color: Theme.gray600
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }

                Item { Layout.fillHeight: true }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingSM

                    Rectangle {
                        Layout.fillWidth: true
                        height: 44
                        radius: Theme.radiusButton
                        color: "transparent"
                        border.width: 1
                        border.color: Theme.gray300

                        Text {
                            anchors.centerIn: parent
                            text: "Cancel"
                            font.pixelSize: Theme.fontSizeMD
                            color: Theme.gray700
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: showClearConfirmation = false
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 44
                        radius: Theme.radiusButton
                        color: Theme.expense

                        Text {
                            anchors.centerIn: parent
                            text: "Clear"
                            font.pixelSize: Theme.fontSizeMD
                            font.weight: Font.SemiBold
                            color: Theme.white
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Database.clearAllData();
                                showClearConfirmation = false;
                                refreshData();
                            }
                        }
                    }
                }
            }
        }
    }

    function refreshData() {
        var settings = Database.getUserSettings();
        if (settings) {
            currencyCode = settings.currency || "INR";
            monthlyIncome = settings.monthly_income || 0;
        }
    }

    Component.onCompleted: {
        refreshData();
    }
}
