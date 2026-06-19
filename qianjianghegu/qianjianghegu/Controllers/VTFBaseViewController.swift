//
//  VTFBaseViewController.swift
//  Vault Finance
//
//  Shared base for all screens: dark background, large title styling, and a
//  helper to embed a scrollable content stack.
//

import UIKit

/// Base controller applying the app's visual identity to every screen.
class VTFBaseViewController: UIViewController {

    /// Vertical scroll container available to subclasses.
    let vtfScrollView = UIScrollView()
    /// Main vertical stack inside the scroll view.
    let vtfContentStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = VTFTheme.background
        vtfApplyNavigationAppearance()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    /// Apply the dark, large-title navigation bar appearance.
    func vtfApplyNavigationAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = VTFTheme.background
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [
            .foregroundColor: VTFTheme.textPrimary,
            .font: VTFTypography.headline()
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: VTFTheme.textPrimary,
            .font: VTFTypography.largeTitle()
        ]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = VTFTheme.accent
    }

    /// Install a vertical scroll view + content stack pinned to safe area.
    /// Subclasses add arranged subviews to `vtfContentStack`.
    func vtfInstallScrollableContent(horizontalInset: CGFloat = VTFTheme.Spacing.md) {
        vtfScrollView.translatesAutoresizingMaskIntoConstraints = false
        vtfScrollView.showsVerticalScrollIndicator = false
        vtfScrollView.alwaysBounceVertical = true
        vtfScrollView.contentInsetAdjustmentBehavior = .always
        view.addSubview(vtfScrollView)

        vtfContentStack.axis = .vertical
        vtfContentStack.spacing = VTFTheme.Spacing.lg
        vtfContentStack.translatesAutoresizingMaskIntoConstraints = false
        vtfScrollView.addSubview(vtfContentStack)

        NSLayoutConstraint.activate([
            vtfScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            vtfScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            vtfScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            vtfScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            vtfContentStack.topAnchor.constraint(equalTo: vtfScrollView.contentLayoutGuide.topAnchor, constant: VTFTheme.Spacing.md),
            vtfContentStack.bottomAnchor.constraint(equalTo: vtfScrollView.contentLayoutGuide.bottomAnchor, constant: -VTFTheme.Spacing.xl),
            vtfContentStack.leadingAnchor.constraint(equalTo: vtfScrollView.frameLayoutGuide.leadingAnchor, constant: horizontalInset),
            vtfContentStack.trailingAnchor.constraint(equalTo: vtfScrollView.frameLayoutGuide.trailingAnchor, constant: -horizontalInset)
        ])
    }

    /// Convenience: a labelled spacer view of a fixed height.
    func vtfSpacer(_ height: CGFloat) -> UIView {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.heightAnchor.constraint(equalToConstant: height).isActive = true
        return spacer
    }
}
