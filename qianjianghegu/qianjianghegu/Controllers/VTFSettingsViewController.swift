//
//  VTFSettingsViewController.swift
//  Vault Finance
//
//  Settings tab: currency entry, haptics toggle, monthly report, about,
//  version, and a destructive "clear all data" action.
//

import UIKit

/// Settings tab.
final class VTFSettingsViewController: VTFBaseViewController {

    private let hapticsRow = VTFToggleRow(title: "Haptic feedback", icon: "hand.tap.fill")
    private let reminderRow = VTFToggleRow(title: "Monthly summary reminder", icon: "bell.fill")
    private let currencyRow = VTFFormRow(title: "Currency", icon: "coloncurrencysign.circle.fill")
    private let reportRow = VTFFormRow(title: "Monthly report", icon: "doc.text.fill")
    private let aboutRow = VTFFormRow(title: "About Vault Finance", icon: "info.circle.fill")
    private let versionRow = VTFFormRow(title: "Version", icon: "number.circle.fill")

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        navigationItem.largeTitleDisplayMode = .always
        vtfBuildLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        vtfRefreshValues()
    }

    private func vtfBuildLayout() {
        vtfInstallScrollableContent()

        // Preferences section.
        vtfContentStack.addArrangedSubview(vtfSectionLabel("Preferences"))

        currencyRow.vtfOnTap = { [weak self] in self?.vtfOpenCurrency() }
        vtfContentStack.addArrangedSubview(currencyRow)

        hapticsRow.vtfOnToggle = { isOn in
            VTFSettingsStore.shared.vtfHapticsEnabled = isOn
            if isOn { VTFHapticManager.shared.vtfImpact(.light) }
        }
        vtfContentStack.addArrangedSubview(hapticsRow)

        reminderRow.vtfOnToggle = { isOn in
            VTFSettingsStore.shared.vtfMonthlyReminderEnabled = isOn
        }
        vtfContentStack.addArrangedSubview(reminderRow)

        // Reports section.
        vtfContentStack.addArrangedSubview(vtfSectionLabel("Reports"))
        reportRow.vtfOnTap = { [weak self] in
            let report = VTFMonthlyReportViewController()
            self?.navigationController?.pushViewController(report, animated: true)
        }
        vtfContentStack.addArrangedSubview(reportRow)

        // About section.
        vtfContentStack.addArrangedSubview(vtfSectionLabel("About"))
        aboutRow.vtfOnTap = { [weak self] in
            self?.navigationController?.pushViewController(VTFAboutViewController(), animated: true)
        }
        vtfContentStack.addArrangedSubview(aboutRow)
        versionRow.isUserInteractionEnabled = false
        vtfContentStack.addArrangedSubview(versionRow)

        // Danger zone.
        vtfContentStack.addArrangedSubview(vtfSectionLabel("Data"))
        let clearButton = VTFPrimaryButton(title: "Clear All Data", systemIcon: "trash.fill")
        clearButton.addTarget(self, action: #selector(vtfClearData), for: .touchUpInside)
        vtfContentStack.addArrangedSubview(clearButton)

        let disclaimer = UILabel()
        disclaimer.text = "All data is stored only on this device. Vault Finance never connects to the internet."
        disclaimer.font = VTFTypography.caption()
        disclaimer.textColor = VTFTheme.textTertiary
        disclaimer.numberOfLines = 0
        disclaimer.textAlignment = .center
        vtfContentStack.addArrangedSubview(disclaimer)
    }

    private func vtfSectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text.uppercased()
        label.font = VTFTypography.caption()
        label.textColor = VTFTheme.textTertiary
        return label
    }

    private func vtfRefreshValues() {
        currencyRow.vtfSetValue("\(VTFSettingsStore.shared.vtfCurrency.vtfSymbol) \(VTFSettingsStore.shared.vtfCurrency.rawValue)",
                                valueColor: VTFTheme.textSecondary)
        versionRow.vtfSetValue(VTFSettingsStore.shared.vtfAppVersion, valueColor: VTFTheme.textSecondary)
        hapticsRow.vtfSetOn(VTFSettingsStore.shared.vtfHapticsEnabled)
        reminderRow.vtfSetOn(VTFSettingsStore.shared.vtfMonthlyReminderEnabled)
    }

    private func vtfOpenCurrency() {
        let picker = VTFCurrencyPickerViewController()
        navigationController?.pushViewController(picker, animated: true)
    }

    @objc private func vtfClearData() {
        let alert = UIAlertController(title: "Clear all data?",
                                      message: "This permanently deletes every transaction and budget on this device. This can't be undone.",
                                      preferredStyle: .alert)
        alert.overrideUserInterfaceStyle = .dark
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete Everything", style: .destructive) { _ in
            VTFStorageManager.shared.vtfClearAll()
            VTFHapticManager.shared.vtfNotify(.warning)
        })
        present(alert, animated: true)
    }
}
