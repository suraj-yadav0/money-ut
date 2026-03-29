import QtQuick 2.7
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
import ".."
import "../components"

Page {
    id: splitPage

    property string currencyCode: "INR"
    property var groups: []

    signal openGroupDetail(var group)

    function refreshData() {
        var settings = Database.getUserSettings();
        if (settings) currencyCode = settings.currency || "INR";
        groups = Database.getSplitGroups();
    }

    Component.onCompleted: refreshData()

    header: PageHeader {
        id: header
        title: "Split Expenses"
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

            // Info banner
            GlassCard {
                Layout.fillWidth: true

                RowLayout {
                    Layout.fillWidth: true
                    spacing: units.gu(1.5)

                    Icon {
                        name: "contact-group"
                        width: units.gu(3.5)
                        height: units.gu(3.5)
                        color: Theme.primary
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Label {
                            text: "Split Expenses"
                            fontSize: "large"
                            font.weight: Font.DemiBold
                            color: Theme.gray900
                        }

                        Label {
                            text: "Track shared expenses with friends & groups"
                            fontSize: "small"
                            color: Theme.gray500
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }
                }
            }

            // Groups list
            Repeater {
                model: groups

                GlassCard {
                    Layout.fillWidth: true

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: units.gu(1.5)

                        // Group icon
                        LomiriShape {
                            width: units.gu(5.5)
                            height: units.gu(5.5)
                            aspect: LomiriShape.Flat
                            radius: "large"
                            relativeRadius: 0.5
                            backgroundColor: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12)

                            Icon {
                                anchors.centerIn: parent
                                width: units.gu(2.5)
                                height: units.gu(2.5)
                                name: "contact-group"
                                color: Theme.primary
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Label {
                                text: modelData.name
                                fontSize: "large"
                                font.weight: Font.DemiBold
                                color: Theme.gray900
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Label {
                                text: modelData.member_count + " members · " + modelData.expense_count + " expenses"
                                fontSize: "small"
                                color: Theme.gray500
                            }
                        }

                        Icon {
                            name: "go-next"
                            width: units.gu(2)
                            height: units.gu(2)
                            color: Theme.gray400
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: splitPage.openGroupDetail(modelData)
                    }
                }
            }

            // Empty state
            EmptyState {
                Layout.fillWidth: true
                Layout.topMargin: units.gu(4)
                visible: groups.length === 0
                iconName: "contact-group"
                title: "No Groups Yet"
                subtitle: "Create a group to start splitting expenses"
                actionText: "Create Group"
                onActionClicked: openCreateGroup()
            }

            Item { Layout.preferredHeight: units.gu(10) }
        }
    }

    // FAB
    LomiriShape {
        anchors {
            right: parent.right
            bottom: parent.bottom
            rightMargin: units.gu(2)
            bottomMargin: units.gu(2)
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
            onClicked: openCreateGroup()
        }
    }

    // ---- Create Group Dialog ----
    Component {
        id: groupDialogComponent

        Dialog {
            id: groupDialog
            title: "Create Group"

            TextField {
                id: groupNameInput
                placeholderText: "Group name (e.g., Goa Trip)"
            }

            TextField {
                id: groupDescInput
                placeholderText: "Description (optional)"
            }

            Label {
                text: "Members (comma-separated)"
                fontSize: "small"
                color: Theme.gray600
            }

            TextField {
                id: groupMembersInput
                placeholderText: "Alice, Bob, You"
            }

            Label {
                id: groupDialogError
                visible: text !== ""
                fontSize: "small"
                color: Theme.expense
                wrapMode: Text.WordWrap
            }

            Button {
                text: "Create"
                color: Theme.primary
                onClicked: splitPage.saveGroup(groupNameInput.text, groupDescInput.text, groupMembersInput.text, groupDialog, groupDialogError)
            }

            Button {
                text: "Cancel"
                onClicked: PopupUtils.close(groupDialog)
            }
        }
    }

    function openCreateGroup() {
        PopupUtils.open(groupDialogComponent)
    }

    function saveGroup(nameText, descText, membersText, dialog, errorLabel) {
        var name = nameText.trim();
        if (name === "") {
            errorLabel.text = "Group name is required.";
            return;
        }
        var memberParts = membersText.split(",");
        var members = [];
        for (var i = 0; i < memberParts.length; i++) {
            var m = memberParts[i].trim();
            if (m !== "") members.push(m);
        }
        if (members.length < 2) {
            errorLabel.text = "Please add at least 2 members (comma-separated).";
            return;
        }
        Database.createSplitGroup(name, descText.trim(), members);
        PopupUtils.close(dialog);
        refreshData();
    }
}
