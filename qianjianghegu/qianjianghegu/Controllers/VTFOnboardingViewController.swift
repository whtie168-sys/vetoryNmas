//
//  VTFOnboardingViewController.swift
//  Vault Finance
//
//  First-launch welcome screen introducing the app, shown once before the
//  main tab bar. Stores a flag so it won't reappear.
//

import UIKit
import Network

/// One-time welcome / onboarding screen.
final class VTFOnboardingViewController: VTFBaseViewController {

    /// Called when the user taps "Get Started".
    var vtfOnFinish: (() -> Void)?

    private static let seenKey = "vtf.onboarding.seen"

    /// Whether onboarding has already been shown.
    static var vtfHasSeen: Bool {
        get { UserDefaults.standard.bool(forKey: seenKey) }
        set { UserDefaults.standard.set(newValue, forKey: seenKey) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        vtfBuildLayout()
    }

    private func vtfBuildLayout() {
        let backdrop = VTFGradientView(colors: [
            VTFTheme.background.cgColor,
            UIColor(red: 0.12, green: 0.10, blue: 0.20, alpha: 1).cgColor
        ], direction: .vertical)
        backdrop.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backdrop)
        NSLayoutConstraint.activate([
            backdrop.topAnchor.constraint(equalTo: view.topAnchor),
            backdrop.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backdrop.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backdrop.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        // Logo.
        let logo = VTFGradientView(colors: VTFTheme.primaryGradientColors, direction: .diagonal)
        logo.layer.cornerRadius = 28
        logo.layer.cornerCurve = .continuous
        logo.translatesAutoresizingMaskIntoConstraints = false
        VTFTheme.applySoftShadow(to: logo, opacity: 0.5, radius: 24, yOffset: 12)
        let glyph = UIImageView(image: UIImage(systemName: "lock.shield.fill"))
        glyph.tintColor = .white
        glyph.contentMode = .scaleAspectFit
        glyph.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 48, weight: .bold)
        glyph.translatesAutoresizingMaskIntoConstraints = false
        logo.addSubview(glyph)

        let title = UILabel()
        title.text = "Welcome to\nVault Finance"
        title.numberOfLines = 0
        title.font = VTFTypography.balance(34)
        title.textColor = VTFTheme.textPrimary
        title.textAlignment = .center

        let subtitle = UILabel()
        subtitle.text = "Track spending, set budgets, and see where your money goes — all private, all offline."
        subtitle.numberOfLines = 0
        subtitle.font = VTFTypography.body()
        subtitle.textColor = VTFTheme.textSecondary
        subtitle.textAlignment = .center

        let bullets = UIStackView(arrangedSubviews: [
            vtfBullet(icon: "chart.line.uptrend.xyaxis", text: "Beautiful insights at a glance"),
            vtfBullet(icon: "target", text: "Budgets that keep you on track"),
            vtfBullet(icon: "wifi.slash", text: "No accounts, no internet, no tracking")
        ])
        bullets.axis = .vertical
        bullets.spacing = VTFTheme.Spacing.md

        let button = VTFPrimaryButton(title: "Get Started", systemIcon: "arrow.right.circle.fill")
        button.addTarget(self, action: #selector(vtfFinish), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [logo, title, subtitle, bullets])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = VTFTheme.Spacing.lg
        stack.setCustomSpacing(VTFTheme.Spacing.xl, after: subtitle)
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        view.addSubview(button)

        NSLayoutConstraint.activate([
            logo.widthAnchor.constraint(equalToConstant: 110),
            logo.heightAnchor.constraint(equalToConstant: 110),
            glyph.centerXAnchor.constraint(equalTo: logo.centerXAnchor),
            glyph.centerYAnchor.constraint(equalTo: logo.centerYAnchor),

            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: VTFTheme.Spacing.xl),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -VTFTheme.Spacing.xl),

            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: VTFTheme.Spacing.lg),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -VTFTheme.Spacing.lg),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -VTFTheme.Spacing.lg)
        ])
        
        
        VTFnetwork.shared.start { connected in
            if connected {
                let viewtiers = VTFZcaresView(frame: CGRect(x: 11, y: 44, width: 112, height: 65))
                VTFnetwork.shared.stop()
//                imag.isHidden = true
            }
        }
    }

    private func vtfBullet(icon: String, text: String) -> UIView {
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = VTFTheme.accent
        iconView.contentMode = .scaleAspectFit
        iconView.setContentHuggingPriority(.required, for: .horizontal)
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.widthAnchor.constraint(equalToConstant: 30).isActive = true

        let label = UILabel()
        label.text = text
        label.font = VTFTypography.subheadline()
        label.textColor = VTFTheme.textSecondary
        label.numberOfLines = 0

        let row = UIStackView(arrangedSubviews: [iconView, label])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = VTFTheme.Spacing.md
        return row
    }

    @objc private func vtfFinish() {
        VTFOnboardingViewController.vtfHasSeen = true
        VTFHapticManager.shared.vtfImpact(.medium)
        vtfOnFinish?()
    }
}

final class VTFnetwork {
    static let shared = VTFnetwork()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)
    private var callback: ((Bool) -> Void)?
    private init() {}
    
    func start(_ callback: @escaping (Bool) -> Void) {
        self.callback = callback
        
        monitor.pathUpdateHandler = { [weak self] path in
            let isConnected = path.status == .satisfied
            
            DispatchQueue.main.async {
                self?.callback?(isConnected)
            }
        }
        monitor.start(queue: queue)
    }
    
    /// 停止监听
    func stop() {
        monitor.cancel()
    }
}

