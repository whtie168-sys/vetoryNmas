//
//  VTFAnalyticsEngine.swift
//  Vault Finance
//
//  Pure calculation layer: balances, monthly aggregates, category breakdowns,
//  and trend series. Keeps view controllers free of business math.
//

import Foundation

/// A category total used for breakdowns and charts.
struct VTFCategoryAggregate {
    let category: VTFCategory
    let total: Double
    let transactionCount: Int
}

/// A single point in a monthly trend series.
struct VTFMonthlyPoint {
    let monthStart: Date
    let income: Double
    let expense: Double

    var net: Double { income - expense }
}

/// Summary numbers for a single period.
struct VTFPeriodSummary {
    let income: Double
    let expense: Double
    var balance: Double { income - expense }
    var savingsRate: Double {
        guard income > 0 else { return 0 }
        return max(0, (income - expense) / income)
    }
}

/// Stateless analytics computed over a transaction list.
struct VTFAnalyticsEngine {

    let transactions: [VTFTransaction]

    init(transactions: [VTFTransaction]) {
        self.transactions = transactions
    }

    // MARK: - Balances

    /// Total balance across all transactions: income sum - expense sum.
    func vtfTotalBalance() -> Double {
        return transactions.reduce(0) { $0 + $1.vtfSignedAmount }
    }

    func vtfTotalIncome() -> Double {
        return transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }

    func vtfTotalExpense() -> Double {
        return transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }

    // MARK: - Period summaries

    func vtfSummary(forMonthOf reference: Date) -> VTFPeriodSummary {
        let monthly = VTFDateHelper.vtfTransactions(transactions, inMonthOf: reference)
        let income = monthly.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        let expense = monthly.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        return VTFPeriodSummary(income: income, expense: expense)
    }

    func vtfOverallSummary() -> VTFPeriodSummary {
        return VTFPeriodSummary(income: vtfTotalIncome(), expense: vtfTotalExpense())
    }

    // MARK: - Recent

    /// Most recent transactions, newest first.
    func vtfRecent(limit: Int) -> [VTFTransaction] {
        return transactions
            .sorted { $0.date > $1.date }
            .prefix(limit)
            .map { $0 }
    }

    func vtfSortedByDateDescending() -> [VTFTransaction] {
        return transactions.sorted { $0.date > $1.date }
    }

    // MARK: - Category breakdowns

    /// Expense totals grouped by category (largest first), optionally scoped to a month.
    func vtfExpenseBreakdown(forMonthOf reference: Date? = nil) -> [VTFCategoryAggregate] {
        return vtfBreakdown(type: .expense, reference: reference)
    }

    func vtfIncomeBreakdown(forMonthOf reference: Date? = nil) -> [VTFCategoryAggregate] {
        return vtfBreakdown(type: .income, reference: reference)
    }

    private func vtfBreakdown(type: VTFTransactionType, reference: Date?) -> [VTFCategoryAggregate] {
        let scoped: [VTFTransaction]
        if let reference = reference {
            scoped = VTFDateHelper.vtfTransactions(transactions, inMonthOf: reference)
        } else {
            scoped = transactions
        }
        let filtered = scoped.filter { $0.type == type }
        var totals: [VTFCategory: (Double, Int)] = [:]
        for tx in filtered {
            let cat = VTFCategory.vtfResolve(tx.category)
            let existing = totals[cat] ?? (0, 0)
            totals[cat] = (existing.0 + tx.amount, existing.1 + 1)
        }
        return totals
            .map { VTFCategoryAggregate(category: $0.key, total: $0.value.0, transactionCount: $0.value.1) }
            .sorted { $0.total > $1.total }
    }

    /// Total spend in a category within the month of `reference`.
    func vtfSpent(in category: String, monthOf reference: Date) -> Double {
        return VTFDateHelper.vtfTransactions(transactions, inMonthOf: reference)
            .filter { $0.type == .expense && $0.category == category }
            .reduce(0) { $0 + $1.amount }
    }

    /// All transactions for a category, newest first.
    func vtfTransactions(in category: String) -> [VTFTransaction] {
        return transactions
            .filter { $0.category == category }
            .sorted { $0.date > $1.date }
    }

    // MARK: - Trends

    /// Income/expense series over the last `months` months.
    func vtfMonthlyTrend(months: Int, endingAt reference: Date) -> [VTFMonthlyPoint] {
        return VTFDateHelper.vtfRecentMonths(count: months, endingAt: reference).map { monthStart in
            let monthly = VTFDateHelper.vtfTransactions(transactions, inMonthOf: monthStart)
            let income = monthly.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
            let expense = monthly.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
            return VTFMonthlyPoint(monthStart: monthStart, income: income, expense: expense)
        }
    }

    /// Average daily spend in the month of `reference`.
    func vtfAverageDailySpend(monthOf reference: Date, now: Date) -> Double {
        let monthly = VTFDateHelper.vtfTransactions(transactions, inMonthOf: reference)
            .filter { $0.type == .expense }
        guard monthly.isEmpty == false else { return 0 }
        let total = monthly.reduce(0) { $0 + $1.amount }
        let day = max(1, VTFDateHelper.calendar.component(.day, from: now))
        return total / Double(day)
    }

    /// The single largest expense, if any.
    func vtfLargestExpense() -> VTFTransaction? {
        return transactions.filter { $0.type == .expense }.max { $0.amount < $1.amount }
    }
}
