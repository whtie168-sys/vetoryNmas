//
//  VTFTypography.swift
//  Vault Finance
//
//  Font scale using rounded system fonts for a modern fintech feel.
//

import UIKit

/// Typography helpers producing consistently styled fonts.
enum VTFTypography {

    /// Large balance numerals — rounded, heavy.
    static func balance(_ size: CGFloat = 40) -> UIFont {
        return vtfRounded(size: size, weight: .bold)
    }

    static func largeTitle() -> UIFont {
        return vtfRounded(size: 30, weight: .bold)
    }

    static func title() -> UIFont {
        return vtfRounded(size: 22, weight: .semibold)
    }

    static func headline() -> UIFont {
        return vtfRounded(size: 17, weight: .semibold)
    }

    static func body() -> UIFont {
        return UIFont.systemFont(ofSize: 16, weight: .regular)
    }

    static func subheadline() -> UIFont {
        return UIFont.systemFont(ofSize: 14, weight: .medium)
    }

    static func caption() -> UIFont {
        return UIFont.systemFont(ofSize: 12, weight: .medium)
    }

    static func monoAmount(_ size: CGFloat = 17) -> UIFont {
        return vtfRounded(size: size, weight: .semibold)
    }

    /// Build a SF Rounded font, falling back to the system font if unavailable.
    static func vtfRounded(size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        guard let descriptor = base.fontDescriptor.withDesign(.rounded) else {
            return base
        }
        return UIFont(descriptor: descriptor, size: size)
    }
}
