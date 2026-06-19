//
//  VTFCategory.swift
//  Vault Finance
//
//  Fixed category set as required by the spec, enriched with display metadata
//  (icon + accent colour) so the UI can render premium category chips.
//

import UIKit

/// The fixed category list defined by the spec.
enum VTFCategory: String, Codable, CaseIterable {
    case food = "Food"
    case transport = "Transport"
    case shopping = "Shopping"
    case entertainment = "Entertainment"
    case bills = "Bills"
    case salary = "Salary"
    case other = "Other"

    /// SF Symbol used to represent the category.
    var vtfSymbolName: String {
        switch self {
        case .food: return "fork.knife"
        case .transport: return "tram.fill"
        case .shopping: return "bag.fill"
        case .entertainment: return "gamecontroller.fill"
        case .bills: return "bolt.fill"
        case .salary: return "banknote.fill"
        case .other: return "square.grid.2x2.fill"
        }
    }

    /// Accent colour used for the category glyph and chart segment.
    var vtfAccentColor: UIColor {
        switch self {
        case .food: return UIColor(red: 0.98, green: 0.55, blue: 0.30, alpha: 1)
        case .transport: return UIColor(red: 0.30, green: 0.70, blue: 0.98, alpha: 1)
        case .shopping: return UIColor(red: 0.78, green: 0.45, blue: 0.98, alpha: 1)
        case .entertainment: return UIColor(red: 0.98, green: 0.40, blue: 0.65, alpha: 1)
        case .bills: return UIColor(red: 0.98, green: 0.80, blue: 0.30, alpha: 1)
        case .salary: return UIColor(red: 0.30, green: 0.85, blue: 0.55, alpha: 1)
        case .other: return UIColor(red: 0.60, green: 0.65, blue: 0.78, alpha: 1)
        }
    }

    /// Whether the category is typically used for income.
    var vtfIsIncomeOriented: Bool {
        switch self {
        case .salary: return true
        default: return false
        }
    }

    /// Resolve a stored raw category string back into the enum, defaulting to `.other`.
    static func vtfResolve(_ raw: String) -> VTFCategory {
        return VTFCategory(rawValue: raw) ?? .other
    }
}
