//
//  VTFSearchViewController.swift
//  Vault Finance
//
//  Live search over all transactions by title, category, or note.
//

import UIKit

/// Searchable list of transactions.
final class VTFSearchViewController: VTFBaseViewController {

    private let searchField = VTFTextField(placeholder: "Search transactions", icon: "magnifyingglass")
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var emptyState: VTFEmptyStateView?

    private var allTransactions: [VTFTransaction] = []
    private var results: [VTFTransaction] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search"
        vtfApplyNavigationAppearance()
        allTransactions = VTFAnalyticsEngine(transactions: VTFStorageManager.shared.vtfLoad()).vtfSortedByDateDescending()
        results = allTransactions
        vtfBuildLayout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchField.vtfBecomeFirstResponder()
    }

    private func vtfBuildLayout() {
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.vtfOnTextChange = { [weak self] text in
            self?.vtfFilter(text)
        }
        view.addSubview(searchField)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(VTFTransactionCell.self, forCellReuseIdentifier: VTFTransactionCell.reuseID)
        tableView.contentInset = UIEdgeInsets(top: VTFTheme.Spacing.sm, left: 0, bottom: VTFTheme.Spacing.xl, right: 0)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: VTFTheme.Spacing.sm),
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: VTFTheme.Spacing.md),
            searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -VTFTheme.Spacing.md),
            tableView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: VTFTheme.Spacing.sm),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func vtfFilter(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if trimmed.isEmpty {
            results = allTransactions
        } else {
            results = allTransactions.filter {
                $0.title.lowercased().contains(trimmed) ||
                $0.category.lowercased().contains(trimmed) ||
                ($0.note?.lowercased().contains(trimmed) ?? false)
            }
        }
        tableView.reloadData()
        vtfUpdateEmptyState()
    }

    private func vtfUpdateEmptyState() {
        emptyState?.removeFromSuperview()
        emptyState = nil
        guard results.isEmpty else { return }
        let empty = VTFEmptyStateView(icon: "doc.text.magnifyingglass",
                                      title: "No matches",
                                      message: "Try a different title, category, or note.")
        empty.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(empty)
        emptyState = empty
        NSLayoutConstraint.activate([
            empty.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            empty.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            empty.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            empty.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

extension VTFSearchViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VTFTransactionCell.reuseID, for: indexPath)
        guard let txCell = cell as? VTFTransactionCell else { return cell }
        txCell.vtfConfigure(with: results[indexPath.row], formatter: VTFSettingsStore.shared.vtfFormatter, now: Date())
        return txCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detail = VTFTransactionDetailViewController(transaction: results[indexPath.row])
        navigationController?.pushViewController(detail, animated: true)
    }
}
