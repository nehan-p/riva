import SwiftUI

// MARK: - Typography
// Riva uses Archivo for display and Inter for body.
// These fonts are referenced in Info.plist under UIAppFonts.
// If font files aren't bundled, SwiftUI custom fonts fall back to system fonts.
// In a production app, download Archivo and Inter from Google Fonts:
//   https://fonts.google.com/specimen/Archivo  (Black, ExtraBold, Bold, SemiBold)
//   https://fonts.google.com/specimen/Inter     (Regular, Medium, SemiBold)
// Place .ttf files in Resources/Fonts/ and add filenames to Info.plist UIAppFonts array.

// MARK: - Archivo (display fonts via system fallback)
extension Font {
    /// Archivo 900 weight approximation
    static func archivoBlack(_ size: CGFloat) -> Font {
        .system(size: size, weight: .black, design: .default)
    }
    
    /// Archivo 800 weight approximation
    static func archivoExtraBold(_ size: CGFloat) -> Font {
        .system(size: size, weight: .heavy, design: .default)
    }
    
    /// Archivo 700 weight approximation
    static func archivoBold(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .default)
    }
    
    /// Archivo 600 weight approximation
    static func archivoSemiBold(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .default)
    }
    
    /// Inter 600 weight approximation
    static func interSemiBold(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
    
    /// Inter 500 weight approximation
    static func interMedium(_ size: CGFloat) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }
    
    /// Inter 400/450 weight approximation
    static func interRegular(_ size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }
}

// MARK: - Design spec font extensions
extension Font {
    /// Wordmark "RIVA" — Archivo 900, 28pt
    static let rivaWordmark = Font.archivoBlack(28)
    
    /// Section label "TRAINING NOW" — Archivo 800, 11pt
    static let rivaSectionLabel = Font.archivoExtraBold(11)
    
    /// Post author name — Archivo 700, 14.5pt
    static let rivaPostAuthor = Font.archivoBold(14.5)
    
    /// Handle · time — Inter 400, 12.5pt
    static let rivaHandleTime = Font.interRegular(12.5)
    
    /// Tag pill — Archivo 700, 11pt
    static let rivaTagPill = Font.archivoBold(11)
    
    /// PR banner label — Archivo 800, 12pt
    static let rivaPRBanner = Font.archivoExtraBold(12)
    
    /// PR hero numeral — Archivo 900, 80pt (tabular)
    static let rivaPRHero = Font.archivoBlack(80).monospacedDigit()
    
    /// PR unit — Archivo 800, 18pt
    static let rivaPRUnit = Font.archivoExtraBold(18)
    
    /// PR scheme — Archivo 700, 13pt
    static let rivaPRScheme = Font.archivoBold(13)
    
    /// Progress chip previous — Archivo 600, 13pt
    static let rivaProgressPrev = Font.archivoSemiBold(13)
    
    /// Progress chip gain — Archivo 800, 13pt
    static let rivaProgressGain = Font.archivoExtraBold(13)
    
    /// Session title — Archivo 800, 23pt
    static let rivaSessionTitle = Font.archivoExtraBold(23)
    
    /// Session stat value — Archivo 800, 15pt (tabular)
    static let rivaStatValue = Font.archivoExtraBold(15).monospacedDigit()
    
    /// Session stat label — Archivo 600, 9.5pt
    static let rivaStatLabel = Font.archivoSemiBold(9.5)
    
    /// Exercise name — Inter 600, 13.5pt
    static let rivaExerciseName = Font.interSemiBold(13.5)
    
    /// Exercise scheme — Inter 400, 12pt
    static let rivaExerciseScheme = Font.interRegular(12)
    
    /// Exercise top set — Archivo 700, 14pt (tabular)
    static let rivaExerciseTopSet = Font.archivoBold(14).monospacedDigit()
    
    /// Caption — Inter 400, 14.5pt
    static let rivaCaption = Font.interRegular(14.5)
    
    /// Face-pile text — Inter 400, 12pt
    static let rivaFacePile = Font.interRegular(12)
    
    /// Reaction count — Archivo 700, 13.5pt (tabular)
    static let rivaReactionCount = Font.archivoBold(13.5).monospacedDigit()
    
    /// Milestone headline — Archivo 900, 58pt
    static let rivaMilestoneHeadline = Font.archivoBlack(58)
    
    /// Nav label — Archivo 700, 8.5pt
    static let rivaNavLabel = Font.archivoBold(8.5)
    
    /// Live label — Archivo 800, 9pt
    static let rivaLiveLabel = Font.archivoExtraBold(9)
    
    /// Milestone sub — Inter 500, 14pt
    static let rivaMilestoneSub = Font.interMedium(14)
}