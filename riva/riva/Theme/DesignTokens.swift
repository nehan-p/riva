import SwiftUI

// MARK: - Riva Palette
extension Color {
    static let riva = RivaPalette()
}

struct RivaPalette {
    // Ink (dark) — default theme
    let inkBg = Color(hex: "#100F0C")
    let inkSurface = Color(hex: "#1A1916")
    let inkRaise = Color(hex: "#232118")
    let inkText = Color(hex: "#F4F1E8")
    let inkSub = Color(hex: "#A8A493")
    let inkMuted = Color(hex: "#6F6C5F")
    let inkLine = Color.white.opacity(0.10)
    let inkChip = Color.white.opacity(0.07)
    let inkHardShadow = Color.black.opacity(0.55)

    // Paper (light)
    let paperBg = Color(hex: "#E8E4D8")
    let paperSurface = Color(hex: "#F8F6F0")
    let paperRaise = Color.white
    let paperText = Color(hex: "#14130E")
    let paperSub = Color(hex: "#54513F")
    let paperMuted = Color(hex: "#8B8675")
    let paperLine = Color.black.opacity(0.12)
    let paperChip = Color.black.opacity(0.05)
    let paperHardShadow = Color.black.opacity(0.92)
    
    // Reaction fire active — always this color regardless of accent
    let fire = Color(hex: "#FF6A2B")
    
    // Accent — default gold
    let gold = Color(hex: "#FFC400")
    let voltOrange = Color(hex: "#FF5A1F")
    let crimson = Color(hex: "#FF3B30")
    let magenta = Color(hex: "#FF2E63")
    let hotPink = Color(hex: "#FF4DA6")
    let violet = Color(hex: "#8B5CF6")
    let indigo = Color(hex: "#4F5DFF")
    let cobalt = Color(hex: "#2F6BFF")
    let teal = Color(hex: "#19C9C0")
    let mint = Color(hex: "#2EE6A6")
    let acid = Color(hex: "#A8FF00")
    let chartreuse = Color(hex: "#C2F73D")
    
    // Avatar identity hues
    let avatarJM = Color(hex: "#E0497B")
    let avatarMR = Color(hex: "#F4622A")
    let avatarSK = Color(hex: "#7C5CF6")
    let avatarJT = Color(hex: "#15B886")
    let avatarAL = Color(hex: "#3B82F6")
    let avatarRP = Color(hex: "#E0A23B")
    let avatarMP = Color(hex: "#3B82F6")
}

// MARK: - Theme
enum RivaTheme: String, CaseIterable {
    case ink
    case paper
    
    var background: Color {
        switch self {
        case .ink: return Color.riva.inkBg
        case .paper: return Color.riva.paperBg
        }
    }
    
    var surface: Color {
        switch self {
        case .ink: return Color.riva.inkSurface
        case .paper: return Color.riva.paperSurface
        }
    }
    
    var raised: Color {
        switch self {
        case .ink: return Color.riva.inkRaise
        case .paper: return Color.riva.paperRaise
        }
    }
    
    var text: Color {
        switch self {
        case .ink: return Color.riva.inkText
        case .paper: return Color.riva.paperText
        }
    }
    
    var sub: Color {
        switch self {
        case .ink: return Color.riva.inkSub
        case .paper: return Color.riva.paperSub
        }
    }
    
    var muted: Color {
        switch self {
        case .ink: return Color.riva.inkMuted
        case .paper: return Color.riva.paperMuted
        }
    }
    
    var line: Color {
        switch self {
        case .ink: return Color.riva.inkLine
        case .paper: return Color.riva.paperLine
        }
    }
    
    var chip: Color {
        switch self {
        case .ink: return Color.riva.inkChip
        case .paper: return Color.riva.paperChip
        }
    }
    
    var hardShadow: Color {
        switch self {
        case .ink: return Color.riva.inkHardShadow
        case .paper: return Color.riva.paperHardShadow
        }
    }
}

