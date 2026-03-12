pragma Singleton
import QtQuick 2.7
import QtQuick.LocalStorage 2.0

QtObject {
    id: database

    property var db: null
    property bool initialized: false

    // ===== INITIALIZATION =====
    function ensureInitialized() {
        if (!initialized || db === null) {
            init();
        }
    }

    function init() {
        if (initialized && db !== null) return;
        db = LocalStorage.openDatabaseSync("QuantroDB", "1.0", "Quantro Money Manager Database", 1000000);
        createTables();
        seedDefaultData();
        initialized = true;
    }

    function createTables() {
        db.transaction(function(tx) {
            // User Settings table
            tx.executeSql('CREATE TABLE IF NOT EXISTS user_settings (id INTEGER PRIMARY KEY AUTOINCREMENT, monthly_income REAL DEFAULT 0, currency TEXT DEFAULT "INR", is_onboarded INTEGER DEFAULT 0, biometric_enabled INTEGER DEFAULT 0, show_income_chart INTEGER DEFAULT 0, created_at TEXT DEFAULT CURRENT_TIMESTAMP)');

            // Categories table
            tx.executeSql('CREATE TABLE IF NOT EXISTS categories (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT UNIQUE NOT NULL, icon TEXT NOT NULL, monthly_budget REAL, type TEXT DEFAULT "expense", is_default INTEGER DEFAULT 1)');

            // Transactions table
            tx.executeSql('CREATE TABLE IF NOT EXISTS transactions (id INTEGER PRIMARY KEY AUTOINCREMENT, amount REAL NOT NULL, type TEXT NOT NULL, category_id INTEGER NOT NULL, goal_id INTEGER, timestamp TEXT NOT NULL, note TEXT, payment_mode TEXT, receipt_image_path TEXT, is_recurring INTEGER DEFAULT 0, created_at TEXT DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY (category_id) REFERENCES categories(id), FOREIGN KEY (goal_id) REFERENCES goals(id))');

            // Goals table
            tx.executeSql('CREATE TABLE IF NOT EXISTS goals (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, target_amount REAL NOT NULL, deadline TEXT NOT NULL, saved_amount REAL DEFAULT 0, is_active INTEGER DEFAULT 1, is_completed INTEGER DEFAULT 0, created_at TEXT DEFAULT CURRENT_TIMESTAMP)');

            // Goal contributions table
            tx.executeSql('CREATE TABLE IF NOT EXISTS goal_contributions (id INTEGER PRIMARY KEY AUTOINCREMENT, goal_id INTEGER NOT NULL, amount REAL NOT NULL, note TEXT, created_at TEXT DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY (goal_id) REFERENCES goals(id))');

            // Assets table
            tx.executeSql('CREATE TABLE IF NOT EXISTS assets (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, type TEXT NOT NULL, value REAL NOT NULL, is_liability INTEGER DEFAULT 0, note TEXT, created_at TEXT DEFAULT CURRENT_TIMESTAMP, updated_at TEXT DEFAULT CURRENT_TIMESTAMP)');

            // Categorization rules table
            tx.executeSql('CREATE TABLE IF NOT EXISTS categorization_rules (id INTEGER PRIMARY KEY AUTOINCREMENT, keyword TEXT NOT NULL, category_id INTEGER NOT NULL, weight INTEGER DEFAULT 1, FOREIGN KEY (category_id) REFERENCES categories(id))');

            // Split groups table
            tx.executeSql('CREATE TABLE IF NOT EXISTS split_groups (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, description TEXT, created_at TEXT DEFAULT CURRENT_TIMESTAMP)');

            // Split members table
            tx.executeSql('CREATE TABLE IF NOT EXISTS split_members (id INTEGER PRIMARY KEY AUTOINCREMENT, group_id INTEGER NOT NULL, name TEXT NOT NULL, created_at TEXT DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY (group_id) REFERENCES split_groups(id))');

            // Split expenses table
            tx.executeSql('CREATE TABLE IF NOT EXISTS split_expenses (id INTEGER PRIMARY KEY AUTOINCREMENT, group_id INTEGER NOT NULL, description TEXT NOT NULL, amount REAL NOT NULL, paid_by_member_id INTEGER NOT NULL, date TEXT NOT NULL, created_at TEXT DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY (group_id) REFERENCES split_groups(id), FOREIGN KEY (paid_by_member_id) REFERENCES split_members(id))');

            // Split shares table
            tx.executeSql('CREATE TABLE IF NOT EXISTS split_shares (id INTEGER PRIMARY KEY AUTOINCREMENT, expense_id INTEGER NOT NULL, member_id INTEGER NOT NULL, share_amount REAL NOT NULL, is_settled INTEGER DEFAULT 0, settled_at TEXT, FOREIGN KEY (expense_id) REFERENCES split_expenses(id), FOREIGN KEY (member_id) REFERENCES split_members(id))');
        });
    }

    function seedDefaultData() {
        db.transaction(function(tx) {
            // Check if categories already exist
            var result = tx.executeSql('SELECT COUNT(*) as count FROM categories');
            if (result.rows.item(0).count > 0) return;

            // Default expense categories
            var expenseCategories = [
                { name: "Food & Dining", icon: "restaurant" },
                { name: "Transport", icon: "directions_car" },
                { name: "Shopping", icon: "shopping_bag" },
                { name: "Entertainment", icon: "movie" },
                { name: "Bills & Utilities", icon: "receipt_long" },
                { name: "Health", icon: "local_hospital" },
                { name: "Education", icon: "school" },
                { name: "Self Care", icon: "spa" },
                { name: "Groceries", icon: "local_grocery_store" },
                { name: "Gifts", icon: "card_giftcard" },
                { name: "Savings", icon: "savings" },
                { name: "Investments", icon: "show_chart" },
                { name: "Family", icon: "family_restroom" },
                { name: "Other", icon: "more_horiz" }
            ];

            for (var i = 0; i < expenseCategories.length; i++) {
                tx.executeSql('INSERT INTO categories (name, icon, type, is_default) VALUES (?, ?, "expense", 1)',
                    [expenseCategories[i].name, expenseCategories[i].icon]);
            }

            // Default income categories
            var incomeCategories = [
                { name: "Salary", icon: "work" },
                { name: "Freelance", icon: "laptop" },
                { name: "Investment", icon: "trending_up" },
                { name: "Other Income", icon: "attach_money" }
            ];

            for (var j = 0; j < incomeCategories.length; j++) {
                tx.executeSql('INSERT INTO categories (name, icon, type, is_default) VALUES (?, ?, "income", 1)',
                    [incomeCategories[j].name, incomeCategories[j].icon]);
            }

            // Default categorization rules
            var rules = [
                { keywords: ["zomato", "swiggy", "restaurant", "cafe", "food", "lunch", "dinner", "breakfast", "mcdonalds", "kfc", "dominos", "pizza"], category: "Food & Dining" },
                { keywords: ["uber", "ola", "rapido", "petrol", "fuel", "metro", "bus", "train", "taxi", "auto"], category: "Transport" },
                { keywords: ["amazon", "flipkart", "myntra", "ajio", "nykaa", "shopping"], category: "Shopping" },
                { keywords: ["netflix", "prime", "hotstar", "movie", "spotify", "youtube", "cinema", "theatre"], category: "Entertainment" },
                { keywords: ["electricity", "water", "internet", "mobile", "rent", "wifi", "gas", "recharge"], category: "Bills & Utilities" },
                { keywords: ["bigbasket", "blinkit", "zepto", "instamart", "grocery", "vegetables", "fruits"], category: "Groceries" },
                { keywords: ["hospital", "doctor", "medicine", "pharmacy", "medical", "clinic", "health"], category: "Health" },
                { keywords: ["school", "college", "tuition", "course", "books", "education", "fees"], category: "Education" },
                { keywords: ["salon", "spa", "haircut", "grooming", "skincare", "beauty"], category: "Self Care" },
                { keywords: ["gift", "present", "birthday", "anniversary"], category: "Gifts" },
                { keywords: ["salary", "paycheck", "wage"], category: "Salary" },
                { keywords: ["freelance", "consulting", "contract", "project"], category: "Freelance" }
            ];

            for (var k = 0; k < rules.length; k++) {
                var catResult = tx.executeSql('SELECT id FROM categories WHERE name = ?', [rules[k].category]);
                if (catResult.rows.length > 0) {
                    var catId = catResult.rows.item(0).id;
                    for (var m = 0; m < rules[k].keywords.length; m++) {
                        tx.executeSql('INSERT INTO categorization_rules (keyword, category_id, weight) VALUES (?, ?, 1)',
                            [rules[k].keywords[m], catId]);
                    }
                }
            }
        });
    }

    // ===== USER SETTINGS =====
    function getUserSettings() {
        ensureInitialized();
        var settings = null;
        db.transaction(function(tx) {
            var result = tx.executeSql('SELECT * FROM user_settings LIMIT 1');
            if (result.rows.length > 0) {
                settings = result.rows.item(0);
            }
        });
        return settings;
    }

    function createUserSettings(monthlyIncome, currency) {
        db.transaction(function(tx) {
            tx.executeSql('INSERT INTO user_settings (monthly_income, currency, is_onboarded) VALUES (?, ?, 1)',
                [monthlyIncome, currency || "INR"]);
        });
    }

    function updateUserSettings(monthlyIncome, currency) {
        db.transaction(function(tx) {
            var result = tx.executeSql('SELECT COUNT(*) as count FROM user_settings');
            if (result.rows.item(0).count === 0) {
                tx.executeSql('INSERT INTO user_settings (monthly_income, currency, is_onboarded) VALUES (?, ?, 1)',
                    [monthlyIncome, currency || "INR"]);
            } else {
                tx.executeSql('UPDATE user_settings SET monthly_income = ?, currency = ?, is_onboarded = 1 WHERE id = 1',
                    [monthlyIncome, currency || "INR"]);
            }
        });
    }

    function isOnboarded() {
        ensureInitialized();
        var onboarded = false;
        db.transaction(function(tx) {
            var result = tx.executeSql('SELECT is_onboarded FROM user_settings LIMIT 1');
            if (result.rows.length > 0) {
                onboarded = result.rows.item(0).is_onboarded === 1;
            }
        });
        return onboarded;
    }

    // ===== CATEGORIES =====
    function getCategories(type) {
        ensureInitialized();
        var categories = [];
        db.transaction(function(tx) {
            var sql = type ? 'SELECT * FROM categories WHERE type = ? ORDER BY name' :
                           'SELECT * FROM categories ORDER BY type, name';
            var params = type ? [type] : [];
            var result = tx.executeSql(sql, params);
            for (var i = 0; i < result.rows.length; i++) {
                categories.push(result.rows.item(i));
            }
        });
        return categories;
    }

    function getCategoryById(id) {
        var category = null;
        db.transaction(function(tx) {
            var result = tx.executeSql('SELECT * FROM categories WHERE id = ?', [id]);
            if (result.rows.length > 0) {
                category = result.rows.item(0);
            }
        });
        return category;
    }

    function updateCategoryBudget(categoryId, budget) {
        db.transaction(function(tx) {
            tx.executeSql('UPDATE categories SET monthly_budget = ? WHERE id = ?', [budget, categoryId]);
        });
    }

    function clearCategoryBudget(categoryId) {
        db.transaction(function(tx) {
            tx.executeSql('UPDATE categories SET monthly_budget = NULL WHERE id = ?', [categoryId]);
        });
    }

    // ===== TRANSACTIONS =====
    function addTransaction(amount, type, categoryId, note, paymentMode, timestamp, goalId, receiptPath, isRecurring) {
        ensureInitialized();
        var insertedId = -1;
        db.transaction(function(tx) {
            var result = tx.executeSql(
                'INSERT INTO transactions (amount, type, category_id, note, payment_mode, timestamp, goal_id, receipt_image_path, is_recurring) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
                [amount, type, categoryId, note || null, paymentMode || null, timestamp || new Date().toISOString(), goalId || null, receiptPath || null, isRecurring ? 1 : 0]
            );
            insertedId = result.insertId;
        });

        // Update goal saved amount if linked
        if (goalId && type === "expense") {
            updateGoalSavedAmount(goalId, amount);
        }

        // Learn categorization from this transaction
        if (note) {
            learnFromTransaction(note, categoryId);
        }

        return insertedId;
    }

    function updateTransaction(id, amount, type, categoryId, note, paymentMode, timestamp, goalId, receiptPath) {
        db.transaction(function(tx) {
            tx.executeSql(
                'UPDATE transactions SET amount = ?, type = ?, category_id = ?, note = ?, payment_mode = ?, timestamp = ?, goal_id = ?, receipt_image_path = ? WHERE id = ?',
                [amount, type, categoryId, note || null, paymentMode || null, timestamp, goalId || null, receiptPath || null, id]
            );
        });
    }

    function deleteTransaction(id) {
        // First get the transaction to check if goal linked
        var transaction = getTransactionById(id);
        if (transaction && transaction.goal_id && transaction.type === "expense") {
            // Subtract from goal
            updateGoalSavedAmount(transaction.goal_id, -transaction.amount);
        }

        db.transaction(function(tx) {
            tx.executeSql('DELETE FROM transactions WHERE id = ?', [id]);
        });
    }

    function getTransactionById(id) {
        ensureInitialized();
        var transaction = null;
        db.transaction(function(tx) {
            var result = tx.executeSql(
                'SELECT t.*, c.name as category_name, c.icon as category_icon FROM transactions t ' +
                'LEFT JOIN categories c ON t.category_id = c.id WHERE t.id = ?', [id]
            );
            if (result.rows.length > 0) {
                transaction = result.rows.item(0);
            }
        });
        return transaction;
    }

    function getTransactions(startDate, endDate, type, limit) {
        ensureInitialized();
        var transactions = [];
        db.transaction(function(tx) {
            var sql = 'SELECT t.*, c.name as category_name, c.icon as category_icon, g.name as goal_name FROM transactions t ' +
                      'LEFT JOIN categories c ON t.category_id = c.id ' +
                      'LEFT JOIN goals g ON t.goal_id = g.id WHERE 1=1';
            var params = [];

            if (startDate) {
                sql += ' AND date(t.timestamp) >= date(?)';
                params.push(startDate);
            }
            if (endDate) {
                sql += ' AND date(t.timestamp) <= date(?)';
                params.push(endDate);
            }
            if (type) {
                sql += ' AND t.type = ?';
                params.push(type);
            }

            sql += ' ORDER BY t.timestamp DESC';

            if (limit) {
                sql += ' LIMIT ?';
                params.push(limit);
            }

            var result = tx.executeSql(sql, params);
            for (var i = 0; i < result.rows.length; i++) {
                transactions.push(result.rows.item(i));
            }
        });
        return transactions;
    }

    function getRecentTransactions(count) {
        return getTransactions(null, null, null, count || 5);
    }

    function getTransactionsByDate(date) {
        var dateStr = Qt.formatDate(new Date(date), "yyyy-MM-dd");
        return getTransactions(dateStr, dateStr, null, null);
    }

    function getTransactionsGroupedByDate(startDate, endDate) {
        var transactions = getTransactions(startDate, endDate, null, null);
        var grouped = {};

        for (var i = 0; i < transactions.length; i++) {
            var t = transactions[i];
            var dateKey = Qt.formatDate(new Date(t.timestamp), "yyyy-MM-dd");
            if (!grouped[dateKey]) {
                grouped[dateKey] = [];
            }
            grouped[dateKey].push(t);
        }

        return grouped;
    }

    // ===== DASHBOARD STATS =====
    function getDashboardStats(startDate, endDate) {
        ensureInitialized();
        var stats = {
            totalIncome: 0,
            totalExpenses: 0,
            balance: 0,
            categoryBreakdown: [],
            dailyData: []
        };

        db.transaction(function(tx) {
            var params = [];
            var dateFilter = '';

            if (startDate && endDate) {
                dateFilter = ' AND date(timestamp) >= date(?) AND date(timestamp) <= date(?)';
                params = [startDate, endDate];
            }

            // Total income
            var incomeResult = tx.executeSql(
                'SELECT COALESCE(SUM(amount), 0) as total FROM transactions WHERE type = "income"' + dateFilter, params
            );
            stats.totalIncome = incomeResult.rows.item(0).total;

            // Total expenses (excluding goal-linked)
            var expenseResult = tx.executeSql(
                'SELECT COALESCE(SUM(amount), 0) as total FROM transactions WHERE type = "expense" AND goal_id IS NULL' + dateFilter, params
            );
            stats.totalExpenses = expenseResult.rows.item(0).total;

            stats.balance = stats.totalIncome - stats.totalExpenses;

            // Category breakdown for expenses
            var catParams = params.slice();
            var catResult = tx.executeSql(
                'SELECT c.id, c.name, c.icon, COALESCE(SUM(t.amount), 0) as total FROM transactions t ' +
                'LEFT JOIN categories c ON t.category_id = c.id ' +
                'WHERE t.type = "expense"' + dateFilter +
                ' GROUP BY c.id ORDER BY total DESC', catParams
            );

            for (var i = 0; i < catResult.rows.length; i++) {
                var row = catResult.rows.item(i);
                stats.categoryBreakdown.push({
                    categoryId: row.id,
                    categoryName: row.name,
                    categoryIcon: row.icon,
                    amount: row.total,
                    percentage: stats.totalExpenses > 0 ? (row.total / stats.totalExpenses * 100) : 0
                });
            }

            // Daily data for trend chart
            var dailyResult = tx.executeSql(
                'SELECT date(timestamp) as day, type, SUM(amount) as total FROM transactions ' +
                'WHERE 1=1' + dateFilter +
                ' GROUP BY date(timestamp), type ORDER BY day', params
            );

            var dailyMap = {};
            for (var j = 0; j < dailyResult.rows.length; j++) {
                var dayRow = dailyResult.rows.item(j);
                if (!dailyMap[dayRow.day]) {
                    dailyMap[dayRow.day] = { date: dayRow.day, income: 0, expense: 0 };
                }
                if (dayRow.type === "income") {
                    dailyMap[dayRow.day].income = dayRow.total;
                } else {
                    dailyMap[dayRow.day].expense = dayRow.total;
                }
            }

            for (var day in dailyMap) {
                stats.dailyData.push(dailyMap[day]);
            }
            stats.dailyData.sort(function(a, b) { return a.date.localeCompare(b.date); });
        });

        return stats;
    }

    // ===== BUDGET =====
    function getBudgetStats(month, year) {
        var stats = {
            totalBudget: 0,
            totalSpent: 0,
            categories: []
        };

        db.transaction(function(tx) {
            var startDate = year + '-' + String(month).padStart(2, '0') + '-01';
            var endDate = year + '-' + String(month).padStart(2, '0') + '-31';

            // Get categories with budgets
            var catResult = tx.executeSql('SELECT * FROM categories WHERE monthly_budget IS NOT NULL AND monthly_budget > 0 ORDER BY name');

            for (var i = 0; i < catResult.rows.length; i++) {
                var cat = catResult.rows.item(i);

                // Get spending for this category (excluding goal-linked)
                var spentResult = tx.executeSql(
                    'SELECT COALESCE(SUM(amount), 0) as total FROM transactions ' +
                    'WHERE category_id = ? AND goal_id IS NULL AND date(timestamp) >= date(?) AND date(timestamp) <= date(?)',
                    [cat.id, startDate, endDate]
                );

                var spent = spentResult.rows.item(0).total;

                stats.categories.push({
                    categoryId: cat.id,
                    categoryName: cat.name,
                    categoryIcon: cat.icon,
                    budget: cat.monthly_budget,
                    spent: spent,
                    remaining: cat.monthly_budget - spent,
                    percentUsed: cat.monthly_budget > 0 ? (spent / cat.monthly_budget) : 0
                });

                stats.totalBudget += cat.monthly_budget;
                stats.totalSpent += spent;
            }

            // Sort by percentage used (descending)
            stats.categories.sort(function(a, b) { return b.percentUsed - a.percentUsed; });
        });

        stats.totalRemaining = stats.totalBudget - stats.totalSpent;
        stats.percentUsed = stats.totalBudget > 0 ? (stats.totalSpent / stats.totalBudget) : 0;

        return stats;
    }

    function getCategoryAverageSpending(categoryId, months) {
        var average = 0;
        db.transaction(function(tx) {
            var result = tx.executeSql(
                'SELECT COALESCE(AVG(monthly_total), 0) as avg_spending FROM (' +
                'SELECT strftime("%Y-%m", timestamp) as month, SUM(amount) as monthly_total FROM transactions ' +
                'WHERE category_id = ? AND type = "expense" AND goal_id IS NULL ' +
                'GROUP BY strftime("%Y-%m", timestamp) ' +
                'ORDER BY month DESC LIMIT ?' +
                ')', [categoryId, months || 3]
            );
            average = result.rows.item(0).avg_spending;
        });
        return Math.ceil(average / 100) * 100; // Round up to nearest 100
    }

    // ===== GOALS =====
    function addGoal(name, targetAmount, deadline) {
        var insertedId = -1;
        db.transaction(function(tx) {
            var result = tx.executeSql(
                'INSERT INTO goals (name, target_amount, deadline) VALUES (?, ?, ?)',
                [name, targetAmount, deadline]
            );
            insertedId = result.insertId;
        });
        return insertedId;
    }

    function updateGoal(id, name, targetAmount, deadline) {
        db.transaction(function(tx) {
            tx.executeSql(
                'UPDATE goals SET name = ?, target_amount = ?, deadline = ? WHERE id = ?',
                [name, targetAmount, deadline, id]
            );
        });
    }

    function deleteGoal(id) {
        db.transaction(function(tx) {
            // Delete contributions first
            tx.executeSql('DELETE FROM goal_contributions WHERE goal_id = ?', [id]);
            // Delete goal
            tx.executeSql('DELETE FROM goals WHERE id = ?', [id]);
        });
    }

    function getGoals(activeOnly) {
        var goals = [];
        db.transaction(function(tx) {
            var sql = activeOnly ?
                'SELECT * FROM goals WHERE is_active = 1 ORDER BY deadline' :
                'SELECT * FROM goals ORDER BY is_active DESC, deadline';
            var result = tx.executeSql(sql);
            for (var i = 0; i < result.rows.length; i++) {
                var goal = result.rows.item(i);
                goal.daysLeft = Math.ceil((new Date(goal.deadline) - new Date()) / (1000 * 60 * 60 * 24));
                goal.percentComplete = goal.target_amount > 0 ? (goal.saved_amount / goal.target_amount * 100) : 0;
                goals.push(goal);
            }
        });
        return goals;
    }

    function getGoalById(id) {
        var goal = null;
        db.transaction(function(tx) {
            var result = tx.executeSql('SELECT * FROM goals WHERE id = ?', [id]);
            if (result.rows.length > 0) {
                goal = result.rows.item(0);
                goal.daysLeft = Math.ceil((new Date(goal.deadline) - new Date()) / (1000 * 60 * 60 * 24));
                goal.percentComplete = goal.target_amount > 0 ? (goal.saved_amount / goal.target_amount * 100) : 0;
            }
        });
        return goal;
    }

    function updateGoalSavedAmount(goalId, amountDelta) {
        db.transaction(function(tx) {
            tx.executeSql('UPDATE goals SET saved_amount = saved_amount + ? WHERE id = ?', [amountDelta, goalId]);

            // Check if goal is completed
            var result = tx.executeSql('SELECT * FROM goals WHERE id = ?', [goalId]);
            if (result.rows.length > 0) {
                var goal = result.rows.item(0);
                if (goal.saved_amount >= goal.target_amount) {
                    tx.executeSql('UPDATE goals SET is_completed = 1 WHERE id = ?', [goalId]);
                }
            }
        });
    }

    // ===== GOAL CONTRIBUTIONS =====
    function addContribution(goalId, amount, note) {
        db.transaction(function(tx) {
            tx.executeSql(
                'INSERT INTO goal_contributions (goal_id, amount, note) VALUES (?, ?, ?)',
                [goalId, amount, note || null]
            );
            tx.executeSql('UPDATE goals SET saved_amount = saved_amount + ? WHERE id = ?', [amount, goalId]);

            // Check completion
            var result = tx.executeSql('SELECT * FROM goals WHERE id = ?', [goalId]);
            if (result.rows.length > 0 && result.rows.item(0).saved_amount >= result.rows.item(0).target_amount) {
                tx.executeSql('UPDATE goals SET is_completed = 1 WHERE id = ?', [goalId]);
            }
        });
    }

    function deleteContribution(id) {
        db.transaction(function(tx) {
            // Get contribution details first
            var result = tx.executeSql('SELECT * FROM goal_contributions WHERE id = ?', [id]);
            if (result.rows.length > 0) {
                var contribution = result.rows.item(0);
                // Subtract from goal
                tx.executeSql('UPDATE goals SET saved_amount = saved_amount - ?, is_completed = 0 WHERE id = ?',
                    [contribution.amount, contribution.goal_id]);
                // Delete contribution
                tx.executeSql('DELETE FROM goal_contributions WHERE id = ?', [id]);
            }
        });
    }

    function getContributions(goalId) {
        var contributions = [];
        db.transaction(function(tx) {
            var result = tx.executeSql(
                'SELECT * FROM goal_contributions WHERE goal_id = ? ORDER BY created_at DESC', [goalId]
            );
            for (var i = 0; i < result.rows.length; i++) {
                contributions.push(result.rows.item(i));
            }
        });
        return contributions;
    }

    // ===== ASSETS =====
    function addAsset(name, type, value, isLiability, note) {
        db.transaction(function(tx) {
            tx.executeSql(
                'INSERT INTO assets (name, type, value, is_liability, note) VALUES (?, ?, ?, ?, ?)',
                [name, type, Math.abs(value), isLiability ? 1 : 0, note || null]
            );
        });
    }

    function updateAsset(id, name, type, value, isLiability, note) {
        db.transaction(function(tx) {
            tx.executeSql(
                'UPDATE assets SET name = ?, type = ?, value = ?, is_liability = ?, note = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
                [name, type, Math.abs(value), isLiability ? 1 : 0, note || null, id]
            );
        });
    }

    function deleteAsset(id) {
        db.transaction(function(tx) {
            tx.executeSql('DELETE FROM assets WHERE id = ?', [id]);
        });
    }

    function getAssets(typeFilter) {
        var assets = [];
        db.transaction(function(tx) {
            var sql = typeFilter ?
                'SELECT * FROM assets WHERE type = ? ORDER BY created_at DESC' :
                'SELECT * FROM assets ORDER BY created_at DESC';
            var params = typeFilter ? [typeFilter] : [];
            var result = tx.executeSql(sql, params);
            for (var i = 0; i < result.rows.length; i++) {
                assets.push(result.rows.item(i));
            }
        });
        return assets;
    }

    function getNetWorthData() {
        var data = {
            totalAssets: 0,
            totalLiabilities: 0,
            totalIncome: 0,
            totalExpenses: 0,
            goalSavings: 0,
            netWorth: 0
        };

        db.transaction(function(tx) {
            // Assets
            var assetsResult = tx.executeSql('SELECT COALESCE(SUM(value), 0) as total FROM assets WHERE is_liability = 0');
            data.totalAssets = assetsResult.rows.item(0).total;

            // Liabilities
            var liabResult = tx.executeSql('SELECT COALESCE(SUM(value), 0) as total FROM assets WHERE is_liability = 1');
            data.totalLiabilities = liabResult.rows.item(0).total;

            // All-time income
            var incomeResult = tx.executeSql('SELECT COALESCE(SUM(amount), 0) as total FROM transactions WHERE type = "income"');
            data.totalIncome = incomeResult.rows.item(0).total;

            // All-time expenses
            var expenseResult = tx.executeSql('SELECT COALESCE(SUM(amount), 0) as total FROM transactions WHERE type = "expense"');
            data.totalExpenses = expenseResult.rows.item(0).total;

            // Goal savings
            var goalsResult = tx.executeSql('SELECT COALESCE(SUM(saved_amount), 0) as total FROM goals');
            data.goalSavings = goalsResult.rows.item(0).total;
        });

        var cashflow = data.totalIncome - data.totalExpenses;
        data.netWorth = cashflow + data.totalAssets - data.totalLiabilities + data.goalSavings;

        return data;
    }

    function getMonthlyNetWorth() {
        var months = [];
        db.transaction(function(tx) {
            var result = tx.executeSql(
                'SELECT strftime("%Y-%m", timestamp) as month, type, SUM(amount) as total ' +
                'FROM transactions GROUP BY strftime("%Y-%m", timestamp), type ORDER BY month'
            );

            var monthMap = {};
            for (var i = 0; i < result.rows.length; i++) {
                var row = result.rows.item(i);
                if (!monthMap[row.month]) {
                    monthMap[row.month] = { income: 0, expenses: 0 };
                }
                if (row.type === "income") {
                    monthMap[row.month].income = row.total;
                } else {
                    monthMap[row.month].expenses = row.total;
                }
            }

            var cumulative = 0;
            var sortedMonths = Object.keys(monthMap).sort();
            for (var j = 0; j < sortedMonths.length; j++) {
                var m = sortedMonths[j];
                var monthData = monthMap[m];
                var net = monthData.income - monthData.expenses;
                cumulative += net;
                months.push({
                    month: m,
                    income: monthData.income,
                    expenses: monthData.expenses,
                    net: net,
                    cumulativeNetWorth: cumulative
                });
            }
        });
        return months;
    }

    // ===== AUTO-CATEGORIZATION =====
    function suggestCategory(note) {
        if (!note || note.trim().length === 0) return null;

        var suggestion = null;
        var maxWeight = 0;

        db.transaction(function(tx) {
            var words = note.toLowerCase().split(/\s+/);
            var categoryWeights = {};

            for (var i = 0; i < words.length; i++) {
                var word = words[i];
                if (word.length < 3) continue;

                var result = tx.executeSql(
                    'SELECT r.category_id, r.weight, c.name, c.icon FROM categorization_rules r ' +
                    'LEFT JOIN categories c ON r.category_id = c.id ' +
                    'WHERE LOWER(?) LIKE "%" || LOWER(r.keyword) || "%"', [word]
                );

                for (var j = 0; j < result.rows.length; j++) {
                    var rule = result.rows.item(j);
                    if (!categoryWeights[rule.category_id]) {
                        categoryWeights[rule.category_id] = { weight: 0, name: rule.name, icon: rule.icon };
                    }
                    categoryWeights[rule.category_id].weight += rule.weight;
                }
            }

            for (var catId in categoryWeights) {
                if (categoryWeights[catId].weight > maxWeight) {
                    maxWeight = categoryWeights[catId].weight;
                    suggestion = {
                        categoryId: parseInt(catId),
                        categoryName: categoryWeights[catId].name,
                        categoryIcon: categoryWeights[catId].icon
                    };
                }
            }
        });

        return suggestion;
    }

    function learnFromTransaction(note, categoryId) {
        if (!note || note.trim().length === 0) return;

        db.transaction(function(tx) {
            var words = note.toLowerCase().split(/\s+/);

            for (var i = 0; i < words.length; i++) {
                var word = words[i].replace(/[^a-z0-9]/g, '');
                if (word.length < 3) continue;

                // Check if rule exists
                var result = tx.executeSql(
                    'SELECT * FROM categorization_rules WHERE keyword = ? AND category_id = ?',
                    [word, categoryId]
                );

                if (result.rows.length > 0) {
                    // Increment weight
                    tx.executeSql(
                        'UPDATE categorization_rules SET weight = weight + 1 WHERE keyword = ? AND category_id = ?',
                        [word, categoryId]
                    );
                } else {
                    // Create new rule
                    tx.executeSql(
                        'INSERT INTO categorization_rules (keyword, category_id, weight) VALUES (?, ?, 1)',
                        [word, categoryId]
                    );
                }
            }
        });
    }

    // ===== RECURRING TRANSACTIONS =====
    function processRecurringTransactions() {
        db.transaction(function(tx) {
            var now = new Date();
            var currentMonth = now.getMonth() + 1;
            var currentYear = now.getFullYear();
            var monthStart = currentYear + '-' + String(currentMonth).padStart(2, '0') + '-01';
            var monthEnd = currentYear + '-' + String(currentMonth).padStart(2, '0') + '-31';

            // Get all recurring templates
            var templates = tx.executeSql('SELECT * FROM transactions WHERE is_recurring = 1');

            for (var i = 0; i < templates.rows.length; i++) {
                var template = templates.rows.item(i);

                // Check if transaction already exists this month
                var existing = tx.executeSql(
                    'SELECT COUNT(*) as count FROM transactions WHERE category_id = ? AND type = ? AND is_recurring = 0 AND date(timestamp) >= date(?) AND date(timestamp) <= date(?)',
                    [template.category_id, template.type, monthStart, monthEnd]
                );

                if (existing.rows.item(0).count === 0) {
                    // Create new instance
                    var newDate = currentYear + '-' + String(currentMonth).padStart(2, '0') + '-01T00:00:00.000Z';
                    tx.executeSql(
                        'INSERT INTO transactions (amount, type, category_id, note, payment_mode, timestamp, is_recurring) VALUES (?, ?, ?, ?, ?, ?, 0)',
                        [template.amount, template.type, template.category_id, template.note, template.payment_mode, newDate]
                    );
                }
            }
        });
    }

    function createSalaryTransaction(amount) {
        var now = new Date();
        var firstOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

        db.transaction(function(tx) {
            // Get salary category
            var catResult = tx.executeSql('SELECT id FROM categories WHERE name = "Salary" LIMIT 1');
            if (catResult.rows.length > 0) {
                var salaryId = catResult.rows.item(0).id;

                // Check if salary exists this month
                var monthStart = Qt.formatDate(firstOfMonth, "yyyy-MM-01");
                var monthEnd = Qt.formatDate(firstOfMonth, "yyyy-MM-31");

                var existing = tx.executeSql(
                    'SELECT * FROM transactions WHERE category_id = ? AND type = "income" AND date(timestamp) >= date(?) AND date(timestamp) <= date(?)',
                    [salaryId, monthStart, monthEnd]
                );

                if (existing.rows.length > 0) {
                    // Update existing
                    tx.executeSql('UPDATE transactions SET amount = ? WHERE id = ?', [amount, existing.rows.item(0).id]);
                } else {
                    // Create new
                    tx.executeSql(
                        'INSERT INTO transactions (amount, type, category_id, note, timestamp, is_recurring) VALUES (?, "income", ?, "Monthly Salary", ?, 1)',
                        [amount, salaryId, firstOfMonth.toISOString()]
                    );
                }
            }
        });
    }

    // ===== CALENDAR DATA =====
    function getCalendarData(month, year) {
        var data = {};
        db.transaction(function(tx) {
            var startDate = year + '-' + String(month).padStart(2, '0') + '-01';
            var endDate = year + '-' + String(month).padStart(2, '0') + '-31';

            var result = tx.executeSql(
                'SELECT date(timestamp) as day, type, SUM(amount) as total, COUNT(*) as count ' +
                'FROM transactions WHERE date(timestamp) >= date(?) AND date(timestamp) <= date(?) ' +
                'GROUP BY date(timestamp), type', [startDate, endDate]
            );

            for (var i = 0; i < result.rows.length; i++) {
                var row = result.rows.item(i);
                if (!data[row.day]) {
                    data[row.day] = { income: 0, expense: 0, count: 0 };
                }
                if (row.type === "income") {
                    data[row.day].income = row.total;
                } else {
                    data[row.day].expense = row.total;
                }
                data[row.day].count += row.count;
            }
        });
        return data;
    }

    function getMonthTotals(month, year) {
        var totals = { income: 0, expenses: 0, net: 0 };
        db.transaction(function(tx) {
            var startDate = year + '-' + String(month).padStart(2, '0') + '-01';
            var endDate = year + '-' + String(month).padStart(2, '0') + '-31';

            var result = tx.executeSql(
                'SELECT type, COALESCE(SUM(amount), 0) as total FROM transactions ' +
                'WHERE date(timestamp) >= date(?) AND date(timestamp) <= date(?) GROUP BY type',
                [startDate, endDate]
            );

            for (var i = 0; i < result.rows.length; i++) {
                var row = result.rows.item(i);
                if (row.type === "income") {
                    totals.income = row.total;
                } else {
                    totals.expenses = row.total;
                }
            }
            totals.net = totals.income - totals.expenses;
        });
        return totals;
    }

    // ===== INSIGHTS ENGINE =====
    function generateInsights() {
        var insights = [];
        var settings = getUserSettings();
        var monthlyIncome = settings ? settings.monthly_income : 0;

        var now = new Date();
        var currentMonth = now.getMonth() + 1;
        var currentYear = now.getFullYear();
        var daysInMonth = new Date(currentYear, currentMonth, 0).getDate();
        var dayOfMonth = now.getDate();

        var monthStart = currentYear + '-' + String(currentMonth).padStart(2, '0') + '-01';
        var monthEnd = currentYear + '-' + String(currentMonth).padStart(2, '0') + '-31';

        db.transaction(function(tx) {
            // 1. Spending Spike Detection
            var todayStr = Qt.formatDate(now, "yyyy-MM-dd");
            var todaySpending = tx.executeSql(
                'SELECT COALESCE(SUM(amount), 0) as total FROM transactions WHERE type = "expense" AND date(timestamp) = date(?)',
                [todayStr]
            ).rows.item(0).total;

            var avgDaily = tx.executeSql(
                'SELECT COALESCE(AVG(daily_total), 0) as avg FROM (' +
                'SELECT date(timestamp) as day, SUM(amount) as daily_total FROM transactions ' +
                'WHERE type = "expense" AND date(timestamp) >= date(?) GROUP BY date(timestamp))',
                [monthStart]
            ).rows.item(0).avg;

            if (todaySpending > avgDaily * 2 && todaySpending > 0) {
                insights.push({
                    type: "spendingSpike",
                    severity: "critical",
                    title: "Spending Spike Detected!",
                    description: "Today's spending is " + (todaySpending / avgDaily).toFixed(1) + "x higher than average.",
                    tip: "Review your transactions and identify any unnecessary expenses."
                });
            }

            // 2. Category Dominance
            var totalExpenses = tx.executeSql(
                'SELECT COALESCE(SUM(amount), 0) as total FROM transactions WHERE type = "expense" AND date(timestamp) >= date(?) AND date(timestamp) <= date(?)',
                [monthStart, monthEnd]
            ).rows.item(0).total;

            if (totalExpenses > 0) {
                var catDominance = tx.executeSql(
                    'SELECT c.name, SUM(t.amount) as total FROM transactions t ' +
                    'LEFT JOIN categories c ON t.category_id = c.id ' +
                    'WHERE t.type = "expense" AND date(t.timestamp) >= date(?) AND date(t.timestamp) <= date(?) ' +
                    'GROUP BY c.id ORDER BY total DESC LIMIT 1',
                    [monthStart, monthEnd]
                );

                if (catDominance.rows.length > 0) {
                    var topCat = catDominance.rows.item(0);
                    var dominancePercent = topCat.total / totalExpenses;

                    if (dominancePercent > 0.4) {
                        insights.push({
                            type: "categoryDominance",
                            severity: "warning",
                            title: topCat.name + " Dominates Spending",
                            description: Math.round(dominancePercent * 100) + "% of expenses are in " + topCat.name + ".",
                            tip: "Consider diversifying your spending or setting a budget for this category."
                        });
                    }
                }
            }

            // 3. Budget Pace Tracking
            if (monthlyIncome > 0) {
                var expectedProgress = dayOfMonth / daysInMonth;
                var spendingProgress = totalExpenses / monthlyIncome;

                if (spendingProgress > expectedProgress * 1.2) {
                    var severity = spendingProgress > expectedProgress * 1.5 ? "critical" : "warning";
                    insights.push({
                        type: "budgetPace",
                        severity: severity,
                        title: "Spending Ahead of Pace",
                        description: "You've spent " + Math.round(spendingProgress * 100) + "% of income but we're only " + Math.round(expectedProgress * 100) + "% through the month.",
                        tip: "Try to reduce spending for the remaining days."
                    });
                }
            }

            // 4. Weekend Spending Analysis
            var weekdayAvg = tx.executeSql(
                'SELECT COALESCE(AVG(daily_total), 0) as avg FROM (' +
                'SELECT date(timestamp) as day, SUM(amount) as daily_total FROM transactions ' +
                'WHERE type = "expense" AND cast(strftime("%w", timestamp) as integer) BETWEEN 1 AND 5 ' +
                'GROUP BY date(timestamp))'
            ).rows.item(0).avg;

            var weekendAvg = tx.executeSql(
                'SELECT COALESCE(AVG(daily_total), 0) as avg FROM (' +
                'SELECT date(timestamp) as day, SUM(amount) as daily_total FROM transactions ' +
                'WHERE type = "expense" AND cast(strftime("%w", timestamp) as integer) IN (0, 6) ' +
                'GROUP BY date(timestamp))'
            ).rows.item(0).avg;

            if (weekendAvg > weekdayAvg * 1.8 && weekendAvg > 0) {
                insights.push({
                    type: "weekendSpending",
                    severity: "info",
                    title: "Weekend Spending Higher",
                    description: "Your weekend spending averages " + (weekendAvg / weekdayAvg).toFixed(1) + "x more than weekdays.",
                    tip: "Plan weekend activities with a budget in mind."
                });
            }

            // 5. Forecast Warning
            if (monthlyIncome > 0 && dayOfMonth > 1) {
                var dailyBurnRate = totalExpenses / dayOfMonth;
                var projectedMonthEnd = dailyBurnRate * daysInMonth;
                var projectedBalance = monthlyIncome - projectedMonthEnd;
                var percentRemaining = projectedBalance / monthlyIncome;

                if (projectedBalance < 0) {
                    insights.push({
                        type: "forecast",
                        severity: "critical",
                        title: "Deficit Projected!",
                        description: "At current pace, you'll exceed your income by " + Theme.formatCurrency(Math.abs(projectedBalance)),
                        tip: "Reduce daily spending to avoid going over budget.",
                        actionText: "View Budget"
                    });
                } else if (percentRemaining < 0.1) {
                    insights.push({
                        type: "forecast",
                        severity: "warning",
                        title: "Low Savings Projected",
                        description: "Only " + Math.round(percentRemaining * 100) + "% of income will remain at month end.",
                        tip: "Look for areas to cut back on spending."
                    });
                }
            }
        });

        return insights;
    }

    // ===== SPLIT FEATURE =====

    function createSplitGroup(name, description, memberNames) {
        ensureInitialized();
        var groupId = -1;
        db.transaction(function(tx) {
            tx.executeSql('INSERT INTO split_groups (name, description) VALUES (?, ?)',
                [name, description || ""]);
            var res = tx.executeSql('SELECT last_insert_rowid() as id');
            groupId = res.rows.item(0).id;
            for (var i = 0; i < memberNames.length; i++) {
                if (memberNames[i].trim() !== "") {
                    tx.executeSql('INSERT INTO split_members (group_id, name) VALUES (?, ?)',
                        [groupId, memberNames[i].trim()]);
                }
            }
        });
        return groupId;
    }

    function getSplitGroups() {
        ensureInitialized();
        var groups = [];
        db.transaction(function(tx) {
            var result = tx.executeSql('SELECT g.*, (SELECT COUNT(*) FROM split_members WHERE group_id = g.id) as member_count, (SELECT COUNT(*) FROM split_expenses WHERE group_id = g.id) as expense_count FROM split_groups g ORDER BY g.created_at DESC');
            for (var i = 0; i < result.rows.length; i++) {
                groups.push(result.rows.item(i));
            }
        });
        return groups;
    }

    function getSplitGroupById(groupId) {
        ensureInitialized();
        var group = null;
        db.transaction(function(tx) {
            var result = tx.executeSql('SELECT * FROM split_groups WHERE id = ?', [groupId]);
            if (result.rows.length > 0) {
                group = result.rows.item(0);
            }
        });
        return group;
    }

    function getSplitMembers(groupId) {
        ensureInitialized();
        var members = [];
        db.transaction(function(tx) {
            var result = tx.executeSql('SELECT * FROM split_members WHERE group_id = ? ORDER BY name', [groupId]);
            for (var i = 0; i < result.rows.length; i++) {
                members.push(result.rows.item(i));
            }
        });
        return members;
    }

    function addSplitExpense(groupId, description, amount, paidByMemberId, date, shares) {
        // shares: array of { memberId, shareAmount }
        ensureInitialized();
        var expenseId = -1;
        db.transaction(function(tx) {
            tx.executeSql('INSERT INTO split_expenses (group_id, description, amount, paid_by_member_id, date) VALUES (?, ?, ?, ?, ?)',
                [groupId, description, amount, paidByMemberId, date]);
            var res = tx.executeSql('SELECT last_insert_rowid() as id');
            expenseId = res.rows.item(0).id;
            for (var i = 0; i < shares.length; i++) {
                tx.executeSql('INSERT INTO split_shares (expense_id, member_id, share_amount) VALUES (?, ?, ?)',
                    [expenseId, shares[i].memberId, shares[i].shareAmount]);
            }
        });
        return expenseId;
    }

    function getSplitExpenses(groupId) {
        ensureInitialized();
        var expenses = [];
        db.transaction(function(tx) {
            var result = tx.executeSql(
                'SELECT e.*, m.name as paid_by_name FROM split_expenses e JOIN split_members m ON e.paid_by_member_id = m.id WHERE e.group_id = ? ORDER BY e.date DESC, e.created_at DESC',
                [groupId]);
            for (var i = 0; i < result.rows.length; i++) {
                expenses.push(result.rows.item(i));
            }
        });
        return expenses;
    }

    function getSplitShares(expenseId) {
        ensureInitialized();
        var shares = [];
        db.transaction(function(tx) {
            var result = tx.executeSql(
                'SELECT s.*, m.name as member_name FROM split_shares s JOIN split_members m ON s.member_id = m.id WHERE s.expense_id = ? ORDER BY m.name',
                [expenseId]);
            for (var i = 0; i < result.rows.length; i++) {
                shares.push(result.rows.item(i));
            }
        });
        return shares;
    }

    // Returns balances: array of { fromMemberId, fromName, toMemberId, toName, amount }
    function getSplitGroupBalances(groupId) {
        ensureInitialized();
        var members = getSplitMembers(groupId);
        // Build net balance map: how much each member owes/is owed
        var balance = {};
        for (var i = 0; i < members.length; i++) {
            balance[members[i].id] = 0;
        }

        db.transaction(function(tx) {
            // For each expense, payer is owed back shares from others
            var expenses = tx.executeSql(
                'SELECT e.paid_by_member_id, s.member_id, s.share_amount, s.is_settled FROM split_expenses e JOIN split_shares s ON s.expense_id = e.id WHERE e.group_id = ? AND s.is_settled = 0',
                [groupId]);
            for (var j = 0; j < expenses.rows.length; j++) {
                var row = expenses.rows.item(j);
                var payer = row.paid_by_member_id;
                var debtor = row.member_id;
                if (payer !== debtor) {
                    // debtor owes payer share_amount
                    if (balance[debtor] !== undefined) balance[debtor] -= row.share_amount;
                    if (balance[payer] !== undefined) balance[payer] += row.share_amount;
                }
            }
        });

        // Simplify debts: generate minimal transactions
        var BALANCE_EPSILON = 0.005;
        var creditors = [];
        var debtors = [];
        for (var mid in balance) {
            if (balance[mid] > BALANCE_EPSILON) {
                creditors.push({ id: parseInt(mid), amount: balance[mid] });
            } else if (balance[mid] < -BALANCE_EPSILON) {
                debtors.push({ id: parseInt(mid), amount: -balance[mid] });
            }
        }

        // Build member name map
        var nameMap = {};
        for (var k = 0; k < members.length; k++) {
            nameMap[members[k].id] = members[k].name;
        }

        var settlements = [];
        var ci = 0;
        var di = 0;
        while (ci < creditors.length && di < debtors.length) {
            var credit = creditors[ci];
            var debt = debtors[di];
            var settled = Math.min(credit.amount, debt.amount);
            settlements.push({
                fromMemberId: debt.id,
                fromName: nameMap[debt.id] || "?",
                toMemberId: credit.id,
                toName: nameMap[credit.id] || "?",
                amount: settled
            });
            credit.amount -= settled;
            debt.amount -= settled;
            if (credit.amount < BALANCE_EPSILON) ci++;
            if (debt.amount < BALANCE_EPSILON) di++;
        }
        return settlements;
    }

    function settleExpenseShare(shareId) {
        ensureInitialized();
        db.transaction(function(tx) {
            tx.executeSql('UPDATE split_shares SET is_settled = 1, settled_at = CURRENT_TIMESTAMP WHERE id = ?', [shareId]);
        });
    }

    // Settle all unsettled shares between two members in a group
    function settleBetweenMembers(groupId, fromMemberId, toMemberId) {
        ensureInitialized();
        db.transaction(function(tx) {
            // from owes to: shares where payer=to and member=from
            tx.executeSql(
                'UPDATE split_shares SET is_settled = 1, settled_at = CURRENT_TIMESTAMP WHERE is_settled = 0 AND member_id = ? AND expense_id IN (SELECT id FROM split_expenses WHERE group_id = ? AND paid_by_member_id = ?)',
                [fromMemberId, groupId, toMemberId]);
        });
    }

    function deleteSplitExpense(expenseId) {
        ensureInitialized();
        db.transaction(function(tx) {
            tx.executeSql('DELETE FROM split_shares WHERE expense_id = ?', [expenseId]);
            tx.executeSql('DELETE FROM split_expenses WHERE id = ?', [expenseId]);
        });
    }

    function deleteSplitGroup(groupId) {
        ensureInitialized();
        db.transaction(function(tx) {
            tx.executeSql('DELETE FROM split_shares WHERE expense_id IN (SELECT id FROM split_expenses WHERE group_id = ?)', [groupId]);
            tx.executeSql('DELETE FROM split_expenses WHERE group_id = ?', [groupId]);
            tx.executeSql('DELETE FROM split_members WHERE group_id = ?', [groupId]);
            tx.executeSql('DELETE FROM split_groups WHERE id = ?', [groupId]);
        });
    }

    // ===== DATA MANAGEMENT =====
    function clearAllData() {
        db.transaction(function(tx) {
            tx.executeSql('DELETE FROM transactions');
            tx.executeSql('DELETE FROM goals');
            tx.executeSql('DELETE FROM goal_contributions');
            tx.executeSql('DELETE FROM assets');
            tx.executeSql('DELETE FROM user_settings');
            tx.executeSql('DELETE FROM categorization_rules');
            // Re-seed categories and rules
            tx.executeSql('DELETE FROM categories');
        });
        seedDefaultData();
    }

    function exportData() {
        var data = {
            settings: getUserSettings(),
            transactions: getTransactions(null, null, null, null),
            categories: getCategories(),
            goals: getGoals(false),
            assets: getAssets(),
            exportDate: new Date().toISOString()
        };
        return JSON.stringify(data, null, 2);
    }

    Component.onCompleted: {
        init();
    }
}
