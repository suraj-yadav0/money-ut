import QtQuick 2.7
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3
import ".."
import "../components"

Page {
    id: onboardingPage

    signal onboardingComplete()

    property int currentStep: 0
    property real monthlyIncome: 0
    property string currency: "INR"

    header: PageHeader {
        id: header
        title: ""
        visible: false
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

    // Progress indicator
    Row {
        id: progressIndicator
        anchors {
            top: parent.top
            topMargin: units.gu(4)
            horizontalCenter: parent.horizontalCenter
        }
        spacing: units.gu(1)
        visible: currentStep > 0

        Repeater {
            model: 3

            LomiriShape {
                width: currentStep === index ? units.gu(3) : units.gu(1)
                height: units.gu(1)
                aspect: LomiriShape.Flat
                radius: "small"
                backgroundColor: currentStep >= index ? Theme.primary : Theme.gray300

                Behavior on width {
                    LomiriNumberAnimation {}
                }
            }
        }
    }

    // Step content
    StackLayout {
        id: stepStack
        anchors {
            fill: parent
            topMargin: units.gu(8)
            bottomMargin: units.gu(2)
            leftMargin: units.gu(3)
            rightMargin: units.gu(3)
        }
        currentIndex: currentStep

        // Step 0: Welcome
        Item {
            ColumnLayout {
                anchors.centerIn: parent
                spacing: units.gu(3)
                width: parent.width

                // Logo container
                LomiriShape {
                    Layout.alignment: Qt.AlignHCenter
                    width: units.gu(15)
                    height: units.gu(15)
                    aspect: LomiriShape.DropShadow
                    radius: "large"
                    backgroundMode: LomiriShape.VerticalGradient
                    backgroundColor: Theme.primary
                    secondaryBackgroundColor: Theme.primaryDark

                    Label {
                        anchors.centerIn: parent
                        text: "👛"
                        font.pixelSize: units.gu(7)
                    }
                }

                Label {
                    text: "Quantro"
                    font.pixelSize: units.gu(5)
                    font.weight: Font.Bold
                    color: Theme.gray900
                    Layout.alignment: Qt.AlignHCenter
                }

                Label {
                    text: "Smart Finance Manager"
                    fontSize: "x-large"
                    color: Theme.gray500
                    Layout.alignment: Qt.AlignHCenter
                }

                Item { Layout.preferredHeight: units.gu(4) }

                Label {
                    text: "Take control of your finances"
                    fontSize: "large"
                    color: Theme.gray600
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Item { Layout.fillHeight: true }

                Button {
                    Layout.fillWidth: true
                    text: "Get Started"
                    color: Theme.primary
                    onClicked: currentStep = 1
                }

                Button {
                    Layout.fillWidth: true
                    text: "Continue as Guest"
                    strokeColor: Theme.gray400
                    onClicked: completeOnboarding(0)
                }
            }
        }

        // Step 1: Income Setup
        Item {
            ColumnLayout {
                anchors.centerIn: parent
                spacing: units.gu(3)
                width: parent.width

                Label {
                    text: "What's your monthly income?"
                    font.pixelSize: units.gu(3)
                    font.weight: Font.Bold
                    color: Theme.gray900
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Label {
                    text: "This helps us provide better insights and budget suggestions"
                    fontSize: "medium"
                    color: Theme.gray500
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Item { Layout.preferredHeight: units.gu(3) }

                Row {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: units.gu(1)

                    Label {
                        text: Theme.getCurrencySymbol(currency)
                        font.pixelSize: units.gu(4)
                        font.weight: Font.Bold
                        color: Theme.gray400
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    TextField {
                        id: incomeInput
                        width: units.gu(25)
                        font.pixelSize: units.gu(4)
                        placeholderText: "0"
                        inputMethodHints: Qt.ImhDigitsOnly
                        horizontalAlignment: Text.AlignLeft

                        onTextChanged: {
                            monthlyIncome = parseFloat(text) || 0;
                        }
                    }
                }

                // Currency selector
                Row {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: units.gu(1)

                    Repeater {
                        model: Theme.currencies

                        AbstractButton {
                            width: units.gu(6)
                            height: units.gu(4.5)

                            onClicked: currency = modelData.code

                            LomiriShape {
                                anchors.fill: parent
                                aspect: LomiriShape.Flat
                                radius: "small"
                                backgroundColor: currency === modelData.code ? Theme.primary : "transparent"
                                borderSource: currency === modelData.code ? "" : "radius_idle.sci"

                                Label {
                                    anchors.centerIn: parent
                                    text: modelData.symbol
                                    fontSize: "medium"
                                    color: currency === modelData.code ? Theme.white : Theme.gray700
                                }
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                Button {
                    Layout.fillWidth: true
                    text: "Continue"
                    color: monthlyIncome > 0 ? Theme.primary : Theme.gray300
                    onClicked: {
                        if (monthlyIncome > 0) currentStep = 2;
                    }
                }

                Button {
                    Layout.fillWidth: true
                    text: "← Back"
                    strokeColor: Theme.gray400
                    onClicked: currentStep = 0
                }
            }
        }

        // Step 2: Confirmation
        Item {
            ColumnLayout {
                anchors.centerIn: parent
                spacing: units.gu(3)
                width: parent.width

                Label {
                    text: "🎉"
                    font.pixelSize: units.gu(8)
                    Layout.alignment: Qt.AlignHCenter
                }

                Label {
                    text: "Perfect! You're all set"
                    font.pixelSize: units.gu(3)
                    font.weight: Font.Bold
                    color: Theme.gray900
                    Layout.alignment: Qt.AlignHCenter
                }

                // Summary card
                GlassCard {
                    Layout.fillWidth: true

                    ColumnLayout {
                        spacing: units.gu(2)

                        RowLayout {
                            Layout.fillWidth: true

                            Label {
                                text: "Monthly Income"
                                fontSize: "medium"
                                color: Theme.gray600
                            }

                            Item { Layout.fillWidth: true }

                            Label {
                                text: Theme.formatFullCurrency(monthlyIncome, currency)
                                fontSize: "large"
                                font.weight: Font.DemiBold
                                color: Theme.income
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: Theme.gray200
                        }

                        RowLayout {
                            Layout.fillWidth: true

                            Label {
                                text: "Daily Budget"
                                fontSize: "medium"
                                color: Theme.gray600
                            }

                            Item { Layout.fillWidth: true }

                            Label {
                                property int daysInMonth: new Date(new Date().getFullYear(), new Date().getMonth() + 1, 0).getDate()
                                text: Theme.formatCurrency(monthlyIncome / daysInMonth, currency) + "/day"
                                fontSize: "large"
                                font.weight: Font.DemiBold
                                color: Theme.primary
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                Button {
                    Layout.fillWidth: true
                    text: "Start Tracking"
                    color: Theme.primary
                    onClicked: completeOnboarding(monthlyIncome)
                }

                Button {
                    Layout.fillWidth: true
                    text: "← Back"
                    strokeColor: Theme.gray400
                    onClicked: currentStep = 1
                }
            }
        }
    }

    function completeOnboarding(income) {
        Database.updateUserSettings(income, currency);
        if (income > 0) {
            Database.createSalaryTransaction(income);
        }
        Database.processRecurringTransactions();
        onboardingComplete();
    }
}
