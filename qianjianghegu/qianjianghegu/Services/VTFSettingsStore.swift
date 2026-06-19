//
//  VTFSettingsStore.swift
//  Vault Finance
//
//  Lightweight key-value settings persisted to UserDefaults (vtf. prefix).
//

import Foundation

/// User preferences for the app (currency, haptics, etc).
final class VTFSettingsStore {

    static let shared = VTFSettingsStore()

    private enum Keys {
        static let currency = "vtf.settings.currency"
        static let haptics = "vtf.settings.haptics"
        static let monthlyBudgetReminder = "vtf.settings.monthlyReminder"
    }

    private let defaults: UserDefaults

    /// Posted when a setting that affects formatting changes.
    static let vtfSettingsChanged = Notification.Name("vtf.settingsChanged")

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - Currency

    var vtfCurrency: VTFCurrency {
        get {
            guard let raw = defaults.string(forKey: Keys.currency),
                  let currency = VTFCurrency(rawValue: raw) else {
                return .usd
            }
            return currency
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.currency)
            NotificationCenter.default.post(name: VTFSettingsStore.vtfSettingsChanged, object: nil)
        }
    }

    /// Convenience formatter built from the current currency.
    var vtfFormatter: VTFCurrencyFormatter {
        return VTFCurrencyFormatter(currency: vtfCurrency)
    }

    // MARK: - Haptics

    var vtfHapticsEnabled: Bool {
        get {
            if defaults.object(forKey: Keys.haptics) == nil { return true }
            return defaults.bool(forKey: Keys.haptics)
        }
        set { defaults.set(newValue, forKey: Keys.haptics) }
    }

    // MARK: - Reminder

    var vtfMonthlyReminderEnabled: Bool {
        get { defaults.bool(forKey: Keys.monthlyBudgetReminder) }
        set { defaults.set(newValue, forKey: Keys.monthlyBudgetReminder) }
    }

    var vtfAppVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}
