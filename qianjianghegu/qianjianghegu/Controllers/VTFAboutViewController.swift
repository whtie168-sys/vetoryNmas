//
//  VTFAboutViewController.swift
//  Vault Finance
//
//  Brand/about screen: app logo, tagline, feature highlights, and credits.
//

import UIKit

/// About screen with branding and feature list.
final class VTFAboutViewController: VTFBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "About"
        vtfApplyNavigationAppearance()
        vtfBuildLayout()
    }

    private func vtfBuildLayout() {
        vtfInstallScrollableContent()

        // Logo badge.
        let logo = VTFGradientView(colors: VTFTheme.primaryGradientColors, direction: .diagonal)
        logo.layer.cornerRadius = 24
        logo.layer.cornerCurve = .continuous
        logo.translatesAutoresizingMaskIntoConstraints = false
        let glyph = UIImageView(image: UIImage(systemName: "lock.shield.fill"))
        glyph.tintColor = .white
        glyph.contentMode = .scaleAspectFit
        glyph.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)
        glyph.translatesAutoresizingMaskIntoConstraints = false
        logo.addSubview(glyph)

        let name = UILabel()
        name.text = "Vault Finance"
        name.font = VTFTypography.largeTitle()
        name.textColor = VTFTheme.textPrimary
        name.textAlignment = .center

        let tagline = UILabel()
        tagline.text = "Private, offline money tracking."
        tagline.font = VTFTypography.body()
        tagline.textColor = VTFTheme.textSecondary
        tagline.textAlignment = .center

        let header = UIStackView(arrangedSubviews: [logo, name, tagline])
        header.axis = .vertical
        header.alignment = .center
        header.spacing = VTFTheme.Spacing.md
        vtfContentStack.addArrangedSubview(header)

        NSLayoutConstraint.activate([
            logo.widthAnchor.constraint(equalToConstant: 96),
            logo.heightAnchor.constraint(equalToConstant: 96),
            glyph.centerXAnchor.constraint(equalTo: logo.centerXAnchor),
            glyph.centerYAnchor.constraint(equalTo: logo.centerYAnchor)
        ])

        // Feature list.
        vtfContentStack.addArrangedSubview(vtfSpacer(VTFTheme.Spacing.sm))
        let featureCard = VTFCardView()
        featureCard.vtfAddArranged(vtfFeature(icon: "wifi.slash", title: "100% offline", detail: "No accounts, no servers, no tracking."))
        featureCard.vtfAddArranged(vtfFeature(icon: "chart.pie.fill", title: "Clear insights", detail: "See where your money goes at a glance."))
        featureCard.vtfAddArranged(vtfFeature(icon: "target", title: "Smart budgets", detail: "Set monthly limits and stay on track."))
        featureCard.vtfAddArranged(vtfFeature(icon: "lock.fill", title: "Yours alone", detail: "Everything stays on this device."))
        vtfContentStack.addArrangedSubview(featureCard)

        let credit = UILabel()
        credit.text = "Version \(VTFSettingsStore.shared.vtfAppVersion)\nMade with care for iPhone."
        credit.font = VTFTypography.caption()
        credit.textColor = VTFTheme.textTertiary
        credit.textAlignment = .center
        credit.numberOfLines = 0
        vtfContentStack.addArrangedSubview(credit)
    }

    private func vtfFeature(icon: String, title: String, detail: String) -> UIView {
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = VTFTheme.accent
        iconView.contentMode = .scaleAspectFit
        iconView.setContentHuggingPriority(.required, for: .horizontal)
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.widthAnchor.constraint(equalToConstant: 28).isActive = true

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = VTFTypography.headline()
        titleLabel.textColor = VTFTheme.textPrimary

        let detailLabel = UILabel()
        detailLabel.text = detail
        detailLabel.font = VTFTypography.caption()
        detailLabel.textColor = VTFTheme.textTertiary
        detailLabel.numberOfLines = 0

        let textStack = UIStackView(arrangedSubviews: [titleLabel, detailLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        let row = UIStackView(arrangedSubviews: [iconView, textStack])
        row.axis = .horizontal
        row.alignment = .top
        row.spacing = VTFTheme.Spacing.md
        return row
    }
}
