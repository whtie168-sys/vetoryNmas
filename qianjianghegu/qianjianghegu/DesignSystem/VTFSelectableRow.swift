//
//  VTFSelectableRow.swift
//  Vault Finance
//
//  A list row with a leading glyph/text, a title, and a trailing checkmark
//  when selected. Used by currency and similar pickers.
//

import UIKit

/// A single-selection list row with a checkmark.
final class VTFSelectableRow: UIControl {

    private let leadingLabel = UILabel()
    private let titleLabel = UILabel()
    private let checkmark = UIImageView()

    var vtfOnTap: (() -> Void)?

    init(title: String, leading: String, isSelected: Bool) {
        super.init(frame: .zero)
        vtfSetup(title: title, leading: leading, isSelected: isSelected)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func vtfSetup(title: String, leading: String, isSelected: Bool) {
        backgroundColor = VTFTheme.surface
        layer.cornerRadius = VTFTheme.Radius.medium
        layer.cornerCurve = .continuous
        layer.borderWidth = isSelected ? 2 : 1
        layer.borderColor = isSelected ? VTFTheme.accent.cgColor : VTFTheme.stroke.cgColor

        leadingLabel.text = leading
        leadingLabel.font = VTFTypography.title()
        leadingLabel.textColor = VTFTheme.accent
        leadingLabel.textAlignment = .center
        leadingLabel.setContentHuggingPriority(.required, for: .horizontal)
        leadingLabel.widthAnchor.constraint(equalToConstant: 32).isActive = true

        titleLabel.text = title
        titleLabel.font = VTFTypography.headline()
        titleLabel.textColor = VTFTheme.textPrimary

        checkmark.image = UIImage(systemName: "checkmark.circle.fill")
        checkmark.tintColor = VTFTheme.accent
        checkmark.isHidden = !isSelected
        checkmark.setContentHuggingPriority(.required, for: .horizontal)
        checkmark.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)

        let stack = UIStackView(arrangedSubviews: [leadingLabel, titleLabel, checkmark])
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
    }

    @objc private func vtfTapped() {
        vtfOnTap?()
    }
}
