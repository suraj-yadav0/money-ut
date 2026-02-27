import QtQuick 2.7
import QtQuick.Layouts 1.3
import ".."

ListView {
    id: dateFilterBar

    property var filters: [
        { label: "This Week", key: "thisWeek" },
        { label: "Last Week", key: "lastWeek" },
        { label: "This Month", key: "thisMonth" },
        { label: "Last Month", key: "lastMonth" },
        { label: "This Year", key: "thisYear" },
        { label: "All Time", key: "allTime" }
    ]

    property string selectedFilter: "thisMonth"
    signal filterChanged(string filterKey)

    orientation: ListView.Horizontal
    height: 44
    spacing: Theme.spacingSM
    clip: true

    model: filters

    delegate: Rectangle {
        width: filterLabel.implicitWidth + Theme.spacingLG * 2
        height: 36
        radius: Theme.radiusButton

        color: dateFilterBar.selectedFilter === modelData.key ? Theme.primary :
               mouseArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1) :
               "transparent"

        border.width: dateFilterBar.selectedFilter === modelData.key ? 0 : 1
        border.color: Theme.gray300

        Text {
            id: filterLabel
            anchors.centerIn: parent
            text: modelData.label
            font.pixelSize: Theme.fontSizeSM
            font.weight: dateFilterBar.selectedFilter === modelData.key ? Font.SemiBold : Font.Normal
            color: dateFilterBar.selectedFilter === modelData.key ? Theme.white : Theme.gray700
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                dateFilterBar.selectedFilter = modelData.key;
                dateFilterBar.filterChanged(modelData.key);
            }
        }

        Behavior on color {
            ColorAnimation { duration: Theme.animationFast }
        }
    }

    function getDateRange() {
        var now = new Date();
        var startDate, endDate;

        switch (selectedFilter) {
            case "thisWeek":
                var dayOfWeek = now.getDay();
                startDate = new Date(now);
                startDate.setDate(now.getDate() - dayOfWeek);
                endDate = new Date(startDate);
                endDate.setDate(startDate.getDate() + 6);
                break;

            case "lastWeek":
                var lastWeekDay = now.getDay();
                endDate = new Date(now);
                endDate.setDate(now.getDate() - lastWeekDay - 1);
                startDate = new Date(endDate);
                startDate.setDate(endDate.getDate() - 6);
                break;

            case "thisMonth":
                startDate = new Date(now.getFullYear(), now.getMonth(), 1);
                endDate = new Date(now.getFullYear(), now.getMonth() + 1, 0);
                break;

            case "lastMonth":
                startDate = new Date(now.getFullYear(), now.getMonth() - 1, 1);
                endDate = new Date(now.getFullYear(), now.getMonth(), 0);
                break;

            case "thisYear":
                startDate = new Date(now.getFullYear(), 0, 1);
                endDate = new Date(now.getFullYear(), 11, 31);
                break;

            case "allTime":
            default:
                return { startDate: null, endDate: null };
        }

        return {
            startDate: Qt.formatDate(startDate, "yyyy-MM-dd"),
            endDate: Qt.formatDate(endDate, "yyyy-MM-dd")
        };
    }
}
