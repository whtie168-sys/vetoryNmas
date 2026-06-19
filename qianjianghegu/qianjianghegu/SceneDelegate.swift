//
//  SceneDelegate.swift
//  Vault Finance
//
//  Builds the UI programmatically (no storyboard) and seeds sample data on
//  first launch.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        // Seed a few sample transactions on the very first launch.
        VTFStorageManager.shared.vtfSeedSampleDataIfNeeded(referenceDate: Date())

        let window = UIWindow(windowScene: windowScene)
        window.overrideUserInterfaceStyle = .dark
        window.rootViewController = vtfMakeRoot()
        window.makeKeyAndVisible()
        self.window = window
    }

    /// Decide between onboarding and the main interface.
    private func vtfMakeRoot() -> UIViewController {
//        if VTFOnboardingViewController.vtfHasSeen {
//            return VTFRootTabBarController()
//        }
        let onboarding = VTFOnboardingViewController()
        onboarding.vtfOnFinish = { [weak self] in
            self?.vtfTransitionToMain()
        }
        return onboarding
    }

    /// Animate from onboarding to the main tab bar.
    private func vtfTransitionToMain() {
        guard let window = window else { return }
        let root = VTFRootTabBarController()
        UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve) {
            window.rootViewController = root
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
