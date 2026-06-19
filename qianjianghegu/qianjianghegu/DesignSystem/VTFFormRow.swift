//
//  VTFFormRow.swift
//  Vault Finance
//
//  A tappable form row: leading icon, title, trailing value + chevron.
//

import UIKit

/// A disclosure-style row used in forms (category, date, etc).
final class VTFFormRow: UIControl {

    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let chevron = UIImageView()

    var vtfOnTap: (() -> Void)?

    init(title: String, icon: String) {
        super.init(frame: .zero)
        vtfSetup(title: title, icon: icon)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func vtfSetup(title: String, icon: String) {
        backgroundColor = VTFTheme.surface
        layer.cornerRadius = VTFTheme.Radius.medium
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = VTFTheme.stroke.cgColor

        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = VTFTheme.textTertiary
        iconView.contentMode = .scaleAspectFit
        iconView.setContentHuggingPriority(.required, for: .horizontal)
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)

        titleLabel.text = title
        titleLabel.font = VTFTypography.body()
        titleLabel.textColor = VTFTheme.textPrimary

        valueLabel.font = VTFTypography.subheadline()
        valueLabel.textColor = VTFTheme.textSecondary
        valueLabel.textAlignment = .right

        chevron.image = UIImage(systemName: "chevron.right")
        chevron.tintColor = VTFTheme.textTertiary
        chevron.setContentHuggingPriority(.required, for: .horizontal)
        chevron.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)

        let stack = UIStackView(arrangedSubviews: [iconView, titleLabel, valueLabel, chevron])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = VTFTheme.Spacing.md
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: 56),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: VTFTheme.Spacing.sm),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -VTFTheme.Spacing.sm),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: VTFTheme.Spacing.md),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -VTFTheme.Spacing.md)
        ])

        addTarget(self, action: #selector(vtfTapped), for: .touchUpInside)
        addTarget(self, action: #selector(vtfDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(vtfUp), for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit])
    }

    func vtfSetValue(_ text: String, valueColor: UIColor) {
        valueLabel.text = text
        valueLabel.textColor = valueColor
    }

    @objc private func vtfTapped() {
        VTFHapticManager.shared.vtfSelection()
        vtfOnTap?()
    }

    @objc private func vtfDown() {
        UIView.animate(withDuration: 0.12) { self.backgroundColor = VTFTheme.surfaceElevated }
    }

    @objc private func vtfUp() {
        UIView.animate(withDuration: 0.12) { self.backgroundColor = VTFTheme.surface }
    }
}
