//
//  VTFBudgetViewController.swift
//  Vault Finance
//
//  Budgets tab: an overview ring of total budget usage plus per-category
//  budget rows. Tapping a row opens the budget editor.
//

import UIKit

/// Budgets tab.
final class VTFBudgetViewController: VTFBaseViewController {

    private let overviewCard = VTFCardView(elevated: true)
    private let overviewRing = VTFProgressRingView()
    private let overviewCaption = UILabel()
    private let overviewDetail = UILabel()
    private let listStack = UIStackView()
    private var emptyState: VTFEmptyStateView?

    private var referenceMonth = VTFDateHelper.vtfStartOfMonth(for: Date())

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Budgets"
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus.circle.fill"),
                                                            style: .plain, target: self, action: #selector(vtfAddBudget))
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

        let title = UILabel()
        title.text = "Monthly budget usage"
        title.font = VTFTypography.headline()
        title.textColor = VTFTheme.textSecondary

        overviewRing.translatesAutoresizingMaskIntoConstraints = false
        overviewRing.lineWidth = 12
        overviewRing.widthAnchor.constraint(equalToConstant: 120).isActive = true
        overviewRing.heightAnchor.constraint(equalToConstant: 120).isActive = true

        overviewCaption.font = VTFTypography.title()
        overviewCaption.textColor = VTFTheme.textPrimary
        overviewCaption.textAlignment = .center
        overviewDetail.font = VTFTypography.caption()
        overviewDetail.textColor = VTFTheme.textTertiary
        overviewDetail.textAlignment = .center
        overviewDetail.numberOfLines = 0

        let ringStack = UIStackView(arrangedSubviews: [overviewRing, overviewCaption, overviewDetail])
        ringStack.axis = .vertical
        ringStack.alignment = .center
        ringStack.spacing = VTFTheme.Spacing.sm

        overviewCard.vtfAddArranged(title)
        overviewCard.vtfAddArranged(ringStack)
        vtfContentStack.addArrangedSubview(overviewCard)

        let header = VTFSectionHeaderView(title: "Category budgets")
        vtfContentStack.addArrangedSubview(header)

        listStack.axis = .vertical
        listStack.spacing = VTFTheme.Spacing.sm
        vtfContentStack.addArrangedSubview(listStack)
    }

    @objc private func vtfReload() {
        let transactions = VTFStorageManager.shared.vtfLoad()
        let formatter = VTFSettingsStore.shared.vtfFormatter
        let progresses = VTFBudgetManager.shared.vtfProgress(transactions: transactions, monthOf: referenceMonth)

        // Overview ring: total spent vs total budgeted.
        let totalBudget = progresses.reduce(0) { $0 + $1.budget.monthlyLimit }
        let totalSpent = progresses.reduce(0) { $0 + $1.spent }
        let fraction = totalBudget > 0 ? totalSpent / totalBudget : 0
        overviewRing.vtfTintColors = fraction > 1 ? VTFTheme.expenseGradientColors : VTFTheme.primaryGradientColors
        overviewRing.vtfSetProgress(CGFloat(min(1, fraction)), text: "\(Int((min(1, fraction) * 100).rounded()))%")
        overviewCaption.text = "\(formatter.vtfString(from: totalSpent)) of \(formatter.vtfString(from: totalBudget))"
        overviewDetail.text = totalBudget > 0
            ? (fraction > 1 ? "Over budget this month" : "On track for \(VTFDateHelper.vtfMonthYearLabel(for: referenceMonth))")
            : "Set budgets below to start tracking."

        vtfRenderList(progresses, formatter: formatter)
    }

    private func vtfRenderList(_ progresses: [VTFBudgetProgress], formatter: VTFCurrencyFormatter) {
        listStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        emptyState?.removeFromSuperview()
        emptyState = nil

        guard progresses.isEmpty == false else {
            let empty = VTFEmptyStateView(icon: "target",
                                          title: "No budgets yet",
                                          message: "Tap + to set a monthly limit for a category and track your spending.")
            emptyState = empty
            listStack.addArrangedSubview(empty)
            return
        }

        for progress in progresses {
            let row = VTFBudgetRow()
            let category = VTFCategory.vtfResolve(progress.budget.category)
            row.vtfConfigure(category: category,
                             spent: formatter.vtfString(from: progress.spent),
                             limit: formatter.vtfString(from: progress.budget.monthlyLimit),
                             fraction: progress.fraction,
                             isOver: progress.isOverBudget)
            row.vtfOnTap = { [weak self] in
                self?.vtfEditBudget(category: category)
            }
            listStack.addArrangedSubview(row)
        }
    }

    @objc private func vtfAddBudget() {
        vtfEditBudget(category: nil)
    }

    private func vtfEditBudget(category: VTFCategory?) {
        let editor = VTFBudgetEditViewController(category: category)
        let nav = UINavigationController(rootViewController: editor)
        present(nav, animated: true)
    }
}
