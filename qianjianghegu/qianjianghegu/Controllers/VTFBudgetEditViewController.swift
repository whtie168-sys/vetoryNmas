//
//  VTFBudgetEditViewController.swift
//  Vault Finance
//
//  Modal editor to set or remove a monthly budget for a category.
//

import UIKit

/// Editor for a single category budget.
final class VTFBudgetEditViewController: VTFBaseViewController {

    private let categoryRow = VTFFormRow(title: "Category", icon: "square.grid.2x2.fill")
    private let amountField = VTFTextField(placeholder: "Monthly limit", icon: "target")
    private let saveButton = VTFPrimaryButton(title: "Save Budget", systemIcon: "checkmark.circle.fill")
    private let removeButton = UIButton(type: .system)

    private var selectedCategory: VTFCategory
    private let isExisting: Bool

    init(category: VTFCategory?) {
        if let category = category {
            self.selectedCategory = category
            self.isExisting = VTFBudgetManager.shared.vtfBudget(for: category.rawValue) != nil
        } else {
            self.selectedCategory = .food
            self.isExisting = false
        }
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = isExisting ? "Edit Budget" : "New Budget"
        vtfApplyNavigationAppearance()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self, action: #selector(vtfCancel))
        vtfBuildLayout()
        vtfPopulate()
    }

    private func vtfBuildLayout() {
        vtfInstallScrollableContent()

        categoryRow.vtfOnTap = { [weak self] in self?.vtfPickCategory() }
        vtfContentStack.addArrangedSubview(categoryRow)

        amountField.vtfKeyboardType = .decimalPad
        amountField.vtfFont = VTFTypography.balance(30)
        vtfContentStack.addArrangedSubview(amountField)

        vtfContentStack.addArrangedSubview(vtfSpacer(VTFTheme.Spacing.sm))
        saveButton.addTarget(self, action: #selector(vtfSave), for: .touchUpInside)
        vtfContentStack.addArrangedSubview(saveButton)

        if isExisting {
            removeButton.setTitle("Remove Budget", for: .normal)
            removeButton.setTitleColor(VTFTheme.expense, for: .normal)
            removeButton.titleLabel?.font = VTFTypography.headline()
            removeButton.addTarget(self, action: #selector(vtfRemove), for: .touchUpInside)
            vtfContentStack.addArrangedSubview(removeButton)
        }
    }

    private func vtfPopulate() {
        vtfUpdateCategoryRow()
        if let existing = VTFBudgetManager.shared.vtfBudget(for: selectedCategory.rawValue) {
            amountField.vtfText = String(format: "%.2f", existing.monthlyLimit)
        }
    }

    private func vtfUpdateCategoryRow() {
        categoryRow.vtfSetValue(selectedCategory.rawValue, valueColor: selectedCategory.vtfAccentColor)
    }

    private func vtfPickCategory() {
        let picker = VTFCategoryPickerViewController(selected: selectedCategory)
        picker.vtfOnSelect = { [weak self] category in
            self?.selectedCategory = category
            self?.vtfUpdateCategoryRow()
            if let existing = VTFBudgetManager.shared.vtfBudget(for: category.rawValue) {
                self?.amountField.vtfText = String(format: "%.2f", existing.monthlyLimit)
            }
        }
        let nav = UINavigationController(rootViewController: picker)
        present(nav, animated: true)
    }

    @objc private func vtfSave() {
        view.endEditing(true)
        let raw = (amountField.vtfText ?? "").replacingOccurrences(of: ",", with: ".")
        guard let limit = Double(raw), limit > 0 else {
            VTFHapticManager.shared.vtfNotify(.error)
            let alert = UIAlertController(title: "Hold on", message: "Enter a limit greater than zero.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            alert.overrideUserInterfaceStyle = .dark
            present(alert, animated: true)
            return
        }
        VTFBudgetManager.shared.vtfSetBudget(category: selectedCategory.rawValue, monthlyLimit: limit)
        NotificationCenter.default.post(name: VTFStorageManager.vtfTransactionsChanged, object: nil)
        VTFHapticManager.shared.vtfNotify(.success)
        dismiss(animated: true)
    }

    @objc private func vtfRemove() {
        VTFBudgetManager.shared.vtfRemoveBudget(for: selectedCategory.rawValue)
        NotificationCenter.default.post(name: VTFStorageManager.vtfTransactionsChanged, object: nil)
        VTFHapticManager.shared.vtfImpact(.medium)
        dismiss(animated: true)
    }

    @objc private func vtfCancel() {
        dismiss(animated: true)
    }
}
