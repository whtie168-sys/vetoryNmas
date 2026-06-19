//
//  VTFBudgetManager.swift
//  Vault Finance
//
//  Manages per-category budgets and computes progress against spending.
//

import Foundation

/// Owns budget CRUD and progress computation.
final class VTFBudgetManager {

    static let shared = VTFBudgetManager()

    private let storage = VTFStorageManager.shared

    private init() {}

    func vtfAllBudgets() -> [VTFBudget] {
        return storage.vtfLoadBudgets().sorted { $0.category < $1.category }
    }

    func vtfBudget(for category: String) -> VTFBudget? {
        return storage.vtfLoadBudgets().first { $0.category == category }
    }

    /// Insert or update a budget for a category.
    func vtfSetBudget(category: String, monthlyLimit: Double) {
        var budgets = storage.vtfLoadBudgets()
        if let index = budgets.firstIndex(where: { $0.category == category }) {
            budgets[index].monthlyLimit = max(0, monthlyLimit)
        } else {
            budgets.append(VTFBudget(category: category, monthlyLimit: monthlyLimit))
        }
        storage.vtfSaveBudgets(budgets)
    }

    func vtfRemoveBudget(for category: String) {
        var budgets = storage.vtfLoadBudgets()
        budgets.removeAll { $0.category == category }
        storage.vtfSaveBudgets(budgets)
    }

    /// Compute progress for every budget in the month of `reference`.
    func vtfProgress(transactions: [VTFTransaction], monthOf reference: Date) -> [VTFBudgetProgress] {
        let engine = VTFAnalyticsEngine(transactions: transactions)
        return vtfAllBudgets().map { budget in
            let spent = engine.vtfSpent(in: budget.category, monthOf: reference)
            return VTFBudgetProgress(budget: budget, spent: spent)
        }
    }

    /// Total budgeted amount across all categories.
    func vtfTotalBudgeted() -> Double {
        return storage.vtfLoadBudgets().reduce(0) { $0 + $1.monthlyLimit }
    }
}
