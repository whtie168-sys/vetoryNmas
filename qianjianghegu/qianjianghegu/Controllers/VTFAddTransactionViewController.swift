//
//  VTFAddTransactionViewController.swift
//  Vault Finance
//
//  Modal form to create (or edit) a transaction: type toggle, amount, title,
//  category picker, date, and optional note.
//

import UIKit

/// Form for creating or editing a transaction.
final class VTFAddTransactionViewController: VTFBaseViewController {

    private let typeControl = VTFSegmentedControl(titles: ["Expense", "Income"])
    private let amountField = VTFTextField(placeholder: "0.00", icon: "dollarsign.circle.fill")
    private let titleField = VTFTextField(placeholder: "Title (e.g. Coffee)", icon: "textformat")
    private let categoryRow = VTFFormRow(title: "Category", icon: "square.grid.2x2.fill")
    private let dateRow = VTFFormRow(title: "Date", icon: "calendar")
    private let noteField = VTFTextField(placeholder: "Note (optional)", icon: "note.text")
    private let saveButton = VTFPrimaryButton(title: "Save Transaction", systemIcon: "checkmark.circle.fill")
    private let datePicker = UIDatePicker()

    /// The transaction being edited, if any.
    private let editingTransaction: VTFTransaction?
    private var selectedType: VTFTransactionType = .expense
    private var selectedCategory: VTFCategory = .food
    private var selectedDate = Date()

    init(editing transaction: VTFTransaction? = nil) {
        self.editingTransaction = transaction
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = editingTransaction == nil ? "New Transaction" : "Edit Transaction"
        vtfApplyNavigationAppearance()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self, action: #selector(vtfCancel))
        vtfBuildLayout()
        vtfConfigureDatePicker()
        vtfPopulateIfEditing()
        vtfUpdateAmountTint()
    }

    private func vtfBuildLayout() {
        vtfInstallScrollableContent()

        typeControl.translatesAutoresizingMaskIntoConstraints = false
        typeControl.addTarget(self, action: #selector(vtfTypeChanged), for: .valueChanged)
        vtfContentStack.addArrangedSubview(typeControl)

        amountField.vtfKeyboardType = .decimalPad
        amountField.vtfFont = VTFTypography.balance(34)
        vtfContentStack.addArrangedSubview(amountField)

        vtfContentStack.addArrangedSubview(titleField)

        categoryRow.vtfOnTap = { [weak self] in self?.vtfOpenCategoryPicker() }
        vtfContentStack.addArrangedSubview(categoryRow)

        dateRow.vtfOnTap = { [weak self] in self?.vtfToggleDatePicker() }
        vtfContentStack.addArrangedSubview(dateRow)

        datePicker.isHidden = true
        vtfContentStack.addArrangedSubview(datePicker)

        vtfContentStack.addArrangedSubview(noteField)

        vtfContentStack.addArrangedSubview(vtfSpacer(VTFTheme.Spacing.sm))
        saveButton.addTarget(self, action: #selector(vtfSave), for: .touchUpInside)
        vtfContentStack.addArrangedSubview(saveButton)

        vtfUpdateCategoryRow()
        vtfUpdateDateRow()
    }

    private func vtfConfigureDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.tintColor = VTFTheme.accent
        datePicker.overrideUserInterfaceStyle = .dark
        datePicker.maximumDate = Date()
        datePicker.addTarget(self, action: #selector(vtfDateChanged), for: .valueChanged)
    }

    private func vtfPopulateIfEditing() {
        guard let tx = editingTransaction else { return }
        selectedType = tx.type
        selectedCategory = VTFCategory.vtfResolve(tx.category)
        selectedDate = tx.date
        typeControl.vtfSetSelectedIndex(tx.type == .expense ? 0 : 1, animated: false)
        amountField.vtfText = String(format: "%.2f", tx.amount)
        titleField.vtfText = tx.title
        noteField.vtfText = tx.note ?? ""
        vtfUpdateCategoryRow()
        vtfUpdateDateRow()
    }

    // MARK: - Updates

    @objc private func vtfTypeChanged() {
        selectedType = typeControl.vtfSelectedIndex == 0 ? .expense : .income
        vtfUpdateAmountTint()
    }

    private func vtfUpdateAmountTint() {
        amountField.vtfTextColor = VTFTheme.color(for: selectedType)
    }

    private func vtfUpdateCategoryRow() {
        categoryRow.vtfSetValue(selectedCategory.rawValue, valueColor: selectedCategory.vtfAccentColor)
    }

    private func vtfUpdateDateRow() {
        dateRow.vtfSetValue(VTFDateHelper.vtfMediumDateLabel(for: selectedDate), valueColor: VTFTheme.textSecondary)
        datePicker.date = selectedDate
    }

    @objc private func vtfDateChanged() {
        selectedDate = datePicker.date
        vtfUpdateDateRow()
    }

    private func vtfToggleDatePicker() {
        UIView.animate(withDuration: 0.25) {
            self.datePicker.isHidden.toggle()
            self.datePicker.alpha = self.datePicker.isHidden ? 0 : 1
        }
    }

    private func vtfOpenCategoryPicker() {
        let picker = VTFCategoryPickerViewController(selected: selectedCategory)
        picker.vtfOnSelect = { [weak self] category in
            self?.selectedCategory = category
            self?.vtfUpdateCategoryRow()
        }
        let nav = UINavigationController(rootViewController: picker)
        present(nav, animated: true)
    }

    // MARK: - Save

    @objc private func vtfSave() {
        view.endEditing(true)
        guard let amount = vtfParseAmount(amountField.vtfText), amount > 0 else {
            vtfShowError("Enter a valid amount greater than zero.")
            return
        }
        let title = (titleField.vtfText ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard title.isEmpty == false else {
            vtfShowError("Please enter a title.")
            return
        }
        let note = (noteField.vtfText ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        let transaction = VTFTransaction(id: editingTransaction?.id ?? UUID(),
                                         title: title,
                                         amount: amount,
                                         type: selectedType,
                                         category: selectedCategory.rawValue,
                                         date: selectedDate,
                                         note: note.isEmpty ? nil : note)
        if editingTransaction == nil {
            VTFStorageManager.shared.vtfAppend(transaction)
        } else {
            VTFStorageManager.shared.vtfUpdate(transaction)
        }
        VTFHapticManager.shared.vtfNotify(.success)
        dismiss(animated: true)
    }

    private func vtfParseAmount(_ text: String?) -> Double? {
        guard let text = text?.trimmingCharacters(in: .whitespaces), text.isEmpty == false else { return nil }
        return Double(text.replacingOccurrences(of: ",", with: "."))
    }

    private func vtfShowError(_ message: String) {
        VTFHapticManager.shared.vtfNotify(.error)
        let alert = UIAlertController(title: "Hold on", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.overrideUserInterfaceStyle = .dark
        present(alert, animated: true)
    }

    @objc private func vtfCancel() {
        dismiss(animated: true)
    }
}
