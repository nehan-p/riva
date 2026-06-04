import SwiftUI

struct PhotoCardBody: View {
    let post: PhotoPost
    
    var body: some View {
        MediaWell(
            isVideo: false,
            videoDuration: nil,
            overlayLabel: post.workoutLabel,
            overlayDuration: post.duration
        )
    }
}