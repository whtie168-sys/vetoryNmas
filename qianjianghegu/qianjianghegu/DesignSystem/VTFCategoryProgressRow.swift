//
//  VTFCategoryProgressRow.swift
//  Vault Finance
//
//  A category row with a coloured progress bar showing its share of spending.
//

import UIKit

/// Row: category badge, name + count, amount, and a share progress bar.
final class VTFCategoryProgressRow: UIControl {

    private let iconView = VTFCategoryIconView(size: 40)
    private let nameLabel = UILabel()
    private let countLabel = UILabel()
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
        countLabel.font = VTFTypography.caption()
        countLabel.textColor = VTFTheme.textTertiary
        amountLabel.font = VTFTypography.monoAmount(16)
        amountLabel.textColor = VTFTheme.textPrimary
        amountLabel.textAlignment = .right
        amountLabel.setContentHuggingPriority(.required, for: .horizontal)

        let textStack = UIStackView(arrangedSubviews: [nameLabel, countLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        let topRow = UIStackView(arrangedSubviews: [iconView, textStack, amountLabel])
        topRow.axis = .horizontal
        topRow.alignment = .center
        topRow.spacing = VTFTheme.Spacing.md

        trackView.backgroundColor = UIColor(white: 1, alpha: 0.08)
        trackView.layer.cornerRadius = 3
        trackView.translatesAutoresizingMaskIntoConstraints = false
        fillView.layer.cornerRadius = 3
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
            trackView.heightAnchor.constraint(equalToConstant: 6),
            fillView.leadingAnchor.constraint(equalTo: trackView.leadingAnchor),
            fillView.topAnchor.constraint(equalTo: trackView.topAnchor),
            fillView.bottomAnchor.constraint(equalTo: trackView.bottomAnchor),
            fillWidth!
        ])

        addTarget(self, action: #selector(vtfTapped), for: .touchUpInside)
    }

    func vtfConfigure(category: VTFCategory, amount: String, fraction: Double, count: Int) {
        iconView.vtfConfigure(with: category)
        nameLabel.text = category.rawValue
        countLabel.text = count == 1 ? "1 transaction" : "\(count) transactions"
        amountLabel.text = amount
        fillView.backgroundColor = category.vtfAccentColor
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
