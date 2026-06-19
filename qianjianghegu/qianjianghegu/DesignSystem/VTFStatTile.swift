//
//  VTFStatTile.swift
//  Vault Finance
//
//  A compact metric tile: icon + caption + value, used on the dashboard and
//  statistics screens.
//

import UIKit

/// A small card-like tile presenting a single metric.
final class VTFStatTile: UIView {

    private let iconView = UIImageView()
    private let captionLabel = UILabel()
    private let valueLabel = UILabel()

    init(icon: String, caption: String, tint: UIColor) {
        super.init(frame: .zero)
        vtfSetup(icon: icon, caption: caption, tint: tint)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func vtfSetup(icon: String, caption: String, tint: UIColor) {
        backgroundColor = VTFTheme.surface
        layer.cornerRadius = VTFTheme.Radius.medium
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = VTFTheme.stroke.cgColor

        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = tint
        iconView.contentMode = .scaleAspectFit
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        iconView.setContentHuggingPriority(.required, for: .horizontal)

        captionLabel.text = caption
        captionLabel.font = VTFTypography.caption()
        captionLabel.textColor = VTFTheme.textTertiary

        valueLabel.font = VTFTypography.title()
        valueLabel.textColor = VTFTheme.textPrimary
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.6

        let stack = UIStackView(arrangedSubviews: [iconView, captionLabel, valueLabel])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = VTFTheme.Spacing.xs
        stack.setCustomSpacing(VTFTheme.Spacing.sm, after: iconView)
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: VTFTheme.Spacing.md),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -VTFTheme.Spacing.md),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: VTFTheme.Spacing.md),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -VTFTheme.Spacing.md)
        ])
    }

    func vtfSetValue(_ text: String) {
        valueLabel.text = text
    }

    func vtfSetValueColor(_ color: UIColor) {
        valueLabel.textColor = color
    }
}
