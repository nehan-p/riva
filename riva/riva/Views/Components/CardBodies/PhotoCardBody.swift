import SwiftUI

struct PhotoCardBody: View {
    let post: PhotoPost
    
    var body: some View {
        MediaWell(
            isVideo: false,
            overlayLabel: post.workoutLabel,
            overlayDuration: post.duration,
            imageUrl: post.imageUrl
        )
    }
}