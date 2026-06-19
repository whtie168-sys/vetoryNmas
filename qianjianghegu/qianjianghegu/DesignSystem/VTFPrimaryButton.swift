//
//  VTFPrimaryButton.swift
//  Vault Finance
//
//  Gradient-filled primary action button with press animation + haptics.
//

import UIKit

/// A pill-shaped gradient button for primary calls to action.
final class VTFPrimaryButton: UIControl {

    private let gradientView = VTFGradientView(colors: VTFTheme.primaryGradientColors, direction: .horizontal)
    private let titleLabel = UILabel()
    private let iconView = UIImageView()
    private let stack = UIStackView()

    var vtfTitle: String = "" {
        didSet { titleLabel.text = vtfTitle }
    }

    init(title: String, systemIcon: String? = nil) {
        super.init(frame: .zero)
        vtfSetup(title: title, systemIcon: systemIcon)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func vtfSetup(title: String, systemIcon: String?) {
        layer.cornerRadius = VTFTheme.Radius.medium
        layer.cornerCurve = .continuous
        clipsToBounds = true

        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.isUserInteractionEnabled = false
        addSubview(gradientView)

        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = VTFTheme.Spacing.sm
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        if let systemIcon = systemIcon {
            iconView.image = UIImage(systemName: systemIcon)
            iconView.tintColor = .white
            iconView.contentMode = .scaleAspectFit
            iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
            stack.addArrangedSubview(iconView)
        }

        titleLabel.text = title
        titleLabel.font = VTFTypography.headline()
        titleLabel.textColor = .white
        stack.addArrangedSubview(titleLabel)

        vtfTitle = title

        NSLayoutConstraint.activate([
            gradientView.topAnchor.constraint(equalTo: topAnchor),
            gradientView.bottomAnchor.constraint(equalTo: bottomAnchor),
            gradientView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 54)
        ])
    }

    // MARK: - Press feedback

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        vtfAnimate(pressed: true)
        return super.beginTracking(touch, with: event)
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        vtfAnimate(pressed: false)
        VTFHapticManager.shared.vtfImpact(.medium)
        super.endTracking(touch, with: event)
    }

    override func cancelTracking(with event: UIEvent?) {
        vtfAnimate(pressed: false)
        super.cancelTracking(with: event)
    }

    private func vtfAnimate(pressed: Bool) {
        UIView.animate(withDuration: 0.18, delay: 0, options: [.allowUserInteraction, .curveEaseOut]) {
            self.transform = pressed ? CGAffineTransform(scaleX: 0.97, y: 0.97) : .identity
            self.alpha = pressed ? 0.92 : 1.0
        }
    }
}
