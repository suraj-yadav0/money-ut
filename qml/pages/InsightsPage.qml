import QtQuick 2.7
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3
import ".."
import "../components"

Page {
    id: insightsPage

    property var insights: []

    signal navigateToBudget()
    signal navigateToTransactions()

    header: PageHeader {
        id: header
        title: "Insights"

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

            // Insights list
            Repeater {
                model: insights

                GlassCard {
                    Layout.fillWidth: true

                    ColumnLayout {
                        spacing: Theme.spacingMD

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Theme.spacingSM

                            // Severity icon
                            Rectangle {
                                width: 44
                                height: 44
                                radius: 22
                                color: Qt.rgba(
                                    Theme.getInsightColor(modelData.severity).r,
                                    Theme.getInsightColor(modelData.severity).g,
                                    Theme.getInsightColor(modelData.severity).b,
                                    0.15
                                )

                                Text {
                                    anchors.centerIn: parent
                                    text: getSeverityIcon(modelData.severity)
                                    font.pixelSize: 20
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: modelData.title
                                    font.pixelSize: Theme.fontSizeMD
                                    font.weight: Font.SemiBold
                                    color: Theme.gray900
                                }

                                Text {
                                    text: modelData.severity.charAt(0).toUpperCase() + modelData.severity.slice(1)
                                    font.pixelSize: Theme.fontSizeXS
                                    color: Theme.getInsightColor(modelData.severity)
                                    font.weight: Font.Medium
                                }
                            }
                        }

                        Text {
                            text: modelData.description
                            font.pixelSize: Theme.fontSizeMD
                            color: Theme.gray700
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }

                        // Tip box
                        Rectangle {
                            Layout.fillWidth: true
                            visible: modelData.tip !== undefined
                            radius: Theme.radiusSM
                            color: Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.1)
                            height: tipContent.height + Theme.spacingSM * 2

                            Row {
                                id: tipContent
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    top: parent.top
                                    margins: Theme.spacingSM
                                }
                                spacing: Theme.spacingSM

                                Text {
                                    text: "💡"
                                    font.pixelSize: 16
                                }

                                Text {
                                    text: modelData.tip || ""
                                    font.pixelSize: Theme.fontSizeSM
                                    color: Theme.gray700
                                    wrapMode: Text.WordWrap
                                    width: parent.width - 30
                                }
                            }
                        }

                        // Action button
                        Rectangle {
                            visible: modelData.actionText !== undefined
                            Layout.alignment: Qt.AlignRight
                            width: actionLabel.width + Theme.spacingLG * 2
                            height: 36
                            radius: Theme.radiusSM
                            color: Theme.primary

                            Text {
                                id: actionLabel
                                anchors.centerIn: parent
                                text: modelData.actionText || ""
                                font.pixelSize: Theme.fontSizeSM
                                font.weight: Font.SemiBold
                                color: Theme.white
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: handleInsightAction(modelData.type)
                            }
                        }
                    }
                }
            }

            // Empty state
            EmptyState {
                Layout.fillWidth: true
                Layout.topMargin: Theme.spacing3XL
                visible: insights.length === 0
                emoji: "💡"
                title: "No Insights Yet"
                subtitle: "Add more transactions to get personalized financial insights"
            }

            Item { Layout.preferredHeight: Theme.spacing2XL }
        }
    }

    function getSeverityIcon(severity) {
        switch (severity) {
            case "critical": return "🚨";
            case "warning": return "⚠️";
            default: return "ℹ️";
        }
    }

    function handleInsightAction(type) {
        switch (type) {
            case "forecast":
            case "budgetPace":
                navigateToBudget();
                break;
            case "spendingSpike":
            case "categoryDominance":
            case "weekendSpending":
                navigateToTransactions();
                break;
        }
    }

    function refreshData() {
        insights = Database.generateInsights();
    }

    Component.onCompleted: {
        refreshData();
    }
}
