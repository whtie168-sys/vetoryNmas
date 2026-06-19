//
//  VTFSegmentedControl.swift
//  Vault Finance
//
//  A custom pill segmented control (e.g. Income / Expense toggle) with a
//  sliding gradient indicator.
//

import UIKit

/// A two-or-more option pill control with an animated selection indicator.
final class VTFSegmentedControl: UIControl {

    private let backgroundView = UIView()
    private let indicator = VTFGradientView(colors: VTFTheme.primaryGradientColors, direction: .horizontal)
    private let stack = UIStackView()
    private var buttons: [UIButton] = []
    private var indicatorLeading: NSLayoutConstraint?
    private var indicatorWidth: NSLayoutConstraint?

    private(set) var vtfSelectedIndex: Int = 0

    let titles: [String]

    init(titles: [String]) {
        self.titles = titles
        super.init(frame: .zero)
        vtfSetup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func vtfSetup() {
        backgroundView.backgroundColor = VTFTheme.surfaceElevated
        backgroundView.layer.cornerRadius = VTFTheme.Radius.medium
        backgroundView.layer.cornerCurve = .continuous
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundView)

        indicator.layer.cornerRadius = VTFTheme.Radius.medium - 4
        indicator.layer.cornerCurve = .continuous
        indicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(indicator)

        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        for (index, title) in titles.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = VTFTypography.subheadline()
            button.setTitleColor(VTFTheme.textPrimary, for: .normal)
            button.tag = index
            button.addTarget(self, action: #selector(vtfHandleTap(_:)), for: .touchUpInside)
            buttons.append(button)
            stack.addArrangedSubview(button)
        }

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            indicator.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            indicator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 48)
        ])

        let leading = indicator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4)
        let width = indicator.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0 / CGFloat(titles.count), constant: -8)
        indicatorLeading = leading
        indicatorWidth = width
        NSLayoutConstraint.activate([leading, width])

        vtfUpdateButtonColors()
    }

    @objc private func vtfHandleTap(_ sender: UIButton) {
        vtfSetSelectedIndex(sender.tag, animated: true)
        VTFHapticManager.shared.vtfSelection()
        sendActions(for: .valueChanged)
    }

    func vtfSetSelectedIndex(_ index: Int, animated: Bool) {
        guard index >= 0, index < titles.count else { return }
        vtfSelectedIndex = index
        let segmentWidth = bounds.width / CGFloat(titles.count)
        indicatorLeading?.constant = 4 + segmentWidth * CGFloat(index)
        let updates = {
            self.layoutIfNeeded()
            self.vtfUpdateButtonColors()
        }
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.5, options: [.curveEaseOut], animations: updates)
        } else {
            updates()
        }
    }

    private func vtfUpdateButtonColors() {
        for (index, button) in buttons.enumerated() {
            button.setTitleColor(index == vtfSelectedIndex ? .white : VTFTheme.textSecondary, for: .normal)
            button.titleLabel?.font = index == vtfSelectedIndex ? VTFTypography.headline() : VTFTypography.subheadline()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        vtfSetSelectedIndex(vtfSelectedIndex, animated: false)
    }
}
