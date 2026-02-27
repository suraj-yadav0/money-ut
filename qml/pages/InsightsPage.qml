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
        contentHeight: contentColumn.height + units.gu(3)
        clip: true

        ColumnLayout {
            id: contentColumn
            width: parent.width - units.gu(4)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: units.gu(2)

            Item { Layout.preferredHeight: units.gu(1) }

            // Insights list
            Repeater {
                model: insights

                GlassCard {
                    Layout.fillWidth: true

                    ColumnLayout {
                        spacing: units.gu(1.5)

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: units.gu(1)

                            // Severity icon
                            LomiriShape {
                                Layout.preferredWidth: units.gu(5)
                                Layout.preferredHeight: units.gu(5)
                                aspect: LomiriShape.Flat
                                radius: "large"
                                relativeRadius: 0.5
                                backgroundColor: Qt.rgba(
                                    Theme.getInsightColor(modelData.severity).r,
                                    Theme.getInsightColor(modelData.severity).g,
                                    Theme.getInsightColor(modelData.severity).b,
                                    0.15
                                )

                                Icon {
                                    anchors.centerIn: parent
                                    width: units.gu(2.5)
                                    height: units.gu(2.5)
                                    name: getSeverityIcon(modelData.severity)
                                    color: Theme.getInsightColor(modelData.severity)
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: units.dp(2)

                                Label {
                                    text: modelData.title
                                    fontSize: "medium"
                                    font.weight: Font.DemiBold
                                    color: Theme.gray900
                                }

                                Label {
                                    text: modelData.severity.charAt(0).toUpperCase() + modelData.severity.slice(1)
                                    fontSize: "x-small"
                                    color: Theme.getInsightColor(modelData.severity)
                                    font.weight: Font.Medium
                                }
                            }
                        }

                        Label {
                            text: modelData.description
                            fontSize: "medium"
                            color: Theme.gray700
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }

                        // Tip box
                        LomiriShape {
                            Layout.fillWidth: true
                            visible: modelData.tip !== undefined
                            aspect: LomiriShape.Flat
                            radius: "small"
                            backgroundColor: Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.1)
                            implicitHeight: tipContent.height + units.gu(2)

                            Row {
                                id: tipContent
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    top: parent.top
                                    margins: units.gu(1)
                                }
                                spacing: units.gu(1)

                                Icon {
                                    width: units.gu(2.5)
                                    height: units.gu(2.5)
                                    name: "info"
                                    color: Theme.secondary
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Label {
                                    text: modelData.tip || ""
                                    fontSize: "small"
                                    color: Theme.gray700
                                    wrapMode: Text.WordWrap
                                    width: parent.width - units.gu(4)
                                }
                            }
                        }

                        // Action button
                        Button {
                            visible: modelData.actionText !== undefined
                            Layout.alignment: Qt.AlignRight
                            text: modelData.actionText || ""
                            color: Theme.primary
                            onClicked: handleInsightAction(modelData.type)
                        }
                    }
                }
            }

            // Empty state
            EmptyState {
                Layout.fillWidth: true
                Layout.topMargin: units.gu(4)
                visible: insights.length === 0
                iconName: "info"
                title: "No Insights Yet"
                subtitle: "Add more transactions to get personalized financial insights"
            }

            Item { Layout.preferredHeight: units.gu(3) }
        }
    }

    function getSeverityIcon(severity) {
        switch (severity) {
            case "critical": return "dialog-warning-symbolic";
            case "warning": return "dialog-warning-symbolic";
            default: return "info";
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
