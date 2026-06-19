//
//  VTFSectionHeaderView.swift
//  Vault Finance
//
//  A section header with a title and optional trailing action label.
//

import UIKit

/// Reusable header row: bold title on the left, optional action on the right.
final class VTFSectionHeaderView: UIView {

    private let titleLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    private var actionHandler: (() -> Void)?

    init(title: String, actionTitle: String? = nil) {
        super.init(frame: .zero)
        vtfSetup(title: title, actionTitle: actionTitle)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func vtfSetup(title: String, actionTitle: String?) {
        titleLabel.text = title
        titleLabel.font = VTFTypography.title()
        titleLabel.textColor = VTFTheme.textPrimary

        actionButton.setTitle(actionTitle, for: .normal)
        actionButton.setTitleColor(VTFTheme.accent, for: .normal)
        actionButton.titleLabel?.font = VTFTypography.subheadline()
        actionButton.isHidden = (actionTitle == nil)
        actionButton.addTarget(self, action: #selector(vtfTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [titleLabel, UIView(), actionButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    func vtfSetAction(_ handler: @escaping () -> Void) {
        actionHandler = handler
    }

    @objc private func vtfTapped() {
        actionHandler?()
    }
}
