//
//  VTFBarChartView.swift
//  Vault Finance
//
//  A lightweight grouped bar chart (income vs expense per month) drawn with
//  CALayers. No external dependencies.
//

import UIKit

/// Data point for the bar chart.
struct VTFBarChartEntry {
    let label: String
    let incomeValue: Double
    let expenseValue: Double
}

/// A grouped bar chart comparing income and expense across periods.
final class VTFBarChartView: UIView {

    private var entries: [VTFBarChartEntry] = []
    private let containerLayer = CALayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        layer.addSublayer(containerLayer)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
        layer.addSublayer(containerLayer)
    }

    func vtfSetEntries(_ entries: [VTFBarChartEntry]) {
        self.entries = entries
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        containerLayer.frame = bounds
        containerLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        vtfDraw()
    }

    private func vtfDraw() {
        guard entries.isEmpty == false, bounds.width > 0 else { return }

        let labelHeight: CGFloat = 18
        let chartHeight = bounds.height - labelHeight
        let maxValue = entries.flatMap { [$0.incomeValue, $0.expenseValue] }.max() ?? 1
        let safeMax = maxValue <= 0 ? 1 : maxValue

        let groupCount = CGFloat(entries.count)
        let groupWidth = bounds.width / groupCount
        let barWidth = min(14, groupWidth * 0.28)
        let barSpacing: CGFloat = 6

        for (index, entry) in entries.enumerated() {
            let groupX = CGFloat(index) * groupWidth
            let centerX = groupX + groupWidth / 2

            let incomeHeight = chartHeight * CGFloat(entry.incomeValue / safeMax)
            let expenseHeight = chartHeight * CGFloat(entry.expenseValue / safeMax)

            let incomeRect = CGRect(x: centerX - barWidth - barSpacing / 2,
                                    y: chartHeight - incomeHeight,
                                    width: barWidth,
                                    height: max(2, incomeHeight))
            let expenseRect = CGRect(x: centerX + barSpacing / 2,
                                     y: chartHeight - expenseHeight,
                                     width: barWidth,
                                     height: max(2, expenseHeight))

            containerLayer.addSublayer(vtfBar(rect: incomeRect, colors: VTFTheme.incomeGradientColors))
            containerLayer.addSublayer(vtfBar(rect: expenseRect, colors: VTFTheme.expenseGradientColors))

            let label = vtfTextLayer(text: entry.label,
                                     frame: CGRect(x: groupX, y: chartHeight + 2, width: groupWidth, height: labelHeight))
            containerLayer.addSublayer(label)
        }
    }

    private func vtfBar(rect: CGRect, colors: [CGColor]) -> CALayer {
        let gradient = CAGradientLayer()
        gradient.frame = rect
        gradient.colors = colors
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        gradient.cornerRadius = rect.width / 2
        gradient.cornerCurve = .continuous

        // Grow-up animation.
        let animation = CABasicAnimation(keyPath: "transform.scale.y")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 0.5
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        gradient.anchorPoint = CGPoint(x: 0.5, y: 1)
        gradient.add(animation, forKey: "vtfGrow")
        return gradient
    }

    private func vtfTextLayer(text: String, frame: CGRect) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.string = text
        textLayer.font = VTFTypography.caption()
        textLayer.fontSize = 11
        textLayer.foregroundColor = VTFTheme.textTertiary.cgColor
        textLayer.alignmentMode = .center
        textLayer.frame = frame
        textLayer.contentsScale = UIScreen.main.scale
        return textLayer
    }
}
