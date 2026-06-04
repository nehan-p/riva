import SwiftUI

struct SessionCardBody: View {
    let post: SessionPost
    @Environment(\.rivaTheme) private var theme
    @Environment(\.rivaAccent) private var accent
    
    var body: some View {
        VStack(spacing: 12) {
            // Title
            Text(post.title)
                .font(.rivaSessionTitle)
                .foregroundColor(theme.text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 14)
            
            // Stat ribbon
            HStack(spacing: 24) {
                StatItem(value: post.stats.duration, label: "TIME")
                StatItem(value: post.stats.volume, label: "VOLUME")
                StatItem(value: "\(post.stats.sets)", label: "SETS")
            }
            .padding(.horizontal, 14)
            
            // Exercise list
            VStack(spacing: 0) {
                ForEach(Array(post.exercises.enumerated()), id: \.offset) { index, exercise in
                    HStack(spacing: 10) {
                        Text("\(index + 1)")
                            .font(.rivaExerciseScheme)
                            .foregroundColor(theme.muted)
                            .frame(width: 18, alignment: .leading)
                        
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
                    .padding(.vertical, 7)
                    
                    if index < post.exercises.count - 1 {
                        Divider()
                            .background(theme.line)
                            .padding(.horizontal, 14)
                    }
                }
            }
        }
        .padding(.vertical, 10)
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let value: String
    let label: String
    @Environment(\.rivaTheme) private var theme
    
    var body: some View {
        VStack(spacing: 0) {
            Text(value)
                .font(.rivaStatValue)
                .foregroundColor(theme.text)
            Text(label)
                .font(.rivaStatLabel)
                .foregroundColor(theme.muted)
        }
    }
}

#Preview {
    SessionCardBody(post: .sample)
        .environment(\.rivaTheme, .ink)
        .background(Color.riva.inkBg)
}