//
//  VTFCategoryIconView.swift
//  Vault Finance
//
//  A rounded badge displaying a category's glyph tinted with its accent colour.
//

import UIKit

/// A square rounded badge showing a category icon.
final class VTFCategoryIconView: UIView {

    private let iconView = UIImageView()

    init(size: CGFloat = 44) {
        super.init(frame: .zero)
        vtfSetup(size: size)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func vtfSetup(size: CGFloat) {
        layer.cornerRadius = size * 0.30
        layer.cornerCurve = .continuous
        translatesAutoresizingMaskIntoConstraints = false

        iconView.contentMode = .scaleAspectFit
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: size * 0.42, weight: .semibold)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconView)

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: size),
            heightAnchor.constraint(equalToConstant: size),
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    func vtfConfigure(with category: VTFCategory) {
        iconView.image = UIImage(systemName: category.vtfSymbolName)
        iconView.tintColor = category.vtfAccentColor
        backgroundColor = category.vtfAccentColor.withAlphaComponent(0.16)
    }
}
