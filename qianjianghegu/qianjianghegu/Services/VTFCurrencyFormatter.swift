//
//  VTFCurrencyFormatter.swift
//  Vault Finance
//
//  Currency formatting honouring the user's selected currency code.
//

import Foundation

/// Supported display currencies (offline, no live rates — formatting only).
enum VTFCurrency: String, Codable, CaseIterable {
    case usd = "USD"
    case eur = "EUR"
    case gbp = "GBP"
    case jpy = "JPY"
    case cny = "CNY"

    var vtfSymbol: String {
        switch self {
        case .usd: return "$"
        case .eur: return "€"
        case .gbp: return "£"
        case .jpy: return "¥"
        case .cny: return "¥"
        }
    }

    var vtfDisplayName: String {
        switch self {
        case .usd: return "US Dollar"
        case .eur: return "Euro"
        case .gbp: return "British Pound"
        case .jpy: return "Japanese Yen"
        case .cny: return "Chinese Yuan"
        }
    }

    var vtfFractionDigits: Int {
        switch self {
        case .jpy: return 0
        default: return 2
        }
    }
}

/// Formats monetary values for display.
struct VTFCurrencyFormatter {

    let currency: VTFCurrency

    init(currency: VTFCurrency) {
        self.currency = currency
    }

    private func vtfBaseFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = currency.vtfFractionDigits
        formatter.maximumFractionDigits = currency.vtfFractionDigits
        formatter.groupingSeparator = ","
        formatter.usesGroupingSeparator = true
        return formatter
    }

    /// e.g. "$1,250.00".
    func vtfString(from amount: Double) -> String {
        let formatter = vtfBaseFormatter()
        let number = NSNumber(value: abs(amount))
        let body = formatter.string(from: number) ?? "0"
        return "\(currency.vtfSymbol)\(body)"
    }

    /// e.g. "+$1,250.00" / "-$30.00" relative to type.
    func vtfSignedString(amount: Double, type: VTFTransactionType) -> String {
        let prefix = type == .income ? "+" : "-"
        return "\(prefix)\(vtfString(from: amount))"
    }

    /// Compact form for charts axis, e.g. "$1.2k".
    func vtfCompactString(from amount: Double) -> String {
        let absValue = abs(amount)
        if absValue >= 1_000_000 {
            return "\(currency.vtfSymbol)\(String(format: "%.1f", absValue / 1_000_000))M"
        } else if absValue >= 1_000 {
            return "\(currency.vtfSymbol)\(String(format: "%.1f", absValue / 1_000))k"
        }
        return vtfString(from: absValue)
    }
}
