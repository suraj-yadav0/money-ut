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
        spacing: Theme.spacingSM
        visible: currentStep > 0

        Repeater {
            model: 3

            Rectangle {
                width: currentStep === index ? 24 : 8
                height: 8
                radius: 4
                color: currentStep >= index ? Theme.primary : Theme.gray300

                Behavior on width {
                    NumberAnimation { duration: Theme.animationNormal }
                }
                Behavior on color {
                    ColorAnimation { duration: Theme.animationNormal }
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
            leftMargin: Theme.spacingXL
            rightMargin: Theme.spacingXL
        }
        currentIndex: currentStep

        // Step 0: Welcome
        Item {
            ColumnLayout {
                anchors.centerIn: parent
                spacing: Theme.spacing2XL
                width: parent.width

                // Logo container
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    width: 120
                    height: 120
                    radius: 30
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Theme.primary }
                        GradientStop { position: 1.0; color: Theme.primaryDark }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "👛"
                        font.pixelSize: 56
                    }
                }

                // App name
                Text {
                    text: "Quantro"
                    font.pixelSize: Theme.fontSize5XL
                    font.weight: Font.Bold
                    color: Theme.gray900
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "Smart Finance Manager"
                    font.pixelSize: Theme.fontSizeXL
                    color: Theme.gray500
                    Layout.alignment: Qt.AlignHCenter
                }

                Item { Layout.preferredHeight: Theme.spacing3XL }

                Text {
                    text: "Take control of your finances"
                    font.pixelSize: Theme.fontSizeLG
                    color: Theme.gray600
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Item { Layout.fillHeight: true }

                // Get Started button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56
                    radius: Theme.radiusButton
                    color: Theme.primary

                    Text {
                        anchors.centerIn: parent
                        text: "Get Started"
                        font.pixelSize: Theme.fontSizeLG
                        font.weight: Font.SemiBold
                        color: Theme.white
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: currentStep = 1
                    }
                }

                // Continue as Guest
                Text {
                    text: "Continue as Guest"
                    font.pixelSize: Theme.fontSizeMD
                    color: Theme.gray500
                    Layout.alignment: Qt.AlignHCenter

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            completeOnboarding(0);
                        }
                    }
                }
            }
        }

        // Step 1: Income Setup
        Item {
            ColumnLayout {
                anchors.centerIn: parent
                spacing: Theme.spacing2XL
                width: parent.width

                Text {
                    text: "What's your monthly income?"
                    font.pixelSize: Theme.fontSize2XL
                    font.weight: Font.Bold
                    color: Theme.gray900
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Text {
                    text: "This helps us provide better insights and budget suggestions"
                    font.pixelSize: Theme.fontSizeMD
                    color: Theme.gray500
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Item { Layout.preferredHeight: Theme.spacingXL }

                // Currency prefix + Amount input
                Row {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: Theme.spacingSM

                    Text {
                        text: Theme.getCurrencySymbol(currency)
                        font.pixelSize: Theme.fontSize4XL
                        font.weight: Font.Bold
                        color: Theme.gray400
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    TextField {
                        id: incomeInput
                        width: 200
                        font.pixelSize: Theme.fontSize4XL
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
                    spacing: Theme.spacingSM

                    Repeater {
                        model: Theme.currencies

                        Rectangle {
                            width: 50
                            height: 36
                            radius: Theme.radiusSM
                            color: currency === modelData.code ? Theme.primary : "transparent"
                            border.width: currency === modelData.code ? 0 : 1
                            border.color: Theme.gray300

                            Text {
                                anchors.centerIn: parent
                                text: modelData.symbol
                                font.pixelSize: Theme.fontSizeMD
                                color: currency === modelData.code ? Theme.white : Theme.gray700
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: currency = modelData.code
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                // Continue button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56
                    radius: Theme.radiusButton
                    color: monthlyIncome > 0 ? Theme.primary : Theme.gray300

                    Text {
                        anchors.centerIn: parent
                        text: "Continue"
                        font.pixelSize: Theme.fontSizeLG
                        font.weight: Font.SemiBold
                        color: monthlyIncome > 0 ? Theme.white : Theme.gray500
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: monthlyIncome > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            if (monthlyIncome > 0) {
                                currentStep = 2;
                            }
                        }
                    }
                }

                // Back button
                Text {
                    text: "← Back"
                    font.pixelSize: Theme.fontSizeMD
                    color: Theme.gray500
                    Layout.alignment: Qt.AlignHCenter

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: currentStep = 0
                    }
                }
            }
        }

        // Step 2: Confirmation
        Item {
            ColumnLayout {
                anchors.centerIn: parent
                spacing: Theme.spacing2XL
                width: parent.width

                Text {
                    text: "🎉"
                    font.pixelSize: 64
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "Perfect! You're all set"
                    font.pixelSize: Theme.fontSize2XL
                    font.weight: Font.Bold
                    color: Theme.gray900
                    Layout.alignment: Qt.AlignHCenter
                }

                // Summary card
                GlassCard {
                    Layout.fillWidth: true

                    ColumnLayout {
                        spacing: Theme.spacingLG

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text: "Monthly Income"
                                font.pixelSize: Theme.fontSizeMD
                                color: Theme.gray600
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                text: Theme.formatFullCurrency(monthlyIncome, currency)
                                font.pixelSize: Theme.fontSizeLG
                                font.weight: Font.SemiBold
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

                            Text {
                                text: "Daily Budget"
                                font.pixelSize: Theme.fontSizeMD
                                color: Theme.gray600
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                property int daysInMonth: new Date(new Date().getFullYear(), new Date().getMonth() + 1, 0).getDate()
                                text: Theme.formatCurrency(monthlyIncome / daysInMonth, currency) + "/day"
                                font.pixelSize: Theme.fontSizeLG
                                font.weight: Font.SemiBold
                                color: Theme.primary
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                // Start button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56
                    radius: Theme.radiusButton
                    color: Theme.primary

                    Text {
                        anchors.centerIn: parent
                        text: "Start Tracking"
                        font.pixelSize: Theme.fontSizeLG
                        font.weight: Font.SemiBold
                        color: Theme.white
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: completeOnboarding(monthlyIncome)
                    }
                }

                // Back button
                Text {
                    text: "← Back"
                    font.pixelSize: Theme.fontSizeMD
                    color: Theme.gray500
                    Layout.alignment: Qt.AlignHCenter

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: currentStep = 1
                    }
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
