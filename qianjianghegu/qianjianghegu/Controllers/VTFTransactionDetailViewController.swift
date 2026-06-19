//
//  VTFTransactionDetailViewController.swift
//  Vault Finance
//
//  Detail view for a single transaction with edit + delete actions.
//

import UIKit

/// Read-only detail screen for one transaction.
final class VTFTransactionDetailViewController: VTFBaseViewController {

    private var transaction: VTFTransaction
    private let amountLabel = UILabel()
    private let typeBadge = UILabel()
    private let detailCard = VTFCardView()

    init(transaction: VTFTransaction) {
        self.transaction = transaction
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Details"
        vtfApplyNavigationAppearance()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"),
                                                            style: .plain, target: self, action: #selector(vtfEdit))
        vtfBuildLayout()
        NotificationCenter.default.addObserver(self, selector: #selector(vtfRefresh),
                                               name: VTFStorageManager.vtfTransactionsChanged, object: nil)
    }

    private func vtfBuildLayout() {
        vtfInstallScrollableContent()

        let category = VTFCategory.vtfResolve(transaction.category)
        let icon = VTFCategoryIconView(size: 64)
        icon.vtfConfigure(with: category)
        icon.translatesAutoresizingMaskIntoConstraints = false

        amountLabel.font = VTFTypography.balance(44)
        amountLabel.textAlignment = .center
        amountLabel.adjustsFontSizeToFitWidth = true
        amountLabel.minimumScaleFactor = 0.5

        typeBadge.font = VTFTypography.caption()
        typeBadge.textAlignment = .center
        typeBadge.layer.cornerRadius = 10
        typeBadge.layer.cornerCurve = .continuous
        typeBadge.clipsToBounds = true
        typeBadge.translatesAutoresizingMaskIntoConstraints = false
        typeBadge.heightAnchor.constraint(equalToConstant: 26).isActive = true
        typeBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 96).isActive = true

        let header = UIStackView(arrangedSubviews: [icon, amountLabel, typeBadge])
        header.axis = .vertical
        header.alignment = .center
        header.spacing = VTFTheme.Spacing.md
        vtfContentStack.addArrangedSubview(header)

        vtfContentStack.addArrangedSubview(detailCard)

        let deleteButton = VTFPrimaryButton(title: "Delete Transaction", systemIcon: "trash.fill")
        deleteButton.addTarget(self, action: #selector(vtfDelete), for: .touchUpInside)
        vtfContentStack.addArrangedSubview(vtfSpacer(VTFTheme.Spacing.sm))
        vtfContentStack.addArrangedSubview(deleteButton)

        vtfPopulate()
    }

    private func vtfPopulate() {
        let formatter = VTFSettingsStore.shared.vtfFormatter
        let category = VTFCategory.vtfResolve(transaction.category)
        amountLabel.text = formatter.vtfSignedString(amount: transaction.amount, type: transaction.type)
        amountLabel.textColor = VTFTheme.color(for: transaction.type)

        typeBadge.text = "  \(transaction.type.vtfDisplayName)  "
        typeBadge.textColor = VTFTheme.color(for: transaction.type)
        typeBadge.backgroundColor = VTFTheme.color(for: transaction.type).withAlphaComponent(0.16)

        // Rebuild detail rows.
        (detailCard.subviews.first as? UIStackView)?.arrangedSubviews.forEach { $0.removeFromSuperview() }
        detailCard.vtfAddArranged(vtfDetailLine(title: "Title", value: transaction.title))
        detailCard.vtfAddArranged(vtfDivider())
        detailCard.vtfAddArranged(vtfDetailLine(title: "Category", value: category.rawValue, valueColor: category.vtfAccentColor))
        detailCard.vtfAddArranged(vtfDivider())
        detailCard.vtfAddArranged(vtfDetailLine(title: "Date", value: VTFDateHelper.vtfMediumDateLabel(for: transaction.date)))
        if let note = transaction.note, note.isEmpty == false {
            detailCard.vtfAddArranged(vtfDivider())
            detailCard.vtfAddArranged(vtfDetailLine(title: "Note", value: note))
        }
    }

    private func vtfDetailLine(title: String, value: String, valueColor: UIColor = VTFTheme.textPrimary) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = VTFTypography.subheadline()
        titleLabel.textColor = VTFTheme.textTertiary
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = VTFTypography.headline()
        valueLabel.textColor = valueColor
        valueLabel.textAlignment = .right
        valueLabel.numberOfLines = 0
        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .horizontal
        stack.alignment = .firstBaseline
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        return stack
    }

    private func vtfDivider() -> UIView {
        let line = UIView()
        line.backgroundColor = VTFTheme.stroke
        line.translatesAutoresizingMaskIntoConstraints = false
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return line
    }

    @objc private func vtfRefresh() {
        // If the transaction was edited elsewhere, reload its latest version.
        if let updated = VTFStorageManager.shared.vtfLoad().first(where: { $0.id == transaction.id }) {
            transaction = updated
            vtfPopulate()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    @objc private func vtfEdit() {
        let editor = VTFAddTransactionViewController(editing: transaction)
        let nav = UINavigationController(rootViewController: editor)
        present(nav, animated: true)
    }

    @objc private func vtfDelete() {
        let alert = UIAlertController(title: "Delete this transaction?",
                                      message: "This can't be undone.",
                                      preferredStyle: .alert)
        alert.overrideUserInterfaceStyle = .dark
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            VTFStorageManager.shared.vtfDelete(id: self.transaction.id)
            VTFHapticManager.shared.vtfNotify(.warning)
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}
