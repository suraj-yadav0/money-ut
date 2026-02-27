import QtQuick 2.7
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
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
        contentHeight: contentColumn.height + units.gu(4)
        clip: true

        ColumnLayout {
            id: contentColumn
            width: parent.width - units.gu(4)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: units.gu(2)

            Item { Layout.preferredHeight: units.gu(1) }

            // Income section
            Label {
                text: "Income"
                fontSize: "medium"
                font.weight: Font.DemiBold
                color: Theme.gray500
            }

            GlassCard {
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: units.gu(1.5)

                    Label {
                        text: "Monthly Income"
                        fontSize: "medium"
                        color: Theme.gray700
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: units.gu(1)

                        Label {
                            text: Theme.getCurrencySymbol(currencyCode)
                            fontSize: "large"
                            color: Theme.gray500
                        }

                        TextField {
                            id: incomeInput
                            Layout.fillWidth: true
                            text: monthlyIncome > 0 ? monthlyIncome.toString() : ""
                            placeholderText: "Enter monthly income"
                            inputMethodHints: Qt.ImhDigitsOnly

                            onAccepted: saveIncome()
                            onFocusChanged: {
                                if (!focus && text !== "") saveIncome();
                            }

                            function saveIncome() {
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

            // Preferences section
            Label {
                text: "Preferences"
                fontSize: "medium"
                font.weight: Font.DemiBold
                color: Theme.gray500
            }

            GlassCard {
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: units.gu(1.5)

                    Label {
                        text: "Currency"
                        fontSize: "medium"
                        color: Theme.gray700
                    }

                    Flow {
                        Layout.fillWidth: true
                        spacing: units.gu(1)

                        Repeater {
                            model: Theme.currencies

                            AbstractButton {
                                width: units.gu(10)
                                height: units.gu(5.5)

                                onClicked: {
                                    currencyCode = modelData.code;
                                    Database.updateUserSettings(monthlyIncome, currencyCode);
                                }

                                LomiriShape {
                                    anchors.fill: parent
                                    aspect: LomiriShape.Flat
                                    radius: "medium"
                                    backgroundColor: currencyCode === modelData.code ? Theme.primary : Theme.white
                                    borderSource: currencyCode === modelData.code ? "" : "radius_idle.sci"

                                    Column {
                                        anchors.centerIn: parent
                                        spacing: 2

                                        Label {
                                            text: modelData.symbol
                                            fontSize: "large"
                                            font.weight: Font.Bold
                                            color: currencyCode === modelData.code ? Theme.white : Theme.gray700
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }

                                        Label {
                                            text: modelData.code
                                            fontSize: "x-small"
                                            color: currencyCode === modelData.code ? Theme.white : Theme.gray500
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // About section
            Label {
                text: "About"
                fontSize: "medium"
                font.weight: Font.DemiBold
                color: Theme.gray500
            }

            GlassCard {
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: units.gu(1.5)

                    RowLayout {
                        Layout.fillWidth: true

                        LomiriShape {
                            width: units.gu(7)
                            height: units.gu(7)
                            aspect: LomiriShape.DropShadow
                            radius: "medium"
                            backgroundMode: LomiriShape.VerticalGradient
                            backgroundColor: Theme.primary
                            secondaryBackgroundColor: Theme.primaryDark

                            Label {
                                anchors.centerIn: parent
                                text: "👛"
                                font.pixelSize: units.gu(3.5)
                            }
                        }

                        ColumnLayout {
                            spacing: 2

                            Label {
                                text: "Quantro"
                                fontSize: "large"
                                font.weight: Font.Bold
                                color: Theme.gray900
                            }

                            Label {
                                text: "Smart Finance Manager"
                                fontSize: "small"
                                color: Theme.gray500
                            }

                            Label {
                                text: "Version 1.0.0"
                                fontSize: "x-small"
                                color: Theme.gray400
                            }
                        }
                    }
                }
            }

            // Data section
            Label {
                text: "Data"
                fontSize: "medium"
                font.weight: Font.DemiBold
                color: Theme.gray500
            }

            GlassCard {
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: units.gu(1.5)

                    // Export data
                    ListItem {
                        Layout.fillWidth: true
                        height: units.gu(6)
                        divider.visible: true

                        RowLayout {
                            anchors {
                                fill: parent
                                leftMargin: units.gu(1)
                                rightMargin: units.gu(1)
                            }
                            spacing: units.gu(1)

                            Label {
                                text: "📤"
                                font.pixelSize: units.gu(2.5)
                            }

                            Label {
                                text: "Export Data"
                                fontSize: "medium"
                                color: Theme.gray900
                                Layout.fillWidth: true
                            }

                            Label {
                                text: "Coming Soon"
                                fontSize: "small"
                                color: Theme.gray400
                            }
                        }
                    }

                    // Clear data
                    ListItem {
                        Layout.fillWidth: true
                        height: units.gu(6)

                        onClicked: PopupUtils.open(clearDialogComponent)

                        RowLayout {
                            anchors {
                                fill: parent
                                leftMargin: units.gu(1)
                                rightMargin: units.gu(1)
                            }
                            spacing: units.gu(1)

                            Label {
                                text: "🗑️"
                                font.pixelSize: units.gu(2.5)
                            }

                            Label {
                                text: "Clear All Data"
                                fontSize: "medium"
                                color: Theme.expense
                                Layout.fillWidth: true
                            }

                            Icon {
                                width: units.gu(2)
                                height: units.gu(2)
                                name: "go-next"
                                color: Theme.gray400
                            }
                        }
                    }
                }
            }

            Item { Layout.preferredHeight: units.gu(4) }
        }
    }

    // Clear data confirmation dialog
    Component {
        id: clearDialogComponent

        Dialog {
            id: clearDialog
            title: "⚠️ Clear All Data?"
            text: "This will delete all transactions, goals, assets, and settings. This action cannot be undone."

            Button {
                text: "Clear"
                color: Theme.expense
                onClicked: {
                    Database.clearAllData();
                    PopupUtils.close(clearDialog);
                    settingsPage.refreshData();
                }
            }

            Button {
                text: "Cancel"
                onClicked: PopupUtils.close(clearDialog)
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
