//
//  VTFCompactTransactionRow.swift
//  Vault Finance
//
//  A tappable compact transaction row used on the dashboard's recent list
//  (outside of a table view).
//

import UIKit

/// A button-like row showing a transaction; used in stacks, not table views.
final class VTFCompactTransactionRow: UIControl {

    private let iconView = VTFCategoryIconView(size: 40)
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let amountLabel = UILabel()

    /// Tap callback.
    var vtfOnTap: (() -> Void)?

    init() {
        super.init(frame: .zero)
        vtfSetup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func vtfSetup() {
        backgroundColor = VTFTheme.surface
        layer.cornerRadius = VTFTheme.Radius.medium
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = VTFTheme.stroke.cgColor

        titleLabel.font = VTFTypography.headline()
        titleLabel.textColor = VTFTheme.textPrimary
        subtitleLabel.font = VTFTypography.caption()
        subtitleLabel.textColor = VTFTheme.textTertiary

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        amountLabel.font = VTFTypography.monoAmount(16)
        amountLabel.textAlignment = .right
        amountLabel.setContentHuggingPriority(.required, for: .horizontal)
        amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let hStack = UIStackView(arrangedSubviews: [iconView, textStack, amountLabel])
        hStack.axis = .horizontal
        hStack.alignment = .center
        hStack.spacing = VTFTheme.Spacing.md
        hStack.isUserInteractionEnabled = false
        hStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hStack)

        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: topAnchor, constant: VTFTheme.Spacing.md),
            hStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -VTFTheme.Spacing.md),
            hStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: VTFTheme.Spacing.md),
            hStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -VTFTheme.Spacing.md)
        ])

        addTarget(self, action: #selector(vtfTapped), for: .touchUpInside)
        addTarget(self, action: #selector(vtfDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(vtfUp), for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit])
    }

    func vtfConfigure(with transaction: VTFTransaction, formatter: VTFCurrencyFormatter, now: Date) {
        let category = VTFCategory.vtfResolve(transaction.category)
        iconView.vtfConfigure(with: category)
        titleLabel.text = transaction.title
        subtitleLabel.text = "\(category.rawValue) · \(VTFDateHelper.vtfRelativeDayLabel(for: transaction.date, now: now))"
        amountLabel.text = formatter.vtfSignedString(amount: transaction.amount, type: transaction.type)
        amountLabel.textColor = VTFTheme.color(for: transaction.type)
    }

    @objc private func vtfTapped() {
        VTFHapticManager.shared.vtfSelection()
        vtfOnTap?()
    }

    @objc private func vtfDown() {
        UIView.animate(withDuration: 0.12) {
            self.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
            self.backgroundColor = VTFTheme.surfaceElevated
        }
    }

    @objc private func vtfUp() {
        UIView.animate(withDuration: 0.12) {
            self.transform = .identity
            self.backgroundColor = VTFTheme.surface
        }
    }
}
