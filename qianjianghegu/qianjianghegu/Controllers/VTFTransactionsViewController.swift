//
//  VTFTransactionsViewController.swift
//  Vault Finance
//
//  Full transaction list grouped by day, with swipe-to-delete, pull-to-refresh,
//  a filter segmented control, and search.
//

import UIKit

/// Activity tab: the complete, filterable transaction list.
final class VTFTransactionsViewController: VTFBaseViewController {

    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let filterControl = VTFSegmentedControl(titles: ["All", "Income", "Expense"])
    private let refreshControl = UIRefreshControl()
    private var emptyState: VTFEmptyStateView?

    /// Section model: a day label + that day's transactions.
    private struct DaySection {
        let title: String
        let items: [VTFTransaction]
    }

    private var allTransactions: [VTFTransaction] = []
    private var sections: [DaySection] = []
    private var filter: VTFTransactionType?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Activity"
        navigationItem.largeTitleDisplayMode = .always
        vtfSetupNavBar()
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

    private func vtfSetupNavBar() {
        let search = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"),
                                     style: .plain, target: self, action: #selector(vtfOpenSearch))
        let add = UIBarButtonItem(image: UIImage(systemName: "plus.circle.fill"),
                                  style: .plain, target: self, action: #selector(vtfPresentAdd))
        navigationItem.rightBarButtonItems = [add, search]
    }

    private func vtfBuildLayout() {
        filterControl.translatesAutoresizingMaskIntoConstraints = false
        filterControl.addTarget(self, action: #selector(vtfFilterChanged), for: .valueChanged)
        view.addSubview(filterControl)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(VTFTransactionCell.self, forCellReuseIdentifier: VTFTransactionCell.reuseID)
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: VTFTheme.Spacing.sm, left: 0, bottom: VTFTheme.Spacing.xl, right: 0)
        refreshControl.tintColor = VTFTheme.accent
        refreshControl.addTarget(self, action: #selector(vtfPulled), for: .valueChanged)
        tableView.refreshControl = refreshControl
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            filterControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: VTFTheme.Spacing.sm),
            filterControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: VTFTheme.Spacing.md),
            filterControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -VTFTheme.Spacing.md),

            tableView.topAnchor.constraint(equalTo: filterControl.bottomAnchor, constant: VTFTheme.Spacing.sm),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Data

    @objc private func vtfReload() {
        allTransactions = VTFAnalyticsEngine(transactions: VTFStorageManager.shared.vtfLoad()).vtfSortedByDateDescending()
        vtfRebuildSections()
        tableView.reloadData()
        vtfUpdateEmptyState()
    }

    private func vtfRebuildSections() {
        let now = Date()
        let filtered = allTransactions.filter { filter == nil || $0.type == filter }
        var grouped: [String: [VTFTransaction]] = [:]
        var order: [String] = []
        for tx in filtered {
            let key = VTFDateHelper.vtfRelativeDayLabel(for: tx.date, now: now)
            if grouped[key] == nil {
                grouped[key] = []
                order.append(key)
            }
            grouped[key]?.append(tx)
        }
        sections = order.map { DaySection(title: $0, items: grouped[$0] ?? []) }
    }

    private func vtfUpdateEmptyState() {
        emptyState?.removeFromSuperview()
        emptyState = nil
        guard sections.isEmpty else {
            tableView.isHidden = false
            return
        }
        let empty = VTFEmptyStateView(icon: "magnifyingglass",
                                      title: "Nothing here",
                                      message: "No transactions match this filter yet.")
        empty.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(empty)
        emptyState = empty
        NSLayoutConstraint.activate([
            empty.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            empty.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            empty.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            empty.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    // MARK: - Actions

    @objc private func vtfFilterChanged() {
        switch filterControl.vtfSelectedIndex {
        case 1: filter = .income
        case 2: filter = .expense
        default: filter = nil
        }
        vtfRebuildSections()
        tableView.reloadData()
        vtfUpdateEmptyState()
    }

    @objc private func vtfPulled() {
        vtfReload()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }

    @objc private func vtfPresentAdd() {
        let addVC = VTFAddTransactionViewController()
        let nav = UINavigationController(rootViewController: addVC)
        present(nav, animated: true)
    }

    @objc private func vtfOpenSearch() {
        let searchVC = VTFSearchViewController()
        navigationController?.pushViewController(searchVC, animated: true)
    }
}

// MARK: - Table data source / delegate

extension VTFTransactionsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VTFTransactionCell.reuseID, for: indexPath)
        guard let txCell = cell as? VTFTransactionCell else { return cell }
        let tx = sections[indexPath.section].items[indexPath.row]
        txCell.vtfConfigure(with: tx, formatter: VTFSettingsStore.shared.vtfFormatter, now: Date())
        return txCell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let container = UIView()
        let label = UILabel()
        label.text = sections[section].title
        label.font = VTFTypography.subheadline()
        label.textColor = VTFTheme.textTertiary
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: VTFTheme.Spacing.md + 4),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6),
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: VTFTheme.Spacing.sm)
        ])
        return container
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let tx = sections[indexPath.section].items[indexPath.row]
        let detail = VTFTransactionDetailViewController(transaction: tx)
        navigationController?.pushViewController(detail, animated: true)
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            guard let self = self else { completion(false); return }
            let tx = self.sections[indexPath.section].items[indexPath.row]
            VTFStorageManager.shared.vtfDelete(id: tx.id)
            VTFHapticManager.shared.vtfNotify(.warning)
            completion(true)
        }
        delete.image = UIImage(systemName: "trash.fill")
        delete.backgroundColor = VTFTheme.expense
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
