import QtQuick 2.7
import QtQuick.Layouts 1.3
import ".."

Item {
    id: sharesView

    property int expenseId: -1
    property string currencyCode: "INR"
    property var sharesData: []

    implicitHeight: sharesCol.implicitHeight

    function refresh() {
        if (expenseId > 0) {
            sharesData = Database.getSplitShares(expenseId);
        } else {
            sharesData = [];
        }
    }

    onExpenseIdChanged: refresh()

    Component.onCompleted: refresh()

    ColumnLayout {
        id: sharesCol
        width: parent.width
        spacing: 2

        Repeater {
            model: sharesData

            RowLayout {
                Layout.fillWidth: true

                Rectangle {
                    width: 6
                    height: 6
                    radius: 3
                    color: modelData.is_settled ? Theme.income : Theme.warning
                }

                Text {
                    text: modelData.member_name
                    font.pixelSize: Theme.fontSizeXS
                    color: Theme.gray600
                    Layout.fillWidth: true
                }

                Text {
                    text: Theme.formatFullCurrency(modelData.share_amount, currencyCode)
                    font.pixelSize: Theme.fontSizeXS
                    color: modelData.is_settled ? Theme.income : Theme.gray700
                    font.weight: Font.DemiBold
                }

                Text {
                    text: modelData.is_settled ? "✓" : ""
                    font.pixelSize: Theme.fontSizeXS
                    color: Theme.income
                }
            }
        }
    }
}
