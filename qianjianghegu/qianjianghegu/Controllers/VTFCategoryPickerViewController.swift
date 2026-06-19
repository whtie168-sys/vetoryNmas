//
//  VTFCategoryPickerViewController.swift
//  Vault Finance
//
//  Modal grid for choosing a category. Returns selection via callback.
//

import UIKit

/// Presents the fixed category list as a tappable grid.
final class VTFCategoryPickerViewController: VTFBaseViewController {

    var vtfOnSelect: ((VTFCategory) -> Void)?

    private var selected: VTFCategory

    init(selected: VTFCategory) {
        self.selected = selected
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Choose Category"
        vtfApplyNavigationAppearance()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                           target: self, action: #selector(vtfClose))
        vtfBuildGrid()
    }

    private func vtfBuildGrid() {
        vtfInstallScrollableContent()

        let columns = 2
        var rowStack: UIStackView?
        for (index, category) in VTFCategory.allCases.enumerated() {
            if index % columns == 0 {
                let newRow = UIStackView()
                newRow.axis = .horizontal
                newRow.distribution = .fillEqually
                newRow.spacing = VTFTheme.Spacing.md
                vtfContentStack.addArrangedSubview(newRow)
                rowStack = newRow
            }
            let tile = vtfMakeTile(for: category)
            rowStack?.addArrangedSubview(tile)
        }
    }

    private func vtfMakeTile(for category: VTFCategory) -> UIControl {
        let tile = VTFCategoryTile(category: category, isSelected: category == selected)
        tile.vtfOnTap = { [weak self] in
            VTFHapticManager.shared.vtfSelection()
            self?.vtfOnSelect?(category)
            self?.dismiss(animated: true)
        }
        return tile
    }

    @objc private func vtfClose() {
        dismiss(animated: true)
    }
}

/// A single category tile in the picker grid.
final class VTFCategoryTile: UIControl {

    private let iconView = VTFCategoryIconView(size: 50)
    private let nameLabel = UILabel()
    var vtfOnTap: (() -> Void)?

    init(category: VTFCategory, isSelected: Bool) {
        super.init(frame: .zero)
        vtfSetup(category: category, isSelected: isSelected)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func vtfSetup(category: VTFCategory, isSelected: Bool) {
        backgroundColor = VTFTheme.surface
        layer.cornerRadius = VTFTheme.Radius.medium
        layer.cornerCurve = .continuous
        layer.borderWidth = isSelected ? 2 : 1
        layer.borderColor = isSelected ? category.vtfAccentColor.cgColor : VTFTheme.stroke.cgColor

        iconView.vtfConfigure(with: category)

        nameLabel.text = category.rawValue
        nameLabel.font = VTFTypography.headline()
        nameLabel.textColor = VTFTheme.textPrimary

        let stack = UIStackView(arrangedSubviews: [iconView, nameLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = VTFTheme.Spacing.sm
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 120),
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        addTarget(self, action: #selector(vtfTapped), for: .touchUpInside)
        addTarget(self, action: #selector(vtfDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(vtfUp), for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit])
    }

    @objc private func vtfTapped() { vtfOnTap?() }

    @objc private func vtfDown() {
        UIView.animate(withDuration: 0.12) { self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96) }
    }

    @objc private func vtfUp() {
        UIView.animate(withDuration: 0.12) { self.transform = .identity }
    }
}
