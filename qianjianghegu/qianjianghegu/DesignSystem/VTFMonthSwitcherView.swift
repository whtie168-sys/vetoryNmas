//
//  VTFMonthSwitcherView.swift
//  Vault Finance
//
//  A left/right month navigation header used by Insights and Reports.
//

import UIKit

/// Header with previous/next arrows and a centered month label.
final class VTFMonthSwitcherView: UIView {

    private let prevButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    private let titleLabel = UILabel()

    /// Called with -1 (previous) or +1 (next).
    var vtfOnChange: ((Int) -> Void)?

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

        vtfStyle(button: prevButton, system: "chevron.left")
        vtfStyle(button: nextButton, system: "chevron.right")
        prevButton.addTarget(self, action: #selector(vtfPrev), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(vtfNext), for: .touchUpInside)

        titleLabel.font = VTFTypography.headline()
        titleLabel.textColor = VTFTheme.textPrimary
        titleLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [prevButton, titleLabel, nextButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 52),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: VTFTheme.Spacing.md),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -VTFTheme.Spacing.md)
        ])
    }

    private func vtfStyle(button: UIButton, system: String) {
        button.setImage(UIImage(systemName: system), for: .normal)
        button.tintColor = VTFTheme.accent
        button.widthAnchor.constraint(equalToConstant: 44).isActive = true
    }

    func vtfSetTitle(_ title: String) {
        titleLabel.text = title
    }

    @objc private func vtfPrev() {
        VTFHapticManager.shared.vtfSelection()
        vtfOnChange?(-1)
    }

    @objc private func vtfNext() {
        VTFHapticManager.shared.vtfSelection()
        vtfOnChange?(1)
    }
}
