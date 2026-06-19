//
//  VTFBalanceCardView.swift
//  Vault Finance
//
//  Hero gradient card showing the total balance plus income/expense pills.
//

import UIKit

/// The dashboard's headline balance card.
final class VTFBalanceCardView: UIView {

    private let gradientView = VTFGradientView(colors: VTFTheme.primaryGradientColors, direction: .diagonal)
    private let captionLabel = UILabel()
    private let balanceLabel = UILabel()
    private let incomeChip = VTFBalanceChip(title: "Income", icon: "arrow.down.left")
    private let expenseChip = VTFBalanceChip(title: "Expense", icon: "arrow.up.right")
    private let decorCircle = UIView()

    init() {
        super.init(frame: .zero)
        vtfSetup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func vtfSetup() {
        layer.cornerRadius = VTFTheme.Radius.large
        layer.cornerCurve = .continuous
        clipsToBounds = true
        VTFTheme.applySoftShadow(to: self, opacity: 0.45, radius: 24, yOffset: 14)

        gradientView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(gradientView)

        // Decorative translucent circle for depth.
        decorCircle.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        decorCircle.layer.cornerRadius = 90
        decorCircle.translatesAutoresizingMaskIntoConstraints = false
        gradientView.addSubview(decorCircle)

        captionLabel.text = "Total Balance"
        captionLabel.font = VTFTypography.subheadline()
        captionLabel.textColor = UIColor.white.withAlphaComponent(0.85)

        balanceLabel.font = VTFTypography.balance(42)
        balanceLabel.textColor = .white
        balanceLabel.adjustsFontSizeToFitWidth = true
        balanceLabel.minimumScaleFactor = 0.5

        let chipStack = UIStackView(arrangedSubviews: [incomeChip, expenseChip])
        chipStack.axis = .horizontal
        chipStack.distribution = .fillEqually
        chipStack.spacing = VTFTheme.Spacing.md

        let stack = UIStackView(arrangedSubviews: [captionLabel, balanceLabel, chipStack])
        stack.axis = .vertical
        stack.spacing = VTFTheme.Spacing.sm
        stack.setCustomSpacing(VTFTheme.Spacing.lg, after: balanceLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false
        gradientView.addSubview(stack)

        NSLayoutConstraint.activate([
            gradientView.topAnchor.constraint(equalTo: topAnchor),
            gradientView.bottomAnchor.constraint(equalTo: bottomAnchor),
            gradientView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: trailingAnchor),

            decorCircle.widthAnchor.constraint(equalToConstant: 180),
            decorCircle.heightAnchor.constraint(equalToConstant: 180),
            decorCircle.trailingAnchor.constraint(equalTo: gradientView.trailingAnchor, constant: 60),
            decorCircle.topAnchor.constraint(equalTo: gradientView.topAnchor, constant: -70),

            stack.topAnchor.constraint(equalTo: gradientView.topAnchor, constant: VTFTheme.Spacing.lg),
            stack.bottomAnchor.constraint(equalTo: gradientView.bottomAnchor, constant: -VTFTheme.Spacing.lg),
            stack.leadingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: VTFTheme.Spacing.lg),
            stack.trailingAnchor.constraint(equalTo: gradientView.trailingAnchor, constant: -VTFTheme.Spacing.lg)
        ])
    }

    func vtfConfigure(balance: String, income: String, expense: String) {
        balanceLabel.text = balance
        incomeChip.vtfSetValue(income)
        expenseChip.vtfSetValue(expense)
    }
}

/// Small translucent pill inside the balance card.
final class VTFBalanceChip: UIView {

    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let iconView = UIImageView()

    init(title: String, icon: String) {
        super.init(frame: .zero)
        vtfSetup(title: title, icon: icon)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func vtfSetup(title: String, icon: String) {
        backgroundColor = UIColor.white.withAlphaComponent(0.16)
        layer.cornerRadius = VTFTheme.Radius.small
        layer.cornerCurve = .continuous

        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = .white
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
        iconView.setContentHuggingPriority(.required, for: .horizontal)

        titleLabel.text = title
        titleLabel.font = VTFTypography.caption()
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.85)

        valueLabel.font = VTFTypography.headline()
        valueLabel.textColor = .white
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.6

        let titleRow = UIStackView(arrangedSubviews: [iconView, titleLabel])
        titleRow.axis = .horizontal
        titleRow.spacing = 4
        titleRow.alignment = .center

        let stack = UIStackView(arrangedSubviews: [titleRow, valueLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: VTFTheme.Spacing.sm + 2),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -(VTFTheme.Spacing.sm + 2)),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: VTFTheme.Spacing.md),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -VTFTheme.Spacing.md)
        ])
    }

    func vtfSetValue(_ text: String) {
        valueLabel.text = text
    }
}
