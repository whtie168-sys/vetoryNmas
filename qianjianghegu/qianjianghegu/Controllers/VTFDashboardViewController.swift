//
//  VTFDashboardViewController.swift
//  Vault Finance
//
//  Home screen: balance hero card, quick stats, savings ring, and recent
//  transactions (latest 10).
//

import UIKit

/// The dashboard / home tab.
final class VTFDashboardViewController: VTFBaseViewController {

    private let balanceCard = VTFBalanceCardView()
    private let savingsCard = VTFCardView(elevated: false)
    private let savingsRing = VTFProgressRingView()
    private let avgSpendTile = VTFStatTile(icon: "calendar", caption: "Avg / day", tint: VTFTheme.accent)
    private let topCategoryTile = VTFStatTile(icon: "flame.fill", caption: "Top category", tint: VTFTheme.warning)
    private let recentStack = UIStackView()
    private let recentHeader = VTFSectionHeaderView(title: "Recent", actionTitle: "See all")
    private var emptyState: VTFEmptyStateView?

    private var transactions: [VTFTransaction] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        navigationItem.largeTitleDisplayMode = .always
        vtfSetupAddButton()
        vtfBuildLayout()
        vtfObserveChanges()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        vtfReload()
    }

    // MARK: - Navigation bar

    private func vtfSetupAddButton() {
        let add = UIBarButtonItem(image: UIImage(systemName: "plus.circle.fill"),
                                  style: .plain,
                                  target: self,
                                  action: #selector(vtfPresentAdd))
        add.tintColor = VTFTheme.accent
        navigationItem.rightBarButtonItem = add
    }

    // MARK: - Layout

    private func vtfBuildLayout() {
        vtfInstallScrollableContent()

        balanceCard.translatesAutoresizingMaskIntoConstraints = false
        balanceCard.heightAnchor.constraint(equalToConstant: 200).isActive = true
        vtfContentStack.addArrangedSubview(balanceCard)

        // Savings rate card with ring + stat tiles.
        let savingsTitle = UILabel()
        savingsTitle.text = "This Month"
        savingsTitle.font = VTFTypography.title()
        savingsTitle.textColor = VTFTheme.textPrimary

        savingsRing.translatesAutoresizingMaskIntoConstraints = false
        savingsRing.widthAnchor.constraint(equalToConstant: 96).isActive = true
        savingsRing.heightAnchor.constraint(equalToConstant: 96).isActive = true

        let ringCaption = UILabel()
        ringCaption.text = "Savings rate"
        ringCaption.font = VTFTypography.caption()
        ringCaption.textColor = VTFTheme.textTertiary
        ringCaption.textAlignment = .center
        let ringStack = UIStackView(arrangedSubviews: [savingsRing, ringCaption])
        ringStack.axis = .vertical
        ringStack.alignment = .center
        ringStack.spacing = VTFTheme.Spacing.sm

        let tilesStack = UIStackView(arrangedSubviews: [avgSpendTile, topCategoryTile])
        tilesStack.axis = .vertical
        tilesStack.distribution = .fillEqually
        tilesStack.spacing = VTFTheme.Spacing.sm

        let rowStack = UIStackView(arrangedSubviews: [ringStack, tilesStack])
        rowStack.axis = .horizontal
        rowStack.spacing = VTFTheme.Spacing.lg
        rowStack.alignment = .center

        savingsCard.vtfAddArranged(savingsTitle)
        savingsCard.vtfAddArranged(rowStack)
        vtfContentStack.addArrangedSubview(savingsCard)

        // Recent section.
        recentHeader.vtfSetAction { [weak self] in
            self?.tabBarController?.selectedIndex = 1
        }
        vtfContentStack.addArrangedSubview(recentHeader)

        recentStack.axis = .vertical
        recentStack.spacing = VTFTheme.Spacing.sm
        vtfContentStack.addArrangedSubview(recentStack)
    }

    private func vtfObserveChanges() {
        NotificationCenter.default.addObserver(self, selector: #selector(vtfReload),
                                               name: VTFStorageManager.vtfTransactionsChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(vtfReload),
                                               name: VTFSettingsStore.vtfSettingsChanged, object: nil)
    }

    // MARK: - Data

    @objc private func vtfReload() {
        transactions = VTFStorageManager.shared.vtfLoad()
        let now = Date()
        let engine = VTFAnalyticsEngine(transactions: transactions)
        let formatter = VTFSettingsStore.shared.vtfFormatter

        let overall = engine.vtfOverallSummary()
        balanceCard.vtfConfigure(balance: formatter.vtfString(from: overall.balance),
                                 income: formatter.vtfString(from: overall.income),
                                 expense: formatter.vtfString(from: overall.expense))

        let monthSummary = engine.vtfSummary(forMonthOf: now)
        let rate = monthSummary.savingsRate
        savingsRing.vtfSetProgress(CGFloat(rate), text: "\(Int((rate * 100).rounded()))%")

        let avg = engine.vtfAverageDailySpend(monthOf: now, now: now)
        avgSpendTile.vtfSetValue(formatter.vtfString(from: avg))

        if let top = engine.vtfExpenseBreakdown(forMonthOf: now).first {
            topCategoryTile.vtfSetValue(top.category.rawValue)
            topCategoryTile.vtfSetValueColor(top.category.vtfAccentColor)
        } else {
            topCategoryTile.vtfSetValue("—")
        }

        vtfRenderRecent(engine.vtfRecent(limit: 10), formatter: formatter, now: now)
    }

    private func vtfRenderRecent(_ recent: [VTFTransaction], formatter: VTFCurrencyFormatter, now: Date) {
        recentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        emptyState?.removeFromSuperview()

        guard recent.isEmpty == false else {
            recentHeader.isHidden = true
            let empty = VTFEmptyStateView(icon: "tray.fill",
                                          title: "No transactions yet",
                                          message: "Tap + to add your first record and watch your balance come to life.")
            emptyState = empty
            empty.translatesAutoresizingMaskIntoConstraints = false
            vtfContentStack.addArrangedSubview(empty)
            return
        }

        recentHeader.isHidden = false
        for tx in recent {
            let row = VTFCompactTransactionRow()
            row.vtfConfigure(with: tx, formatter: formatter, now: now)
            row.vtfOnTap = { [weak self] in
                self?.vtfOpenDetail(tx)
            }
            recentStack.addArrangedSubview(row)
        }
    }

    // MARK: - Actions

    @objc private func vtfPresentAdd() {
        let addVC = VTFAddTransactionViewController()
        let nav = UINavigationController(rootViewController: addVC)
        nav.navigationBar.prefersLargeTitles = false
        present(nav, animated: true)
    }

    private func vtfOpenDetail(_ transaction: VTFTransaction) {
        let detail = VTFTransactionDetailViewController(transaction: transaction)
        navigationController?.pushViewController(detail, animated: true)
    }
}
