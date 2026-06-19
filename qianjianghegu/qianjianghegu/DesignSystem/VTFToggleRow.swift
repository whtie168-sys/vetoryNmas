//
//  VTFToggleRow.swift
//  Vault Finance
//
//  A settings row with a leading icon, title, and a UISwitch.
//

import UIKit

/// Row hosting a labelled toggle switch.
final class VTFToggleRow: UIView {

    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let toggle = UISwitch()

    var vtfOnToggle: ((Bool) -> Void)?

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
        titleLabel.numberOfLines = 0

        toggle.onTintColor = VTFTheme.accent
        toggle.setContentHuggingPriority(.required, for: .horizontal)
        toggle.addTarget(self, action: #selector(vtfChanged), for: .valueChanged)

        let stack = UIStackView(arrangedSubviews: [iconView, titleLabel, toggle])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = VTFTheme.Spacing.md
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: 56),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: VTFTheme.Spacing.sm),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -VTFTheme.Spacing.sm),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: VTFTheme.Spacing.md),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -VTFTheme.Spacing.md)
        ])
    }

    func vtfSetOn(_ isOn: Bool) {
        toggle.setOn(isOn, animated: false)
    }

    @objc private func vtfChanged() {
        VTFHapticManager.shared.vtfSelection()
        vtfOnToggle?(toggle.isOn)
    }
}
