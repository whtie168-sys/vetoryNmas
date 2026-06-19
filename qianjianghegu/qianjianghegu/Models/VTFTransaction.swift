//
//  VTFTransaction.swift
//  Vault Finance
//
//  Core transaction model. Codable for JSON persistence in UserDefaults.
//

import Foundation

/// The type of a money movement.
enum VTFTransactionType: String, Codable, CaseIterable {
    case income
    case expense

    var vtfDisplayName: String {
        switch self {
        case .income: return "Income"
        case .expense: return "Expense"
        }
    }

    /// Sign applied when summing into a running balance.
    var vtfSignMultiplier: Double {
        switch self {
        case .income: return 1.0
        case .expense: return -1.0
        }
    }
}

/// A single financial record.
struct VTFTransaction: Codable, Equatable, Identifiable {
    let id: UUID
    var title: String
    var amount: Double
    var type: VTFTransactionType
    var category: String
    var date: Date
    var note: String?

    init(id: UUID = UUID(),
         title: String,
         amount: Double,
         type: VTFTransactionType,
         category: String,
         date: Date,
         note: String? = nil) {
        self.id = id
        self.title = title
        self.amount = abs(amount)
        self.type = type
        self.category = category
        self.date = date
        self.note = note
    }

    /// Amount with sign relative to the running balance.
    var vtfSignedAmount: Double {
        return amount * type.vtfSignMultiplier
    }
}

extension VTFTransaction {
    /// A small set of realistic sample records used the very first launch so the
    /// dashboard never looks empty during review.
    static func vtfSampleSeed(referenceDate: Date) -> [VTFTransaction] {
        let calendar = Calendar.current
        func day(_ offset: Int) -> Date {
            return calendar.date(byAdding: .day, value: -offset, to: referenceDate) ?? referenceDate
        }
        return [
            VTFTransaction(title: "Monthly Salary", amount: 5200, type: .income,
                           category: VTFCategory.salary.rawValue, date: day(2), note: "April payroll"),
            VTFTransaction(title: "Grocery Run", amount: 86.40, type: .expense,
                           category: VTFCategory.food.rawValue, date: day(1), note: "Weekly stock-up"),
            VTFTransaction(title: "Metro Card", amount: 30, type: .expense,
                           category: VTFCategory.transport.rawValue, date: day(3)),
            VTFTransaction(title: "New Headphones", amount: 199, type: .expense,
                           category: VTFCategory.shopping.rawValue, date: day(5), note: "Noise cancelling"),
            VTFTransaction(title: "Movie Night", amount: 24, type: .expense,
                           category: VTFCategory.entertainment.rawValue, date: day(4)),
            VTFTransaction(title: "Electricity Bill", amount: 74.20, type: .expense,
                           category: VTFCategory.bills.rawValue, date: day(6)),
            VTFTransaction(title: "Freelance Project", amount: 850, type: .income,
                           category: VTFCategory.other.rawValue, date: day(7), note: "Logo design")
        ]
    }
}
