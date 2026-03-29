import QtQuick 2.7
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3
import ".."
import "../components"

Page {
    id: addSplitExpensePage

    property int groupId: -1
    property var members: []
    property string currencyCode: "INR"
    property string splitMode: "equal"

    signal expenseSaved()
    signal cancelled()

    // ListModel to track share amounts for each member
    ListModel {
        id: sharesModel
    }

    function loadGroup(gid, mems) {
        groupId = gid;
        members = mems;
        splitMode = "equal";
        var settings = Database.getUserSettings();
        if (settings) currencyCode = settings.currency || "INR";
        sharesModel.clear();
        for (var i = 0; i < mems.length; i++) {
            sharesModel.append({ memberId: mems[i].id, memberName: mems[i].name, shareAmount: "0" });
        }
    }

    function updateEqualShares() {
        if (splitMode !== "equal") return;
        var amt = parseFloat(amountInput.text) || 0;
        var count = sharesModel.count;
        if (count === 0) return;
        var each = (amt / count).toFixed(2);
        for (var i = 0; i < sharesModel.count; i++) {
            sharesModel.setProperty(i, "shareAmount", each);
        }
    }

    header: PageHeader {
        id: header
        title: "Add Expense"
        leadingActionBar.actions: [
            Action {
                iconName: "back"
                text: "Back"
                onTriggered: addSplitExpensePage.cancelled()
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
        contentHeight: formColumn.height + Theme.spacing3XL
        clip: true

        ColumnLayout {
            id: formColumn
            width: parent.width - Theme.spacingLG * 2
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.spacingLG

            Item { Layout.preferredHeight: Theme.spacingSM }

            // Description
            GlassCard {
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: Theme.spacingSM

                    Text {
                        text: "Description"
                        font.pixelSize: Theme.fontSizeSM
                        color: Theme.gray600
                        font.weight: Font.DemiBold
                    }

                    TextField {
                        id: descriptionInput
                        Layout.fillWidth: true
                        placeholderText: "e.g., Dinner, Hotel, Cab"
                    }
                }
            }

            // Amount
            GlassCard {
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: Theme.spacingSM

                    Text {
                        text: "Total Amount"
                        font.pixelSize: Theme.fontSizeSM
                        color: Theme.gray600
                        font.weight: Font.DemiBold
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacingSM

                        Text {
                            text: Theme.getCurrencySymbol(currencyCode)
                            font.pixelSize: Theme.fontSizeXL
                            color: Theme.gray500
                            font.weight: Font.DemiBold
                        }

                        TextField {
                            id: amountInput
                            Layout.fillWidth: true
                            placeholderText: "0"
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            font.pixelSize: Theme.fontSize2XL
                            font.weight: Font.Bold
                            onTextChanged: updateEqualShares()
                        }
                    }
                }
            }

            // Paid by
            GlassCard {
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: Theme.spacingSM

                    Text {
                        text: "Paid by"
                        font.pixelSize: Theme.fontSizeSM
                        color: Theme.gray600
                        font.weight: Font.DemiBold
                    }

                    Flow {
                        Layout.fillWidth: true
                        spacing: Theme.spacingSM

                        Repeater {
                            id: paidByRepeater
                            model: sharesModel

                            property int selectedIndex: 0

                            Rectangle {
                                width: paidByLabel.width + Theme.spacingLG
                                height: 32
                                radius: 16
                                color: paidByRepeater.selectedIndex === index
                                    ? Theme.primary
                                    : Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1)

                                Text {
                                    id: paidByLabel
                                    anchors.centerIn: parent
                                    text: model.memberName
                                    font.pixelSize: Theme.fontSizeSM
                                    font.weight: Font.DemiBold
                                    color: paidByRepeater.selectedIndex === index ? Theme.white : Theme.primary
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: paidByRepeater.selectedIndex = index
                                }
                            }
                        }
                    }
                }
            }

            // Date
            GlassCard {
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: Theme.spacingSM

                    Text {
                        text: "Date"
                        font.pixelSize: Theme.fontSizeSM
                        color: Theme.gray600
                        font.weight: Font.DemiBold
                    }

                    TextField {
                        id: dateInput
                        Layout.fillWidth: true
                        placeholderText: "YYYY-MM-DD"
                        text: Qt.formatDate(new Date(), "yyyy-MM-dd")
                        inputMask: "0000-00-00;_"
                        validator: RegExpValidator {
                            regExp: /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/
                        }
                        onEditingFinished: {
                            var parts = text.split("-");
                            if (parts.length !== 3) {
                                text = Qt.formatDate(new Date(), "yyyy-MM-dd");
                                return;
                            }
                            var year = parseInt(parts[0], 10);
                            var month = parseInt(parts[1], 10) - 1;
                            var day = parseInt(parts[2], 10);
                            var d = new Date(year, month, day);
                            if (isNaN(d.getTime()) ||
                                    d.getFullYear() !== year ||
                                    d.getMonth() !== month ||
                                    d.getDate() !== day) {
                                text = Qt.formatDate(new Date(), "yyyy-MM-dd");
                            } else {
                                text = Qt.formatDate(d, "yyyy-MM-dd");
                            }
                        }
                    }
                }
            }

            // Split mode
            GlassCard {
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: Theme.spacingMD

                    Text {
                        text: "Split"
                        font.pixelSize: Theme.fontSizeSM
                        color: Theme.gray600
                        font.weight: Font.DemiBold
                    }

                    // Mode selector
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacingSM

                        Rectangle {
                            Layout.fillWidth: true
                            height: 36
                            radius: Theme.radiusMD
                            color: splitMode === "equal" ? Theme.primary : Theme.gray100

                            Text {
                                anchors.centerIn: parent
                                text: "Equal"
                                font.pixelSize: Theme.fontSizeSM
                                font.weight: Font.DemiBold
                                color: splitMode === "equal" ? Theme.white : Theme.gray600
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    splitMode = "equal";
                                    updateEqualShares();
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 36
                            radius: Theme.radiusMD
                            color: splitMode === "custom" ? Theme.primary : Theme.gray100

                            Text {
                                anchors.centerIn: parent
                                text: "Custom"
                                font.pixelSize: Theme.fontSizeSM
                                font.weight: Font.DemiBold
                                color: splitMode === "custom" ? Theme.white : Theme.gray600
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: splitMode = "custom"
                            }
                        }
                    }

                    // Per-member amounts
                    Repeater {
                        id: sharesRepeater
                        model: sharesModel

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Theme.spacingSM

                            Text {
                                text: model.memberName
                                font.pixelSize: Theme.fontSizeSM
                                color: Theme.gray700
                                font.weight: Font.DemiBold
                                Layout.preferredWidth: 80
                                elide: Text.ElideRight
                            }

                            Text {
                                text: Theme.getCurrencySymbol(currencyCode)
                                font.pixelSize: Theme.fontSizeSM
                                color: Theme.gray500
                            }

                            TextField {
                                Layout.fillWidth: true
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                                readOnly: splitMode === "equal"
                                text: model.shareAmount
                                color: splitMode === "equal" ? Theme.gray500 : Theme.gray900
                                onTextChanged: {
                                    if (splitMode === "custom") {
                                        sharesModel.setProperty(index, "shareAmount", text);
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Validation error
            Text {
                id: validationError
                visible: text !== ""
                font.pixelSize: Theme.fontSizeSM
                color: Theme.expense
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            // Save button
            Rectangle {
                Layout.fillWidth: true
                height: 50
                radius: Theme.radiusButton
                color: Theme.primary

                Text {
                    anchors.centerIn: parent
                    text: "Save Expense"
                    font.pixelSize: Theme.fontSizeLG
                    font.weight: Font.DemiBold
                    color: Theme.white
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: saveExpense()
                }
            }

            Item { Layout.preferredHeight: Theme.spacingLG }
        }
    }

    function saveExpense() {
        var desc = descriptionInput.text.trim();
        var amt = parseFloat(amountInput.text) || 0;
        var date = dateInput.text.trim();

        if (desc === "") {
            validationError.text = "Please enter a description.";
            return;
        }
        if (amt <= 0) {
            validationError.text = "Please enter a valid amount greater than 0.";
            return;
        }
        if (date === "") {
            validationError.text = "Please enter a date.";
            return;
        }
        if (sharesModel.count === 0) {
            validationError.text = "No members in this group.";
            return;
        }

        var paidByIndex = paidByRepeater.selectedIndex;
        if (paidByIndex < 0 || paidByIndex >= sharesModel.count) return;
        var paidByMemberId = sharesModel.get(paidByIndex).memberId;

        var shares = [];
        if (splitMode === "equal") {
            // Use the already-rounded UI values to avoid rounding drift
            for (var i = 0; i < sharesModel.count; i++) {
                var equalShareAmt = parseFloat(sharesModel.get(i).shareAmount) || 0;
                shares.push({ memberId: sharesModel.get(i).memberId, shareAmount: equalShareAmt });
            }
        } else {
            var totalShares = 0;
            for (var j = 0; j < sharesModel.count; j++) {
                var rawShare = sharesModel.get(j).shareAmount;
                var shareAmt = parseFloat(rawShare);
                if (rawShare === "" || rawShare === null || rawShare === undefined || isNaN(shareAmt)) {
                    validationError.text = "Please enter valid numeric share amounts for all members.";
                    return;
                }
                if (shareAmt < 0) {
                    validationError.text = "Share amounts cannot be negative.";
                    return;
                }
                totalShares += shareAmt;
                shares.push({ memberId: sharesModel.get(j).memberId, shareAmount: shareAmt });
            }
            var epsilon = 0.01; // Tolerance for floating-point rounding in share sums
            if (Math.abs(totalShares - amt) > epsilon) {
                validationError.text = "The sum of all shares (" + totalShares.toFixed(2) + ") must equal the total amount (" + amt.toFixed(2) + ").";
                return;
            }
        }

        validationError.text = "";
        Database.addSplitExpense(groupId, desc, amt, paidByMemberId, date, shares);
        addSplitExpensePage.expenseSaved();
    }
}
