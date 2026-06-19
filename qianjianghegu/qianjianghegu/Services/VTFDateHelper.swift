//
//  VTFDateHelper.swift
//  Vault Finance
//
//  Calendar / Date filtering helpers used by analytics and monthly views.
//

import Foundation

/// Date math utilities centred on month-based filtering.
enum VTFDateHelper {

    static let calendar = Calendar.current

    /// Start of the month containing `date`.
    static func vtfStartOfMonth(for date: Date) -> Date {
        let comps = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: comps) ?? date
    }

    /// Whether `date` falls in the same month/year as `reference`.
    static func vtfIsInSameMonth(_ date: Date, as reference: Date) -> Bool {
        return calendar.isDate(date, equalTo: reference, toGranularity: .month)
    }

    /// Filter transactions to the month of `reference`.
    static func vtfTransactions(_ transactions: [VTFTransaction], inMonthOf reference: Date) -> [VTFTransaction] {
        return transactions.filter { vtfIsInSameMonth($0.date, as: reference) }
    }

    /// Month + year label, e.g. "April 2026".
    static func vtfMonthYearLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }

    /// Short month label, e.g. "Apr".
    static func vtfShortMonthLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLL"
        return formatter.string(from: date)
    }

    /// Medium friendly date, e.g. "Apr 12, 2026".
    static func vtfMediumDateLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    /// Relative "Today / Yesterday / weekday" style label for list grouping.
    static func vtfRelativeDayLabel(for date: Date, now: Date) -> String {
        if calendar.isDate(date, inSameDayAs: now) { return "Today" }
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now),
           calendar.isDate(date, inSameDayAs: yesterday) {
            return "Yesterday"
        }
        return vtfMediumDateLabel(for: date)
    }

    /// The last `count` months (oldest first) as start-of-month dates.
    static func vtfRecentMonths(count: Int, endingAt reference: Date) -> [Date] {
        var months: [Date] = []
        let start = vtfStartOfMonth(for: reference)
        for offset in stride(from: count - 1, through: 0, by: -1) {
            if let month = calendar.date(byAdding: .month, value: -offset, to: start) {
                months.append(month)
            }
        }
        return months
    }
}
