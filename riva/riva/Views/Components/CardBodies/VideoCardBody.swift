import SwiftUI

struct VideoCardBody: View {
    let post: VideoPost
    
    var body: some View {
        MediaWell(
            isVideo: true,
            videoDuration: post.videoLength,
            overlayLabel: post.workoutLabel,
            overlayDuration: post.duration
        )
    }
}