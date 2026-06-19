//
//  VTFCurrencyPickerViewController.swift
//  Vault Finance
//
//  List of supported display currencies. Selecting one updates settings and
//  re-formats amounts app-wide.
//

import UIKit

/// Lets the user pick the display currency.
final class VTFCurrencyPickerViewController: VTFBaseViewController {

    private let listStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Currency"
        vtfApplyNavigationAppearance()
        vtfBuildLayout()
    }

    private func vtfBuildLayout() {
        vtfInstallScrollableContent()

        let caption = UILabel()
        caption.text = "Choose how amounts are displayed. This only changes formatting — no exchange rates are applied."
        caption.font = VTFTypography.caption()
        caption.textColor = VTFTheme.textTertiary
        caption.numberOfLines = 0
        vtfContentStack.addArrangedSubview(caption)

        listStack.axis = .vertical
        listStack.spacing = VTFTheme.Spacing.sm
        vtfContentStack.addArrangedSubview(listStack)

        vtfRenderList()
    }

    private func vtfRenderList() {
        listStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let current = VTFSettingsStore.shared.vtfCurrency
        for currency in VTFCurrency.allCases {
            let row = VTFSelectableRow(title: "\(currency.vtfDisplayName) (\(currency.rawValue))",
                                       leading: currency.vtfSymbol,
                                       isSelected: currency == current)
            row.vtfOnTap = { [weak self] in
                VTFSettingsStore.shared.vtfCurrency = currency
                VTFHapticManager.shared.vtfSelection()
                self?.vtfRenderList()
            }
            listStack.addArrangedSubview(row)
        }
    }
}
