import QtQuick 2.7
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3
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
    height: units.gu(4.5)
    spacing: units.gu(1)
    clip: true

    model: filters

    delegate: AbstractButton {
        id: filterDelegate
        width: filterLabel.implicitWidth + units.gu(3)
        height: units.gu(4)

        LomiriShape {
            anchors.fill: parent
            aspect: LomiriShape.Flat
            backgroundColor: dateFilterBar.selectedFilter === modelData.key ?
                Theme.primary : "transparent"
            radius: "large"
            relativeRadius: 0.5

            Label {
                id: filterLabel
                anchors.centerIn: parent
                text: modelData.label
                fontSize: "small"
                font.weight: dateFilterBar.selectedFilter === modelData.key ? Font.DemiBold : Font.Normal
                color: dateFilterBar.selectedFilter === modelData.key ? Theme.white : Theme.gray700
            }
        }

        onClicked: {
            dateFilterBar.selectedFilter = modelData.key;
            dateFilterBar.filterChanged(modelData.key);
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
