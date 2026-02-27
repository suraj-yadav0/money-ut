pragma Singleton
import QtQuick 2.7

QtObject {
    id: theme

    // ===== COLOR PALETTE =====
    // Primary / Accent - Orange
    readonly property color primary: "#FF5F1F"
    readonly property color primaryLight: "#FF8F50"
    readonly property color primaryDark: "#CC4C19"

    // Secondary - Blue
    readonly property color secondary: "#00C6FF"

    // Income / Success - Green
    readonly property color income: "#10B981"
    readonly property color success: "#10B981"

    // Expense / Danger - Red
    readonly property color expense: "#FF0033"
    readonly property color danger: "#FF0033"

    // Warning - Yellow/Orange
    readonly property color warning: "#F59E0B"
    readonly property color caution: "#FCD34D"

    // Error
    readonly property color error: "#EF4444"

    // Neutrals
    readonly property color white: "#FFFFFF"
    readonly property color black: "#000000"
    readonly property color gray50: "#FAFAFA"
    readonly property color gray100: "#F4F4F5"
    readonly property color gray200: "#E4E4E7"
    readonly property color gray300: "#D4D4D8"
    readonly property color gray400: "#A1A1AA"
    readonly property color gray500: "#71717A"
    readonly property color gray600: "#52525B"
    readonly property color gray700: "#3F3F46"
    readonly property color gray800: "#27272A"
    readonly property color gray900: "#18181B"

    // Light mode backgrounds
    readonly property color lightBg1: "#FFFFFF"
    readonly property color lightBg2: "#FFFBF5"
    readonly property color lightBg3: "#FFF5EB"

    // Dark mode backgrounds
    readonly property color darkBg1: "#0A0A0A"
    readonly property color darkBg2: "#1A0F0A"
    readonly property color darkBg3: "#1F1512"

    // Glass effects
    readonly property real glassOpacityLight: 0.65
    readonly property real glassOpacityDark: 0.1
    readonly property int glassBlur: 20

    // Chart colors (10 color palette)
    readonly property var chartColors: [
        "#FF5F1F", "#00C6FF", "#FF0033", "#10B981", "#FFD700",
        "#7C3AED", "#EC4899", "#DC2626", "#4F46E5", "#059669"
    ]

    // ===== SPACING & SIZING =====
    readonly property int spacingXS: 4
    readonly property int spacingSM: 8
    readonly property int spacingMD: 12
    readonly property int spacingLG: 16
    readonly property int spacingXL: 20
    readonly property int spacing2XL: 24
    readonly property int spacing3XL: 32

    // Border radius
    readonly property int radiusSM: 8
    readonly property int radiusMD: 12
    readonly property int radiusLG: 16
    readonly property int radiusXL: 20
    readonly property int radiusCard: 20
    readonly property int radiusButton: 16

    // ===== TYPOGRAPHY =====
    readonly property int fontSizeXS: 10
    readonly property int fontSizeSM: 12
    readonly property int fontSizeMD: 14
    readonly property int fontSizeLG: 16
    readonly property int fontSizeXL: 18
    readonly property int fontSize2XL: 20
    readonly property int fontSize3XL: 24
    readonly property int fontSize4XL: 32
    readonly property int fontSize5XL: 40

    // Font weights
    readonly property int fontWeightLight: Font.Light
    readonly property int fontWeightNormal: Font.Normal
    readonly property int fontWeightMedium: Font.Medium
    readonly property int fontWeightSemiBold: Font.DemiBold
    readonly property int fontWeightBold: Font.Bold

    // ===== ANIMATIONS =====
    readonly property int animationFast: 150
    readonly property int animationNormal: 250
    readonly property int animationSlow: 400

    // ===== BUDGET THRESHOLDS =====
    readonly property real budgetCautionThreshold: 0.8  // 80%
    readonly property real budgetDangerThreshold: 1.0   // 100%

    // ===== INSIGHT THRESHOLDS =====
    readonly property real spendingSpikeFactor: 2.0
    readonly property real categoryDominanceThreshold: 0.4
    readonly property real safeBalanceThreshold: 0.2
    readonly property real weekendSpikeFactor: 1.8

    // ===== CURRENCIES =====
    readonly property var currencies: [
        { code: "INR", symbol: "₹", name: "Indian Rupee" },
        { code: "USD", symbol: "$", name: "US Dollar" },
        { code: "EUR", symbol: "€", name: "Euro" },
        { code: "GBP", symbol: "£", name: "British Pound" },
        { code: "JPY", symbol: "¥", name: "Japanese Yen" }
    ]

    // ===== PAYMENT MODES =====
    readonly property var paymentModes: [
        "Cash", "UPI", "Debit Card", "Credit Card", "Net Banking"
    ]

    // ===== ASSET TYPES =====
    readonly property var assetTypes: [
        { type: "savings", emoji: "💰", name: "Savings" },
        { type: "investment", emoji: "📈", name: "Investment" },
        { type: "property", emoji: "🏠", name: "Property" },
        { type: "gold", emoji: "🥇", name: "Gold" },
        { type: "loan", emoji: "🏦", name: "Loan" },
        { type: "other", emoji: "📦", name: "Other" }
    ]

    // ===== HELPER FUNCTIONS =====
    function getCurrencySymbol(code) {
        for (var i = 0; i < currencies.length; i++) {
            if (currencies[i].code === code) {
                return currencies[i].symbol;
            }
        }
        return "₹";
    }

    function formatCurrency(amount, currencyCode) {
        var symbol = getCurrencySymbol(currencyCode || "INR");
        var absAmount = Math.abs(amount);
        var formatted;

        // Indian number system for INR
        if (currencyCode === "INR" || !currencyCode) {
            if (absAmount >= 10000000) {
                formatted = (absAmount / 10000000).toFixed(2) + " Cr";
            } else if (absAmount >= 100000) {
                formatted = (absAmount / 100000).toFixed(2) + " L";
            } else if (absAmount >= 1000) {
                formatted = (absAmount / 1000).toFixed(1) + "K";
            } else {
                formatted = absAmount.toFixed(0);
            }
        } else {
            if (absAmount >= 1000000) {
                formatted = (absAmount / 1000000).toFixed(2) + "M";
            } else if (absAmount >= 1000) {
                formatted = (absAmount / 1000).toFixed(1) + "K";
            } else {
                formatted = absAmount.toFixed(0);
            }
        }

        return (amount < 0 ? "-" : "") + symbol + formatted;
    }

    function formatCompactCurrency(amount, currencyCode) {
        var symbol = getCurrencySymbol(currencyCode || "INR");
        var absAmount = Math.abs(amount);
        var formatted;

        if (absAmount >= 100000) {
            formatted = (absAmount / 100000).toFixed(1) + "L";
        } else if (absAmount >= 1000) {
            formatted = (absAmount / 1000).toFixed(0) + "K";
        } else {
            formatted = absAmount.toFixed(0);
        }

        return (amount < 0 ? "-" : "") + symbol + formatted;
    }

    function formatFullCurrency(amount, currencyCode) {
        var symbol = getCurrencySymbol(currencyCode || "INR");
        var absAmount = Math.abs(amount);

        // Format with Indian/standard separators
        var formatted = absAmount.toLocaleString('en-IN', { maximumFractionDigits: 2 });

        return (amount < 0 ? "-" : "") + symbol + formatted;
    }

    function getBudgetColor(percentUsed) {
        if (percentUsed >= budgetDangerThreshold) {
            return danger;
        } else if (percentUsed >= budgetCautionThreshold) {
            return warning;
        }
        return primary;
    }

    function getInsightColor(severity) {
        switch (severity) {
            case "critical": return danger;
            case "warning": return warning;
            default: return secondary;
        }
    }

    function getSmartDateHeader(date) {
        var today = new Date();
        today.setHours(0, 0, 0, 0);

        var compareDate = new Date(date);
        compareDate.setHours(0, 0, 0, 0);

        var diffDays = Math.floor((today - compareDate) / (1000 * 60 * 60 * 24));

        if (diffDays === 0) return "Today";
        if (diffDays === 1) return "Yesterday";
        if (diffDays < 7) {
            var days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
            return days[compareDate.getDay()];
        }

        return Qt.formatDate(compareDate, "MMM d, yyyy");
    }

    function formatTime(date) {
        return Qt.formatTime(new Date(date), "h:mm AP");
    }

    function formatDate(date) {
        return Qt.formatDate(new Date(date), "MMM d, yyyy");
    }

    function formatMonthYear(date) {
        return Qt.formatDate(new Date(date), "MMMM yyyy");
    }
}
