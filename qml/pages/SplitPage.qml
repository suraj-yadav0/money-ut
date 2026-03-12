import QtQuick 2.7
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3
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
        contentHeight: contentColumn.height + Theme.spacing2XL
        clip: true

        ColumnLayout {
            id: contentColumn
            width: parent.width - Theme.spacingLG * 2
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.spacingLG

            Item { Layout.preferredHeight: Theme.spacingSM }

            // Info banner
            GlassCard {
                Layout.fillWidth: true

                RowLayout {
                    spacing: Theme.spacingMD

                    Text {
                        text: "🤝"
                        font.pixelSize: 28
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: "Split Expenses"
                            font.pixelSize: Theme.fontSizeLG
                            font.weight: Font.DemiBold
                            color: Theme.gray900
                        }

                        Text {
                            text: "Track shared expenses with friends & groups"
                            font.pixelSize: Theme.fontSizeSM
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
                        spacing: Theme.spacingMD

                        // Group icon circle
                        Rectangle {
                            width: 44
                            height: 44
                            radius: 22
                            color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12)

                            Text {
                                anchors.centerIn: parent
                                text: "👥"
                                font.pixelSize: 20
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: modelData.name
                                font.pixelSize: Theme.fontSizeLG
                                font.weight: Font.DemiBold
                                color: Theme.gray900
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Text {
                                text: modelData.member_count + " members · " + modelData.expense_count + " expenses"
                                font.pixelSize: Theme.fontSizeSM
                                color: Theme.gray500
                            }
                        }

                        Text {
                            text: "›"
                            font.pixelSize: 22
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
                Layout.topMargin: Theme.spacing3XL
                visible: groups.length === 0
                emoji: "🤝"
                title: "No Groups Yet"
                subtitle: "Create a group to start splitting expenses"
                actionText: "Create Group"
                onActionClicked: openCreateGroup()
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
            onClicked: openCreateGroup()
        }
    }

    // ---- Create Group Dialog ----
    property bool showGroupDialog: false
    property string groupDialogError: ""

    Rectangle {
        id: groupDialogOverlay
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.5)
        visible: showGroupDialog
        z: 20

        MouseArea {
            anchors.fill: parent
            onClicked: showGroupDialog = false
        }

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: groupDialogContent.implicitHeight + Theme.spacing2XL
            radius: Theme.radiusXL
            color: Theme.white

            MouseArea {
                anchors.fill: parent
            }

            ColumnLayout {
                id: groupDialogContent
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: Theme.spacingLG
                }
                spacing: Theme.spacingMD

                Text {
                    text: "Create Group"
                    font.pixelSize: Theme.fontSizeXL
                    font.weight: Font.Bold
                    color: Theme.gray900
                }

                // Group name
                TextField {
                    id: groupNameInput
                    Layout.fillWidth: true
                    placeholderText: "Group name (e.g., Goa Trip)"
                }

                // Description
                TextField {
                    id: groupDescInput
                    Layout.fillWidth: true
                    placeholderText: "Description (optional)"
                }

                Text {
                    text: "Members (comma-separated)"
                    font.pixelSize: Theme.fontSizeSM
                    color: Theme.gray600
                }

                TextField {
                    id: groupMembersInput
                    Layout.fillWidth: true
                    placeholderText: "Alice, Bob, You"
                }

                // Error message
                Text {
                    visible: groupDialogError !== ""
                    text: groupDialogError
                    font.pixelSize: Theme.fontSizeSM
                    color: Theme.expense
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                // Buttons
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingMD

                    Rectangle {
                        Layout.fillWidth: true
                        height: 44
                        radius: Theme.radiusButton
                        color: Theme.gray100

                        Text {
                            anchors.centerIn: parent
                            text: "Cancel"
                            font.pixelSize: Theme.fontSizeMD
                            color: Theme.gray700
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: showGroupDialog = false
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 44
                        radius: Theme.radiusButton
                        color: Theme.primary

                        Text {
                            anchors.centerIn: parent
                            text: "Create"
                            font.pixelSize: Theme.fontSizeMD
                            font.weight: Font.DemiBold
                            color: Theme.white
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: saveGroup()
                        }
                    }
                }

                Item { Layout.preferredHeight: Theme.spacingSM }
            }
        }
    }

    function openCreateGroup() {
        groupNameInput.text = "";
        groupDescInput.text = "";
        groupMembersInput.text = "";
        groupDialogError = "";
        showGroupDialog = true;
    }

    function saveGroup() {
        var name = groupNameInput.text.trim();
        if (name === "") {
            groupDialogError = "Group name is required.";
            return;
        }
        var memberParts = groupMembersInput.text.split(",");
        var members = [];
        for (var i = 0; i < memberParts.length; i++) {
            var m = memberParts[i].trim();
            if (m !== "") members.push(m);
        }
        if (members.length < 2) {
            groupDialogError = "Please add at least 2 members (comma-separated).";
            return;
        }
        Database.createSplitGroup(name, groupDescInput.text.trim(), members);
        showGroupDialog = false;
        refreshData();
    }
}
