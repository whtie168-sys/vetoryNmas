//
//  VTFDonutChartView.swift
//  Vault Finance
//
//  A donut/pie chart for category expense breakdown.
//

import UIKit

/// A single slice of the donut chart.
struct VTFDonutSlice {
    let value: Double
    let color: UIColor
}

/// A donut chart rendering proportional slices with an animated draw-in.
final class VTFDonutChartView: UIView {

    private var slices: [VTFDonutSlice] = []
    private let centerLabel = UILabel()
    private let captionLabel = UILabel()
    private var sliceLayers: [CAShapeLayer] = []

    var lineWidth: CGFloat = 22

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
        centerLabel.font = VTFTypography.title()
        centerLabel.textColor = VTFTheme.textPrimary
        centerLabel.textAlignment = .center
        captionLabel.font = VTFTypography.caption()
        captionLabel.textColor = VTFTheme.textTertiary
        captionLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [centerLabel, captionLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    func vtfSetSlices(_ slices: [VTFDonutSlice], centerText: String?, caption: String?) {
        self.slices = slices
        centerLabel.text = centerText
        captionLabel.text = caption
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        sliceLayers.forEach { $0.removeFromSuperlayer() }
        sliceLayers.removeAll()
        vtfDraw()
    }

    private func vtfDraw() {
        let total = slices.reduce(0) { $0 + $1.value }
        guard total > 0 else {
            vtfDrawEmptyTrack()
            return
        }

        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = (min(bounds.width, bounds.height) - lineWidth) / 2
        var startAngle: CGFloat = -.pi / 2

        for slice in slices {
            let fraction = CGFloat(slice.value / total)
            let endAngle = startAngle + fraction * 2 * .pi
            let path = UIBezierPath(arcCenter: center,
                                    radius: radius,
                                    startAngle: startAngle,
                                    endAngle: endAngle,
                                    clockwise: true)
            let shape = CAShapeLayer()
            shape.path = path.cgPath
            shape.strokeColor = slice.color.cgColor
            shape.fillColor = UIColor.clear.cgColor
            shape.lineWidth = lineWidth
            shape.lineCap = .butt
            layer.insertSublayer(shape, at: 0)
            sliceLayers.append(shape)

            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = 0
            animation.toValue = 1
            animation.duration = 0.6
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            shape.add(animation, forKey: "vtfDraw")

            startAngle = endAngle
        }
    }

    private func vtfDrawEmptyTrack() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = (min(bounds.width, bounds.height) - lineWidth) / 2
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        let shape = CAShapeLayer()
        shape.path = path.cgPath
        shape.strokeColor = UIColor(white: 1, alpha: 0.08).cgColor
        shape.fillColor = UIColor.clear.cgColor
        shape.lineWidth = lineWidth
        layer.insertSublayer(shape, at: 0)
        sliceLayers.append(shape)
    }
}
