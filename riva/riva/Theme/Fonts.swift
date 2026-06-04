import SwiftUI

// MARK: - Typography
// Archivo (display) and Inter (body) from Google Fonts, bundled in Resources/Fonts/.
// Registered via UIAppFonts in Info.plist (project.yml info.properties).

// MARK: - Archivo (display fonts)

extension Font {
    /// Archivo Black — weight 900
    static func archivoBlack(_ size: CGFloat) -> Font {
        .custom("Archivo-Black", size: size)
    }
    
    /// Archivo ExtraBold — weight 800
    static func archivoExtraBold(_ size: CGFloat) -> Font {
        .custom("Archivo-ExtraBold", size: size)
    }
    
    /// Archivo Bold — weight 700
    static func archivoBold(_ size: CGFloat) -> Font {
        .custom("Archivo-Bold", size: size)
    }
    
    /// Archivo SemiBold — weight 600
    static func archivoSemiBold(_ size: CGFloat) -> Font {
        .custom("Archivo-SemiBold", size: size)
    }
}

// MARK: - Inter (body fonts)

extension Font {
    /// Inter SemiBold — weight 600
    static func interSemiBold(_ size: CGFloat) -> Font {
        .custom("Inter-SemiBold", size: size)
    }
    
    /// Inter Medium — weight 500
    static func interMedium(_ size: CGFloat) -> Font {
        .custom("Inter-Medium", size: size)
    }
    
    /// Inter Regular — weight 400
    static func interRegular(_ size: CGFloat) -> Font {
        .custom("Inter-Regular", size: size)
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