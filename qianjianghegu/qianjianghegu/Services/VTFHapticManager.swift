//
//  VTFHapticManager.swift
//  Vault Finance
//
//  Centralised haptic feedback, respecting the user's settings toggle.
//

import UIKit

/// Thin wrapper over UIFeedbackGenerator with a global on/off switch.
final class VTFHapticManager {

    static let shared = VTFHapticManager()

    private init() {}

    private var vtfEnabled: Bool { VTFSettingsStore.shared.vtfHapticsEnabled }

    func vtfImpact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        guard vtfEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    func vtfSelection() {
        guard vtfEnabled else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    func vtfNotify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard vtfEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}
