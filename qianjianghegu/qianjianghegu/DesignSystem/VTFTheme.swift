//
//  VTFTheme.swift
//  Vault Finance
//
//  Centralised colour palette, gradients and spacing tokens for a premium,
//  minimal fintech look (dark #0F1115 base, blue gradient accent).
//

import UIKit

/// Design tokens: colours, gradients, spacing, radii.
enum VTFTheme {

    // MARK: - Core palette

    /// App background — deep near-black (#0F1115).
    static let background = UIColor(red: 0.059, green: 0.067, blue: 0.082, alpha: 1)

    /// Elevated surface / card background.
    static let surface = UIColor(red: 0.105, green: 0.117, blue: 0.137, alpha: 1)

    /// Higher elevation surface (sheets, pickers).
    static let surfaceElevated = UIColor(red: 0.137, green: 0.152, blue: 0.176, alpha: 1)

    /// Hairline separators / strokes.
    static let stroke = UIColor(white: 1.0, alpha: 0.08)

    // MARK: - Text

    static let textPrimary = UIColor(white: 0.97, alpha: 1)
    static let textSecondary = UIColor(white: 0.97, alpha: 0.6)
    static let textTertiary = UIColor(white: 0.97, alpha: 0.38)

    // MARK: - Semantic

    /// Primary blue accent.
    static let accent = UIColor(red: 0.30, green: 0.52, blue: 0.98, alpha: 1)
    static let accentSecondary = UIColor(red: 0.45, green: 0.36, blue: 0.98, alpha: 1)

    /// Income green.
    static let income = UIColor(red: 0.24, green: 0.82, blue: 0.52, alpha: 1)
    /// Expense red.
    static let expense = UIColor(red: 0.98, green: 0.36, blue: 0.42, alpha: 1)
    static let warning = UIColor(red: 0.98, green: 0.74, blue: 0.30, alpha: 1)

    // MARK: - Gradients

    /// Primary blue→violet gradient colours (for hero balance card, buttons).
    static var primaryGradientColors: [CGColor] {
        return [
            UIColor(red: 0.27, green: 0.50, blue: 0.99, alpha: 1).cgColor,
            UIColor(red: 0.49, green: 0.36, blue: 0.99, alpha: 1).cgColor
        ]
    }

    static var incomeGradientColors: [CGColor] {
        return [
            UIColor(red: 0.20, green: 0.80, blue: 0.55, alpha: 1).cgColor,
            UIColor(red: 0.16, green: 0.66, blue: 0.66, alpha: 1).cgColor
        ]
    }

    static var expenseGradientColors: [CGColor] {
        return [
            UIColor(red: 0.98, green: 0.42, blue: 0.45, alpha: 1).cgColor,
            UIColor(red: 0.96, green: 0.30, blue: 0.55, alpha: 1).cgColor
        ]
    }

    // MARK: - Layout tokens

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    enum Radius {
        static let small: CGFloat = 12
        static let medium: CGFloat = 18
        static let large: CGFloat = 28
        static let pill: CGFloat = 999
    }

    /// Colour for a transaction type.
    static func color(for type: VTFTransactionType) -> UIColor {
        return type == .income ? income : expense
    }

    /// Apply a soft elevation shadow to a layer.
    static func applySoftShadow(to view: UIView, opacity: Float = 0.35, radius: CGFloat = 18, yOffset: CGFloat = 10) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = opacity
        view.layer.shadowRadius = radius
        view.layer.shadowOffset = CGSize(width: 0, height: yOffset)
        view.layer.masksToBounds = false
    }
}
