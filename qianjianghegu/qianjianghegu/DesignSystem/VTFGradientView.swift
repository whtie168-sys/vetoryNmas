//
//  VTFGradientView.swift
//  Vault Finance
//
//  A reusable view backed by a CAGradientLayer.
//

import UIKit

/// A view whose backing layer is a gradient. Set `vtfColors` to update.
final class VTFGradientView: UIView {

    override class var layerClass: AnyClass { CAGradientLayer.self }

    private var gradientLayer: CAGradientLayer {
        // swiftlint:disable:next force_cast
        return layer as! CAGradientLayer
    }

    /// Gradient direction presets.
    enum Direction {
        case horizontal
        case vertical
        case diagonal
    }

    init(colors: [CGColor], direction: Direction = .diagonal) {
        super.init(frame: .zero)
        vtfApply(colors: colors, direction: direction)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func vtfApply(colors: [CGColor], direction: Direction = .diagonal) {
        gradientLayer.colors = colors
        switch direction {
        case .horizontal:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        case .vertical:
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        case .diagonal:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        }
    }
}
