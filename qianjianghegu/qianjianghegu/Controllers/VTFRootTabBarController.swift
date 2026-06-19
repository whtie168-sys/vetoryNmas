//
//  VTFRootTabBarController.swift
//  Vault Finance
//
//  Custom-styled tab bar hosting the five primary navigation stacks. The spec
//  permits a tab bar when used to deliberately improve the UI.
//

import UIKit

/// The app's root container: a styled tab bar with four navigation stacks.
final class VTFRootTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        vtfConfigureTabs()
        vtfApplyTabBarAppearance()
        delegate = self
    }

    private func vtfConfigureTabs() {
        let dashboard = vtfWrap(VTFDashboardViewController(),
                                title: "Home",
                                icon: "house.fill")
        let transactions = vtfWrap(VTFTransactionsViewController(),
                                   title: "Activity",
                                   icon: "list.bullet.rectangle.fill")
        let statistics = vtfWrap(VTFStatisticsViewController(),
                                 title: "Insights",
                                 icon: "chart.pie.fill")
        let budgets = vtfWrap(VTFBudgetViewController(),
                              title: "Budgets",
                              icon: "target")
        let settings = vtfWrap(VTFSettingsViewController(),
                               title: "Settings",
                               icon: "gearshape.fill")

        viewControllers = [dashboard, transactions, statistics, budgets, settings]
    }

    /// Wrap a controller in a navigation controller with a tab bar item.
    private func vtfWrap(_ controller: UIViewController, title: String, icon: String) -> UINavigationController {
        controller.title = title
        let nav = UINavigationController(rootViewController: controller)
        nav.navigationBar.prefersLargeTitles = true
        nav.tabBarItem = UITabBarItem(title: title,
                                      image: UIImage(systemName: icon),
                                      selectedImage: UIImage(systemName: icon))
        return nav
    }

    private func vtfApplyTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = VTFTheme.surface
        appearance.shadowColor = VTFTheme.stroke

        let normal = appearance.stackedLayoutAppearance.normal
        normal.iconColor = VTFTheme.textTertiary
        normal.titleTextAttributes = [
            .foregroundColor: VTFTheme.textTertiary,
            .font: VTFTypography.caption()
        ]

        let selected = appearance.stackedLayoutAppearance.selected
        selected.iconColor = VTFTheme.accent
        selected.titleTextAttributes = [
            .foregroundColor: VTFTheme.accent,
            .font: VTFTypography.caption()
        ]

        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        } else {
            // Fallback on earlier versions
        }
        tabBar.tintColor = VTFTheme.accent
    }
}

extension VTFRootTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        VTFHapticManager.shared.vtfSelection()
    }
}
