import SwiftUI

struct PRCardBody: View {
    let post: PRPost
    @Environment(\.rivaTheme) private var theme
    @Environment(\.rivaAccent) private var accent
    
    var body: some View {
        VStack(spacing: 14) {
            // PR Banner
            HStack(spacing: 8) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 12))
                Text("NEW PERSONAL RECORD")
                    .font(.rivaPRBanner)
                Image(systemName: "bolt.fill")
                    .font(.system(size: 12))
            }
            .foregroundColor(accent.onAccentText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(accent.color)
            .cornerRadius(9)
            .padding(.horizontal, 14)
            
            // Hero
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(post.liftName)
                        .font(.rivaPRScheme)
                        .foregroundColor(theme.sub)
                        .textCase(.uppercase)
                    
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text("\(post.weight)")
                            .font(.rivaPRHero)
                            .foregroundColor(theme.text)
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text(post.unit)
                                .font(.rivaPRUnit)
                                .foregroundColor(theme.sub)
                            Text(post.scheme)
                                .font(.rivaPRScheme)
                                .foregroundColor(theme.muted)
                        }
                        .offset(y: -4)
                    }
                }
                
                Spacer()
                
                // Progress chip
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(post.previousWeight) \(post.unit)")
                        .font(.rivaProgressPrev)
                        .foregroundColor(theme.muted)
                        .strikethrough()
                    Text("+\(post.gain) \(post.unit)")
                        .font(.rivaProgressGain)
                        .foregroundColor(accent.color)
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 14)
            
            // Support lifts
            if !post.supportLifts.isEmpty {
                VStack(spacing: 0) {
                    ForEach(post.supportLifts) { exercise in
                        HStack {
                            Circle()
                                .fill(theme.muted.opacity(0.4))
                                .frame(width: 4, height: 4)
                            
                            Text(exercise.name)
                                .font(.rivaExerciseName)
                                .foregroundColor(theme.text)
                            
                            Spacer()
                            
                            Text(exercise.displayScheme)
                                .font(.rivaExerciseScheme)
                                .foregroundColor(theme.muted)
                            
                            Text(exercise.displayWeight)
                                .font(.rivaExerciseTopSet)
                                .foregroundColor(theme.text)
                                .frame(width: 70, alignment: .trailing)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        
                        if exercise.id != post.supportLifts.last?.id {
                            Divider()
                                .background(theme.line)
                                .padding(.horizontal, 14)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 12)
    }
}

#Preview {
    PRCardBody(post: .sample)
        .environment(\.rivaTheme, .ink)
        .environment(\.rivaAccent, .gold)
        .background(Color.riva.inkBg)
}