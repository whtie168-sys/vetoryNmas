//
//  VTFTransactionCell.swift
//  Vault Finance
//
//  Premium table cell for a single transaction: category badge, title, date,
//  and a signed amount tinted income/expense.
//

import UIKit

/// Table view cell rendering one transaction row.
final class VTFTransactionCell: UITableViewCell {

    static let reuseID = "VTFTransactionCell"

    private let container = UIView()
    private let iconView = VTFCategoryIconView(size: 44)
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let amountLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        vtfSetup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func vtfSetup() {
        backgroundColor = .clear
        selectionStyle = .none

        container.backgroundColor = VTFTheme.surface
        container.layer.cornerRadius = VTFTheme.Radius.medium
        container.layer.cornerCurve = .continuous
        container.layer.borderWidth = 1
        container.layer.borderColor = VTFTheme.stroke.cgColor
        container.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(container)

        titleLabel.font = VTFTypography.headline()
        titleLabel.textColor = VTFTheme.textPrimary
        subtitleLabel.font = VTFTypography.caption()
        subtitleLabel.textColor = VTFTheme.textTertiary

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.translatesAutoresizingMaskIntoConstraints = false

        amountLabel.font = VTFTypography.monoAmount(17)
        amountLabel.textAlignment = .right
        amountLabel.setContentHuggingPriority(.required, for: .horizontal)
        amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let hStack = UIStackView(arrangedSubviews: [iconView, textStack, amountLabel])
        hStack.axis = .horizontal
        hStack.alignment = .center
        hStack.spacing = VTFTheme.Spacing.md
        hStack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(hStack)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: VTFTheme.Spacing.md),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -VTFTheme.Spacing.md),
            hStack.topAnchor.constraint(equalTo: container.topAnchor, constant: VTFTheme.Spacing.md),
            hStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -VTFTheme.Spacing.md),
            hStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: VTFTheme.Spacing.md),
            hStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -VTFTheme.Spacing.md)
        ])
    }

    func vtfConfigure(with transaction: VTFTransaction, formatter: VTFCurrencyFormatter, now: Date) {
        let category = VTFCategory.vtfResolve(transaction.category)
        iconView.vtfConfigure(with: category)
        titleLabel.text = transaction.title
        subtitleLabel.text = "\(category.rawValue) · \(VTFDateHelper.vtfRelativeDayLabel(for: transaction.date, now: now))"
        amountLabel.text = formatter.vtfSignedString(amount: transaction.amount, type: transaction.type)
        amountLabel.textColor = VTFTheme.color(for: transaction.type)
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.15) {
            self.container.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            self.container.backgroundColor = highlighted ? VTFTheme.surfaceElevated : VTFTheme.surface
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        container.layer.borderColor = VTFTheme.stroke.cgColor
    }
}
