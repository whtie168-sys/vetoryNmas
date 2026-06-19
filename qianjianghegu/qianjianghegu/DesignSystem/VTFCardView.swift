//
//  VTFCardView.swift
//  Vault Finance
//
//  Rounded surface container used throughout the app for grouped content.
//

import UIKit

/// A padded, rounded card surface with optional soft shadow.
final class VTFCardView: UIView {

    private let contentStack = UIStackView()

    init(padding: CGFloat = VTFTheme.Spacing.md,
         cornerRadius: CGFloat = VTFTheme.Radius.medium,
         elevated: Bool = false) {
        super.init(frame: .zero)
        vtfSetup(padding: padding, cornerRadius: cornerRadius, elevated: elevated)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func vtfSetup(padding: CGFloat, cornerRadius: CGFloat, elevated: Bool) {
        backgroundColor = elevated ? VTFTheme.surfaceElevated : VTFTheme.surface
        layer.cornerRadius = cornerRadius
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = VTFTheme.stroke.cgColor
        if elevated {
            VTFTheme.applySoftShadow(to: self)
        }

        contentStack.axis = .vertical
        contentStack.spacing = VTFTheme.Spacing.sm
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding)
        ])
    }

    /// Add an arranged subview to the card's vertical stack.
    func vtfAddArranged(_ view: UIView) {
        contentStack.addArrangedSubview(view)
    }

    /// Adjust spacing of the internal content stack.
    func vtfSetSpacing(_ spacing: CGFloat) {
        contentStack.spacing = spacing
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.borderColor = VTFTheme.stroke.cgColor
    }
}
