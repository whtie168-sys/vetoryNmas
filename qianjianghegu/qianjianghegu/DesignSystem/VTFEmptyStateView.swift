//
//  VTFEmptyStateView.swift
//  Vault Finance
//
//  A reusable placeholder shown when a list has no content.
//

import UIKit

/// An icon + title + message empty placeholder.
final class VTFEmptyStateView: UIView {

    private let iconContainer = VTFGradientView(colors: VTFTheme.primaryGradientColors, direction: .diagonal)
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()

    init(icon: String, title: String, message: String) {
        super.init(frame: .zero)
        vtfSetup(icon: icon, title: title, message: message)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func vtfSetup(icon: String, title: String, message: String) {
        iconContainer.layer.cornerRadius = 28
        iconContainer.layer.cornerCurve = .continuous
        iconContainer.translatesAutoresizingMaskIntoConstraints = false

        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 26, weight: .semibold)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(iconView)

        titleLabel.text = title
        titleLabel.font = VTFTypography.title()
        titleLabel.textColor = VTFTheme.textPrimary
        titleLabel.textAlignment = .center

        messageLabel.text = message
        messageLabel.font = VTFTypography.body()
        messageLabel.textColor = VTFTheme.textSecondary
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [iconContainer, titleLabel, messageLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = VTFTheme.Spacing.md
        stack.setCustomSpacing(VTFTheme.Spacing.lg, after: iconContainer)
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            iconContainer.widthAnchor.constraint(equalToConstant: 76),
            iconContainer.heightAnchor.constraint(equalToConstant: 76),
            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: VTFTheme.Spacing.xl),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -VTFTheme.Spacing.xl)
        ])
    }
}
