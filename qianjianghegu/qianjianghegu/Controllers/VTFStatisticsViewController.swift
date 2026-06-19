//
//  VTFStatisticsViewController.swift
//  Vault Finance
//
//  Insights tab: month switcher, income/expense/net summary, donut breakdown
//  of expenses by category, a 6-month trend bar chart, and category rows.
//

import UIKit

/// Insights / statistics tab.
final class VTFStatisticsViewController: VTFBaseViewController {

    private let monthSwitcher = VTFMonthSwitcherView()
    private let summaryRow = UIStackView()
    private let incomeTile = VTFStatTile(icon: "arrow.down.left.circle.fill", caption: "Income", tint: VTFTheme.income)
    private let expenseTile = VTFStatTile(icon: "arrow.up.right.circle.fill", caption: "Expense", tint: VTFTheme.expense)
    private let netTile = VTFStatTile(icon: "equal.circle.fill", caption: "Net", tint: VTFTheme.accent)

    private let donutCard = VTFCardView()
    private let donut = VTFDonutChartView()
    private let legendStack = UIStackView()

    private let trendCard = VTFCardView()
    private let barChart = VTFBarChartView()

    private let categoryListStack = UIStackView()

    private var referenceMonth = VTFDateHelper.vtfStartOfMonth(for: Date())
    private var transactions: [VTFTransaction] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Insights"
        navigationItem.largeTitleDisplayMode = .always
        vtfBuildLayout()
        NotificationCenter.default.addObserver(self, selector: #selector(vtfReload),
                                               name: VTFStorageManager.vtfTransactionsChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(vtfReload),
                                               name: VTFSettingsStore.vtfSettingsChanged, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        vtfReload()
    }

    private func vtfBuildLayout() {
        vtfInstallScrollableContent()

        monthSwitcher.vtfOnChange = { [weak self] direction in
            self?.vtfShiftMonth(by: direction)
        }
        vtfContentStack.addArrangedSubview(monthSwitcher)

        summaryRow.axis = .horizontal
        summaryRow.distribution = .fillEqually
        summaryRow.spacing = VTFTheme.Spacing.sm
        summaryRow.addArrangedSubview(incomeTile)
        summaryRow.addArrangedSubview(expenseTile)
        summaryRow.addArrangedSubview(netTile)
        vtfContentStack.addArrangedSubview(summaryRow)

        // Donut breakdown.
        let donutTitle = UILabel()
        donutTitle.text = "Where it goes"
        donutTitle.font = VTFTypography.title()
        donutTitle.textColor = VTFTheme.textPrimary

        donut.translatesAutoresizingMaskIntoConstraints = false
        donut.heightAnchor.constraint(equalToConstant: 180).isActive = true
        donut.widthAnchor.constraint(equalToConstant: 180).isActive = true

        legendStack.axis = .vertical
        legendStack.spacing = VTFTheme.Spacing.sm

        let donutRow = UIStackView(arrangedSubviews: [donut, legendStack])
        donutRow.axis = .horizontal
        donutRow.alignment = .center
        donutRow.spacing = VTFTheme.Spacing.lg

        donutCard.vtfAddArranged(donutTitle)
        donutCard.vtfAddArranged(donutRow)
        vtfContentStack.addArrangedSubview(donutCard)

        // Trend chart.
        let trendTitle = UILabel()
        trendTitle.text = "6-month trend"
        trendTitle.font = VTFTypography.title()
        trendTitle.textColor = VTFTheme.textPrimary
        barChart.translatesAutoresizingMaskIntoConstraints = false
        barChart.heightAnchor.constraint(equalToConstant: 160).isActive = true
        trendCard.vtfAddArranged(trendTitle)
        trendCard.vtfAddArranged(barChart)
        trendCard.vtfAddArranged(vtfTrendLegend())
        vtfContentStack.addArrangedSubview(trendCard)

        // Category list.
        let catHeader = VTFSectionHeaderView(title: "By category")
        vtfContentStack.addArrangedSubview(catHeader)
        categoryListStack.axis = .vertical
        categoryListStack.spacing = VTFTheme.Spacing.sm
        vtfContentStack.addArrangedSubview(categoryListStack)
    }

    private func vtfTrendLegend() -> UIView {
        let income = vtfLegendDot(color: VTFTheme.income, text: "Income")
        let expense = vtfLegendDot(color: VTFTheme.expense, text: "Expense")
        let stack = UIStackView(arrangedSubviews: [income, expense, UIView()])
        stack.axis = .horizontal
        stack.spacing = VTFTheme.Spacing.md
        return stack
    }

