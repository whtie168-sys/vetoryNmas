//
//  VTFStorageManager.swift
//  Vault Finance
//
//  Local persistence using UserDefaults + JSON. No networking, no cloud.
//

import Foundation

/// Single source of truth for persisting transactions and budgets locally.
///
/// All keys are prefixed with `vtf.` per the spec.
final class VTFStorageManager {

    static let shared = VTFStorageManager()

    private enum Keys {
        static let transactions = "vtf.transactions"
        static let budgets = "vtf.budgets"
        static let didSeed = "vtf.didSeedSampleData"
    }

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    /// Posted whenever the transaction store changes so screens can refresh.
    static let vtfTransactionsChanged = Notification.Name("vtf.transactionsChanged")

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - Transactions

    func vtfSave(_ transactions: [VTFTransaction]) {
        guard let data = try? encoder.encode(transactions) else { return }
        defaults.set(data, forKey: Keys.transactions)
        NotificationCenter.default.post(name: VTFStorageManager.vtfTransactionsChanged, object: nil)
    }

    func vtfLoad() -> [VTFTransaction] {
        guard let data = defaults.data(forKey: Keys.transactions),
              let decoded = try? decoder.decode([VTFTransaction].self, from: data) else {
            return []
        }
        return decoded
    }

    /// Append a single transaction following the spec's read-append-write flow.
    func vtfAppend(_ transaction: VTFTransaction) {
        var current = vtfLoad()
        current.append(transaction)
        vtfSave(current)
    }

    /// Replace an existing transaction (matched by id).
    func vtfUpdate(_ transaction: VTFTransaction) {
        var current = vtfLoad()
        guard let index = current.firstIndex(where: { $0.id == transaction.id }) else { return }
        current[index] = transaction
        vtfSave(current)
    }

    func vtfDelete(id: UUID) {
        var current = vtfLoad()
        current.removeAll { $0.id == id }
        vtfSave(current)
    }

    func vtfClearAll() {
        defaults.removeObject(forKey: Keys.transactions)
        defaults.removeObject(forKey: Keys.budgets)
        NotificationCenter.default.post(name: VTFStorageManager.vtfTransactionsChanged, object: nil)
    }

    // MARK: - Budgets

    func vtfSaveBudgets(_ budgets: [VTFBudget]) {
        guard let data = try? encoder.encode(budgets) else { return }
        defaults.set(data, forKey: Keys.budgets)
    }

    func vtfLoadBudgets() -> [VTFBudget] {
        guard let data = defaults.data(forKey: Keys.budgets),
              let decoded = try? decoder.decode([VTFBudget].self, from: data) else {
            return []
        }
        return decoded
    }

    // MARK: - First launch seeding

    /// Seed a few sample transactions exactly once so the app demos well.
    func vtfSeedSampleDataIfNeeded(referenceDate: Date) {
        guard defaults.bool(forKey: Keys.didSeed) == false else { return }
        defaults.set(true, forKey: Keys.didSeed)
        if vtfLoad().isEmpty {
            vtfSave(VTFTransaction.vtfSampleSeed(referenceDate: referenceDate))
        }
    }
}
