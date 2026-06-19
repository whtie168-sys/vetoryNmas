//
//  VTFProgressRingView.swift
//  Vault Finance
//
//  Circular progress ring used for savings rate / budget usage.
//

import UIKit

/// An animatable circular progress ring with a gradient stroke.
final class VTFProgressRingView: UIView {

    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private let gradientLayer = CAGradientLayer()
    private let centerLabel = UILabel()

    var lineWidth: CGFloat = 10 {
        didSet { vtfUpdatePaths() }
    }

    /// 0...1 progress value.
    private(set) var vtfProgress: CGFloat = 0

    var vtfTintColors: [CGColor] = VTFTheme.primaryGradientColors {
        didSet { gradientLayer.colors = vtfTintColors }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        vtfSetup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        vtfSetup()
    }

    private func vtfSetup() {
        backgroundColor = .clear

        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = UIColor(white: 1, alpha: 0.10).cgColor
        trackLayer.lineCap = .round
        layer.addSublayer(trackLayer)

        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.white.cgColor
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0

        gradientLayer.colors = vtfTintColors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.mask = progressLayer
        layer.addSublayer(gradientLayer)

        centerLabel.textAlignment = .center
        centerLabel.font = VTFTypography.title()
        centerLabel.textColor = VTFTheme.textPrimary
        centerLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(centerLabel)
        NSLayoutConstraint.activate([
            centerLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        trackLayer.frame = bounds
        progressLayer.frame = bounds
        vtfUpdatePaths()
    }

    private func vtfUpdatePaths() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = (min(bounds.width, bounds.height) - lineWidth) / 2
        let path = UIBezierPath(arcCenter: center,
                                radius: radius,
                                startAngle: -.pi / 2,
                                endAngle: 1.5 * .pi,
                                clockwise: true)
        trackLayer.path = path.cgPath
        trackLayer.lineWidth = lineWidth
        progressLayer.path = path.cgPath
        progressLayer.lineWidth = lineWidth
    }

    /// Set progress (0...1) and optionally a center text.
    func vtfSetProgress(_ value: CGFloat, text: String? = nil, animated: Bool = true) {
        vtfProgress = max(0, min(1, value))
        if let text = text { centerLabel.text = text }
        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = progressLayer.strokeEnd
            animation.toValue = vtfProgress
            animation.duration = 0.7
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            progressLayer.add(animation, forKey: "vtfProgress")
        }
        progressLayer.strokeEnd = vtfProgress
    }
}