// MARK: - Accent
enum RivaAccent: String, CaseIterable {
    case gold, voltOrange, crimson, magenta, hotPink, violet, indigo, cobalt, teal, mint, acid, chartreuse
    
    var color: Color {
        switch self {
        case .gold: return Color.riva.gold
        case .voltOrange: return Color.riva.voltOrange
        case .crimson: return Color.riva.crimson
        case .magenta: return Color.riva.magenta
        case .hotPink: return Color.riva.hotPink
        case .violet: return Color.riva.violet
        case .indigo: return Color.riva.indigo
        case .cobalt: return Color.riva.cobalt
        case .teal: return Color.riva.teal
        case .mint: return Color.riva.mint
        case .acid: return Color.riva.acid
        case .chartreuse: return Color.riva.chartreuse
        }
    }
    
    /// Returns dark text color if accent is bright, white if accent is dark
    var onAccentText: Color {
        relativeLuminance > 0.6 ? Color(hex: "#15140F") : .white
    }
    
    /// Compute relative luminance from hex
    private var relativeLuminance: Double {
        let hex = color.toHex ?? "#FFC400"
        let rgb = hex.hexToRGB()
        let r = sRGBComponent(rgb.r)
        let g = sRGBComponent(rgb.g)
        let b = sRGBComponent(rgb.b)
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }
    
    private func sRGBComponent(_ component: Double) -> Double {
        let c = component / 255.0
        return c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
    }
    
    var displayName: String {
        switch self {
        case .gold: return "Gold"
        case .voltOrange: return "Volt Orange"
        case .crimson: return "Crimson"
        case .magenta: return "Magenta"
        case .hotPink: return "Hot Pink"
        case .violet: return "Violet"
        case .indigo: return "Indigo"
        case .cobalt: return "Cobalt"
        case .teal: return "Teal"
        case .mint: return "Mint"
        case .acid: return "Acid"
        case .chartreuse: return "Chartreuse"
        }
    }
}

// MARK: - Tab
enum RivaTab: String, CaseIterable {
    case feed
    case find
    case logLift
    case activity
    case you
    
    var icon: String {
        switch self {
        case .feed: return "square.stack.3d.up.fill"
        case .find: return "magnifyingglass"
        case .logLift: return "dumbbell.fill"
        case .activity: return "bell.fill"
        case .you: return "person.crop.circle"
        }
    }
    
    var label: String {
        switch self {
        case .feed: return "Feed"
        case .find: return "Find"
        case .logLift: return ""
        case .activity: return "Activity"
        case .you: return "You"
        }
    }
    
    var shortLabel: String {
        switch self {
        case .feed: return "FEED"
        case .find: return "FIND"
        case .logLift: return "LOG"
        case .activity: return "ACTIVITY"
        case .you: return "YOU"
        }
    }
}

// MARK: - Environment
private struct RivaThemeKey: EnvironmentKey {
    static let defaultValue: RivaTheme = .ink
}
private struct RivaAccentKey: EnvironmentKey {
    static let defaultValue: RivaAccent = .gold
}

extension EnvironmentValues {
    var rivaTheme: RivaTheme {
        get { self[RivaThemeKey.self] }
        set { self[RivaThemeKey.self] = newValue }
    }
    var rivaAccent: RivaAccent {
        get { self[RivaAccentKey.self] }
        set { self[RivaAccentKey.self] = newValue }
    }
}

// MARK: - Color + Hex helpers
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        let scanner = Scanner(string: hex)
        var int: UInt64 = 0
        scanner.scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    var toHex: String? {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else { return nil }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
}

extension String {
    func hexToRGB() -> (r: Double, g: Double, b: Double) {
        var hex = self.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        if hex.count == 3 {
            hex = hex.map { "\($0)\($0)" }.joined()
        }
        guard let int = UInt64(hex, radix: 16) else { return (0, 0, 0) }
        return (
            r: Double((int >> 16) & 0xFF),
            g: Double((int >> 8) & 0xFF),
            b: Double(int & 0xFF)
        )
    }
}