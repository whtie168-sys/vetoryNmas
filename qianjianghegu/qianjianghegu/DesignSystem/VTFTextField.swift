//
//  VTFTextField.swift
//  Vault Finance
//
//  Styled text field with a leading icon, used across forms.
//

import UIKit

/// A rounded surface text field with a leading SF Symbol.
final class VTFTextField: UIView {

    private let iconView = UIImageView()
    private let textField = UITextField()

    var vtfText: String? {
        get { textField.text }
        set { textField.text = newValue }
    }

    var vtfKeyboardType: UIKeyboardType {
        get { textField.keyboardType }
        set { textField.keyboardType = newValue }
    }

    var vtfFont: UIFont {
        get { textField.font ?? VTFTypography.body() }
        set { textField.font = newValue }
    }

    var vtfTextColor: UIColor {
        get { textField.textColor ?? VTFTheme.textPrimary }
        set { textField.textColor = newValue }
    }

    /// Fired on every edit-changed event with the current text.
    var vtfOnTextChange: ((String) -> Void)?

    init(placeholder: String, icon: String) {
        super.init(frame: .zero)
        vtfSetup(placeholder: placeholder, icon: icon)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func vtfSetup(placeholder: String, icon: String) {
        backgroundColor = VTFTheme.surface
        layer.cornerRadius = VTFTheme.Radius.medium
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = VTFTheme.stroke.cgColor

        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = VTFTheme.textTertiary
        iconView.contentMode = .scaleAspectFit
        iconView.setContentHuggingPriority(.required, for: .horizontal)
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)

        textField.font = VTFTypography.body()
        textField.textColor = VTFTheme.textPrimary
        textField.tintColor = VTFTheme.accent
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: VTFTheme.textTertiary])
        textField.delegate = self
        textField.addTarget(self, action: #selector(vtfEditingChanged), for: .editingChanged)

        let stack = UIStackView(arrangedSubviews: [iconView, textField])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = VTFTheme.Spacing.md
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: 56),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: VTFTheme.Spacing.sm),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -VTFTheme.Spacing.sm),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: VTFTheme.Spacing.md),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -VTFTheme.Spacing.md)
        ])
    }
    func vtfSetValue(_ text: String) {
        textField.text = text
    }

    /// Make the underlying field the first responder.
    @discardableResult
    func vtfBecomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }

    @objc private func vtfEditingChanged() {
        vtfOnTextChange?(textField.text ?? "")
    }
}

extension VTFTextField: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.layer.borderColor = VTFTheme.accent.cgColor
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.layer.borderColor = VTFTheme.stroke.cgColor
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
