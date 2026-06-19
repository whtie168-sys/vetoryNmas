//
//  VTFBudgetRow.swift
//  Vault Finance
//
//  A budget row: category, spent/limit, progress bar (red when over budget).
//

import UIKit

/// Row showing one category's budget progress.
final class VTFBudgetRow: UIControl {

    private let iconView = VTFCategoryIconView(size: 40)
    private let nameLabel = UILabel()
    private let amountLabel = UILabel()
    private let trackView = UIView()
    private let fillView = UIView()
    private var fillWidth: NSLayoutConstraint?
    private var fraction: CGFloat = 0

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

        nameLabel.font = VTFTypography.headline()
        nameLabel.textColor = VTFTheme.textPrimary
        amountLabel.font = VTFTypography.subheadline()
        amountLabel.textColor = VTFTheme.textSecondary
        amountLabel.textAlignment = .right
        amountLabel.setContentHuggingPriority(.required, for: .horizontal)

        let topRow = UIStackView(arrangedSubviews: [iconView, nameLabel, amountLabel])
        topRow.axis = .horizontal
        topRow.alignment = .center
        topRow.spacing = VTFTheme.Spacing.md

        trackView.backgroundColor = UIColor(white: 1, alpha: 0.08)
        trackView.layer.cornerRadius = 4
        trackView.translatesAutoresizingMaskIntoConstraints = false
        fillView.layer.cornerRadius = 4
        fillView.translatesAutoresizingMaskIntoConstraints = false
        trackView.addSubview(fillView)

        let vStack = UIStackView(arrangedSubviews: [topRow, trackView])
        vStack.axis = .vertical
        vStack.spacing = VTFTheme.Spacing.sm
        vStack.isUserInteractionEnabled = false
        vStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(vStack)

        fillWidth = fillView.widthAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: topAnchor, constant: VTFTheme.Spacing.md),
            vStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -VTFTheme.Spacing.md),
            vStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: VTFTheme.Spacing.md),
            vStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -VTFTheme.Spacing.md),
            trackView.heightAnchor.constraint(equalToConstant: 8),
            fillView.leadingAnchor.constraint(equalTo: trackView.leadingAnchor),
            fillView.topAnchor.constraint(equalTo: trackView.topAnchor),
            fillView.bottomAnchor.constraint(equalTo: trackView.bottomAnchor),
            fillWidth!
        ])

        addTarget(self, action: #selector(vtfTapped), for: .touchUpInside)
    }

    func vtfConfigure(category: VTFCategory, spent: String, limit: String, fraction: Double, isOver: Bool) {
        iconView.vtfConfigure(with: category)
        nameLabel.text = category.rawValue
        amountLabel.text = "\(spent) / \(limit)"
        amountLabel.textColor = isOver ? VTFTheme.expense : VTFTheme.textSecondary
        fillView.backgroundColor = isOver ? VTFTheme.expense : category.vtfAccentColor
        self.fraction = CGFloat(max(0, min(1, fraction)))
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        fillWidth?.constant = trackView.bounds.width * fraction
    }

    @objc private func vtfTapped() {
        VTFHapticManager.shared.vtfSelection()
        vtfOnTap?()
    }
}
