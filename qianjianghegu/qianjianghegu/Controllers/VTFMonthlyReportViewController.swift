//
//  VTFMonthlyReportViewController.swift
//  Vault Finance
//
//  A shareable-style monthly report: headline savings, top categories, and a
//  generated narrative summary. Read-only.
//

import UIKit

/// A summarised report for the current month.
final class VTFMonthlyReportViewController: VTFBaseViewController {

    private let monthSwitcher = VTFMonthSwitcherView()
    private var referenceMonth = VTFDateHelper.vtfStartOfMonth(for: Date())

    private let heroCard = VTFCardView(elevated: true)
    private let heroValue = UILabel()
    private let heroCaption = UILabel()
    private let narrativeLabel = UILabel()
    private let highlightsStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Monthly Report"
        vtfApplyNavigationAppearance()
        vtfBuildLayout()
        vtfReload()
    }

    private func vtfBuildLayout() {
        vtfInstallScrollableContent()

        monthSwitcher.vtfOnChange = { [weak self] delta in
            guard let self = self else { return }
            if let newMonth = VTFDateHelper.calendar.date(byAdding: .month, value: delta, to: self.referenceMonth) {
                if delta > 0 && newMonth > VTFDateHelper.vtfStartOfMonth(for: Date()) { return }
                self.referenceMonth = newMonth
                self.vtfReload()
            }
        }
        vtfContentStack.addArrangedSubview(monthSwitcher)

        heroCaption.font = VTFTypography.subheadline()
        heroCaption.textColor = VTFTheme.textSecondary
        heroValue.font = VTFTypography.balance(40)
        heroValue.adjustsFontSizeToFitWidth = true
        heroValue.minimumScaleFactor = 0.5
        heroCard.vtfAddArranged(heroCaption)
        heroCard.vtfAddArranged(heroValue)
        vtfContentStack.addArrangedSubview(heroCard)

        let narrativeHeader = VTFSectionHeaderView(title: "Summary")
        vtfContentStack.addArrangedSubview(narrativeHeader)
        narrativeLabel.font = VTFTypography.body()
        narrativeLabel.textColor = VTFTheme.textSecondary
        narrativeLabel.numberOfLines = 0
        let narrativeCard = VTFCardView()
        narrativeCard.vtfAddArranged(narrativeLabel)
        vtfContentStack.addArrangedSubview(narrativeCard)

        let highlightsHeader = VTFSectionHeaderView(title: "Highlights")
        vtfContentStack.addArrangedSubview(highlightsHeader)
        highlightsStack.axis = .vertical
        highlightsStack.spacing = VTFTheme.Spacing.sm
        vtfContentStack.addArrangedSubview(highlightsStack)
    }

    private func vtfReload() {
        let transactions = VTFStorageManager.shared.vtfLoad()
        let engine = VTFAnalyticsEngine(transactions: transactions)
        let formatter = VTFSettingsStore.shared.vtfFormatter

        monthSwitcher.vtfSetTitle(VTFDateHelper.vtfMonthYearLabel(for: referenceMonth))

        let summary = engine.vtfSummary(forMonthOf: referenceMonth)
        heroCaption.text = "Net for \(VTFDateHelper.vtfMonthYearLabel(for: referenceMonth))"
        heroValue.text = formatter.vtfString(from: summary.balance)
        heroValue.textColor = summary.balance >= 0 ? VTFTheme.income : VTFTheme.expense

        narrativeLabel.text = vtfNarrative(summary: summary, engine: engine, formatter: formatter)

        // Highlights.
        highlightsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        highlightsStack.addArrangedSubview(vtfHighlight(icon: "arrow.down.left.circle.fill",
                                                        tint: VTFTheme.income,
                                                        title: "Income",
                                                        value: formatter.vtfString(from: summary.income)))
        highlightsStack.addArrangedSubview(vtfHighlight(icon: "arrow.up.right.circle.fill",
                                                        tint: VTFTheme.expense,
                                                        title: "Expense",
                                                        value: formatter.vtfString(from: summary.expense)))
        highlightsStack.addArrangedSubview(vtfHighlight(icon: "percent",
                                                        tint: VTFTheme.accent,
                                                        title: "Savings rate",
                                                        value: "\(Int((summary.savingsRate * 100).rounded()))%"))
        if let top = engine.vtfExpenseBreakdown(forMonthOf: referenceMonth).first {
            highlightsStack.addArrangedSubview(vtfHighlight(icon: top.category.vtfSymbolName,
                                                            tint: top.category.vtfAccentColor,
                                                            title: "Top category",
                                                            value: "\(top.category.rawValue) · \(formatter.vtfString(from: top.total))"))
        }
    }

    private func vtfNarrative(summary: VTFPeriodSummary, engine: VTFAnalyticsEngine, formatter: VTFCurrencyFormatter) -> String {
        guard summary.income > 0 || summary.expense > 0 else {
            return "No activity recorded for this month yet. Add some transactions to generate your report."
        }
        var parts: [String] = []
        if summary.balance >= 0 {
            parts.append("You saved \(formatter.vtfString(from: summary.balance)) this month — nice work.")
        } else {
            parts.append("You spent \(formatter.vtfString(from: abs(summary.balance))) more than you earned this month.")
        }
        if let top = engine.vtfExpenseBreakdown(forMonthOf: referenceMonth).first {
            parts.append("Most of your spending went to \(top.category.rawValue.lowercased()) (\(formatter.vtfString(from: top.total))).")
        }
        let rate = Int((summary.savingsRate * 100).rounded())
        if summary.income > 0 {
            parts.append("That's a savings rate of \(rate)%.")
        }
        return parts.joined(separator: " ")
    }

    private func vtfHighlight(icon: String, tint: UIColor, title: String, value: String) -> UIView {
        let row = VTFFormRow(title: title, icon: icon)
        row.isUserInteractionEnabled = false
        row.vtfSetValue(value, valueColor: VTFTheme.textPrimary)
        return row
    }
}
