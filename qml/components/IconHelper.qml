import QtQuick 2.7
import ".."

QtObject {
    id: iconHelper

    readonly property var iconMap: {
        "restaurant": "🍽️",
        "directions_car": "🚗",
        "shopping_bag": "🛍️",
        "movie": "🎬",
        "receipt_long": "📄",
        "local_hospital": "🏥",
        "school": "🎓",
        "spa": "💆",
        "local_grocery_store": "🛒",
        "card_giftcard": "🎁",
        "savings": "💰",
        "show_chart": "📊",
        "family_restroom": "👨‍👩‍👧",
        "more_horiz": "⋯",
        "work": "💼",
        "laptop": "💻",
        "trending_up": "📈",
        "attach_money": "💵",
        "home": "🏠",
        "settings": "⚙️",
        "calendar": "📅",
        "chart": "📊",
        "wallet": "👛",
        "target": "🎯",
        "lightbulb": "💡",
        "warning": "⚠️",
        "error": "❌",
        "check": "✓",
        "add": "+",
        "edit": "✏️",
        "delete": "🗑️",
        "photo": "📷",
        "receipt": "🧾"
    }

    function getEmoji(iconName) {
        return iconMap[iconName] || "📝";
    }
}
