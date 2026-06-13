//
//  Color+Hex.swift
//  Trackeame
//
//  Created by Francisco Garcia on 12/06/2026.
//

import SwiftUI

extension Color {

    // MARK: — Inicializador desde hex

    /// Crea un Color a partir de una cadena hexadecimal (#RRGGBB)
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }

    // MARK: — Conversión a hex

    /// Devuelve la representación hexadecimal del color (#RRGGBB)
    func toHex() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        #if os(iOS)
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: nil)
        #else
        NSColor(self).getRed(&r, green: &g, blue: &b, alpha: nil)
        #endif
        return String(format: "#%02X%02X%02X",
                      Int((r * 255).rounded()),
                      Int((g * 255).rounded()),
                      Int((b * 255).rounded()))
    }

    // MARK: — Colores predefinidos de la app

    /// Paleta de colores disponibles para los hábitos
    static let habitColors: [Color] = [
        .green, .blue, .orange, .red,
        .purple, .pink, .yellow, .teal,
        .mint, .cyan, .indigo, .brown
    ]

    /// Color por defecto para nuevos hábitos
    static let habitDefault = Color.green
}
