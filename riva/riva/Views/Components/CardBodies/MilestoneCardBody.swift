import SwiftUI

struct MilestoneCardBody: View {
    let post: MilestonePost
    @Environment(\.rivaTheme) private var theme
    @Environment(\.rivaAccent) private var accent
    
    var body: some View {
        ZStack {
            // Ghost numeral
            Text("\(post.milestoneNumeral)")
                .font(.system(size: 150, weight: .black, design: .default))
                .foregroundColor(accent.color.opacity(0.12))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .offset(x: 20, y: -20)
                .clipped()
            
            VStack(alignment: .leading, spacing: 8) {
                // Milestone label
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 16))
                    Text("MILESTONE")
                        .font(.rivaPRBanner)
                }
                .foregroundColor(accent.color)
                
                // Headline
                Text("\(post.milestoneNumeral) \(post.milestoneLabel)")
                    .font(.rivaMilestoneHeadline)
                    .foregroundColor(theme.text)
                
                // Sub text
                Text(post.milestoneSub)
                    .font(.rivaMilestoneSub)
                    .foregroundColor(theme.sub)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
        }
        .frame(height: 200)
        .background(theme.raised)
        .cornerRadius(12)
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
    }
}

#Preview {
    MilestoneCardBody(post: .sample)
        .environment(\.rivaTheme, .ink)
        .environment(\.rivaAccent, .gold)
        .background(Color.riva.inkBg)
}