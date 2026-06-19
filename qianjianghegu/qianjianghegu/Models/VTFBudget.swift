//
//  VTFBudget.swift
//  Vault Finance
//
//  Per-category monthly budget model used by the Budget screen.
//

import Foundation

/// A monthly spending budget attached to a category.
struct VTFBudget: Codable, Equatable, Identifiable {
    let id: UUID
    var category: String
    var monthlyLimit: Double

    init(id: UUID = UUID(), category: String, monthlyLimit: Double) {
        self.id = id
        self.category = category
        self.monthlyLimit = max(0, monthlyLimit)
    }
}

/// Computed progress of a budget against actual spending in a period.
struct VTFBudgetProgress {
    let budget: VTFBudget
    let spent: Double

    var remaining: Double { max(0, budget.monthlyLimit - spent) }

    var fraction: Double {
        guard budget.monthlyLimit > 0 else { return 0 }
        return min(1.0, spent / budget.monthlyLimit)
    }

    var isOverBudget: Bool { spent > budget.monthlyLimit && budget.monthlyLimit > 0 }
}