    private func vtfLegendDot(color: UIColor, text: String) -> UIView {
        let dot = UIView()
        dot.backgroundColor = color
        dot.layer.cornerRadius = 5
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.widthAnchor.constraint(equalToConstant: 10).isActive = true
        dot.heightAnchor.constraint(equalToConstant: 10).isActive = true
        let label = UILabel()
        label.text = text
        label.font = VTFTypography.caption()
        label.textColor = VTFTheme.textSecondary
        let stack = UIStackView(arrangedSubviews: [dot, label])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 6
        return stack
    }

    // MARK: - Month navigation

    private func vtfShiftMonth(by delta: Int) {
        guard let newMonth = VTFDateHelper.calendar.date(byAdding: .month, value: delta, to: referenceMonth) else { return }
        // Do not navigate into the future.
        if delta > 0 && newMonth > VTFDateHelper.vtfStartOfMonth(for: Date()) { return }
        referenceMonth = newMonth
        vtfReload()
    }

    // MARK: - Data

    @objc private func vtfReload() {
        transactions = VTFStorageManager.shared.vtfLoad()
        let engine = VTFAnalyticsEngine(transactions: transactions)
        let formatter = VTFSettingsStore.shared.vtfFormatter

        monthSwitcher.vtfSetTitle(VTFDateHelper.vtfMonthYearLabel(for: referenceMonth))

        let summary = engine.vtfSummary(forMonthOf: referenceMonth)
        incomeTile.vtfSetValue(formatter.vtfString(from: summary.income))
        expenseTile.vtfSetValue(formatter.vtfString(from: summary.expense))
        netTile.vtfSetValue(formatter.vtfString(from: summary.balance))
        netTile.vtfSetValueColor(summary.balance >= 0 ? VTFTheme.income : VTFTheme.expense)

        let breakdown = engine.vtfExpenseBreakdown(forMonthOf: referenceMonth)
        vtfRenderDonut(breakdown, total: summary.expense, formatter: formatter)
        vtfRenderLegend(breakdown, formatter: formatter)
        vtfRenderCategoryList(breakdown, formatter: formatter)

        let trend = engine.vtfMonthlyTrend(months: 6, endingAt: referenceMonth)
        barChart.vtfSetEntries(trend.map {
            VTFBarChartEntry(label: VTFDateHelper.vtfShortMonthLabel(for: $0.monthStart),
                             incomeValue: $0.income,
                             expenseValue: $0.expense)
        })
    }

    private func vtfRenderDonut(_ breakdown: [VTFCategoryAggregate], total: Double, formatter: VTFCurrencyFormatter) {
        let slices = breakdown.map { VTFDonutSlice(value: $0.total, color: $0.category.vtfAccentColor) }
        donut.vtfSetSlices(slices,
                           centerText: formatter.vtfCompactString(from: total),
                           caption: "spent")
    }

    private func vtfRenderLegend(_ breakdown: [VTFCategoryAggregate], formatter: VTFCurrencyFormatter) {
        legendStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let top = Array(breakdown.prefix(4))
        if top.isEmpty {
            let label = UILabel()
            label.text = "No expenses this month."
            label.font = VTFTypography.caption()
            label.textColor = VTFTheme.textTertiary
            label.numberOfLines = 0
            legendStack.addArrangedSubview(label)
            return
        }
        for item in top {
            legendStack.addArrangedSubview(vtfLegendDot(color: item.category.vtfAccentColor,
                                                        text: "\(item.category.rawValue)  \(formatter.vtfString(from: item.total))"))
        }
    }

    private func vtfRenderCategoryList(_ breakdown: [VTFCategoryAggregate], formatter: VTFCurrencyFormatter) {
        categoryListStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let total = breakdown.reduce(0) { $0 + $1.total }
        guard breakdown.isEmpty == false else {
            let empty = VTFEmptyStateView(icon: "chart.pie",
                                          title: "No data",
                                          message: "Add expenses to see category insights for this month.")
            categoryListStack.addArrangedSubview(empty)
            return
        }
        for item in breakdown {
            let row = VTFCategoryProgressRow()
            let fraction = total > 0 ? item.total / total : 0
            row.vtfConfigure(category: item.category,
                             amount: formatter.vtfString(from: item.total),
                             fraction: fraction,
                             count: item.transactionCount)
            row.vtfOnTap = { [weak self] in
                let detail = VTFCategoryDetailViewController(category: item.category)
                self?.navigationController?.pushViewController(detail, animated: true)
            }
            categoryListStack.addArrangedSubview(row)
        }
    }
}
