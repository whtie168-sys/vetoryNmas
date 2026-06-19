//
//  VTFCategoryDetailViewController.swift
//  Vault Finance
//
//  Drill-down for a single category: total spent, transaction count, and the
//  list of transactions in that category.
//

import UIKit

/// Detail screen listing all transactions in a category.
final class VTFCategoryDetailViewController: VTFBaseViewController {

    private let category: VTFCategory
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let headerCard = VTFCardView(elevated: true)
    private let totalLabel = UILabel()
    private let countLabel = UILabel()

    private var items: [VTFTransaction] = []

    init(category: VTFCategory) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = category.rawValue
        vtfApplyNavigationAppearance()
        vtfBuildLayout()
        NotificationCenter.default.addObserver(self, selector: #selector(vtfReload),
                                               name: VTFStorageManager.vtfTransactionsChanged, object: nil)
        vtfReload()
    }

    private func vtfBuildLayout() {
        let icon = VTFCategoryIconView(size: 56)
        icon.vtfConfigure(with: category)
        totalLabel.font = VTFTypography.balance(34)
        totalLabel.textColor = category.vtfAccentColor
        countLabel.font = VTFTypography.caption()
        countLabel.textColor = VTFTheme.textTertiary

        let textStack = UIStackView(arrangedSubviews: [totalLabel, countLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        let headerRow = UIStackView(arrangedSubviews: [icon, textStack, UIView()])
        headerRow.axis = .horizontal
        headerRow.alignment = .center
        headerRow.spacing = VTFTheme.Spacing.md
        headerCard.vtfAddArranged(headerRow)
        headerCard.translatesAutoresizingMaskIntoConstraints = false

        let headerContainer = UIView()
        headerContainer.addSubview(headerCard)
        NSLayoutConstraint.activate([
            headerCard.topAnchor.constraint(equalTo: headerContainer.topAnchor, constant: VTFTheme.Spacing.md),
            headerCard.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: -VTFTheme.Spacing.sm),
            headerCard.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: VTFTheme.Spacing.md),
            headerCard.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -VTFTheme.Spacing.md)
        ])

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(VTFTransactionCell.self, forCellReuseIdentifier: VTFTransactionCell.reuseID)
        tableView.contentInset = UIEdgeInsets(top: VTFTheme.Spacing.sm, left: 0, bottom: VTFTheme.Spacing.xl, right: 0)

        // Size the header to fit.
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        view.addSubview(headerContainer)

        NSLayoutConstraint.activate([
            headerContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: headerContainer.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func vtfReload() {
        let engine = VTFAnalyticsEngine(transactions: VTFStorageManager.shared.vtfLoad())
        items = engine.vtfTransactions(in: category.rawValue)
        let formatter = VTFSettingsStore.shared.vtfFormatter
        let total = items.reduce(0.0) { $0 + $1.amount }
        totalLabel.text = formatter.vtfString(from: total)
        countLabel.text = items.count == 1 ? "1 transaction" : "\(items.count) transactions"
        tableView.reloadData()
    }
}

extension VTFCategoryDetailViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VTFTransactionCell.reuseID, for: indexPath)
        guard let txCell = cell as? VTFTransactionCell else { return cell }
        txCell.vtfConfigure(with: items[indexPath.row], formatter: VTFSettingsStore.shared.vtfFormatter, now: Date())
        return txCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detail = VTFTransactionDetailViewController(transaction: items[indexPath.row])
        navigationController?.pushViewController(detail, animated: true)
    }
}
