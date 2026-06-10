import SwiftUI
import PhotosUI

// MARK: - Media Well (Photo/Video placeholder)
struct MediaWell: View {
    let height: CGFloat
    let isVideo: Bool
    let videoDuration: String?
    let overlayLabel: String?
    let overlayDuration: String?
    let imageUrl: String?
    let videoUrl: String?
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: Image?
    @Environment(\.rivaTheme) private var theme
    
    init(
        height: CGFloat = 300,
        isVideo: Bool,
        videoDuration: String? = nil,
        overlayLabel: String? = nil,
        overlayDuration: String? = nil,
        imageUrl: String? = nil,
        videoUrl: String? = nil
    ) {
        self.height = height
        self.isVideo = isVideo
        self.videoDuration = videoDuration
        self.overlayLabel = overlayLabel
        self.overlayDuration = overlayDuration
        self.imageUrl = imageUrl
        self.videoUrl = videoUrl
    }
    
    var body: some View {
        ZStack {
            // Background
            Rectangle()
                .fill(theme.raised)
                .frame(height: height)
            
            if let selectedImage = selectedImage {
                // Local picked image
                selectedImage
                    .resizable()
                    .scaledToFill()
                    .frame(height: height)
                    .clipped()
            } else if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
                // Remote image from URL
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: height)
                            .clipped()
                    case .failure:
                        mediaPlaceholder
                    case .empty:
                        ProgressView()
                            .frame(height: height)
                    @unknown default:
                        mediaPlaceholder
                    }
                }
            } else {
                mediaPlaceholder
            }
            
            // Video play button overlay
            if isVideo {
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.5))
                        .frame(width: 58, height: 58)
                    
                    Circle()
                        .stroke(Color.white, lineWidth: 1.5)
                        .frame(width: 58, height: 58)
                    
                    Image(systemName: "play.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .offset(x: 2)
                }
            }
            
            // Duration badge (video)
            if let duration = videoDuration, isVideo {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(duration)
                            .font(.rivaTagPill)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.62))
                            .cornerRadius(6)
                            .padding(.trailing, 10)
                            .padding(.bottom, 10)
                    }
                }
            }
            
            // Workout overlay chip (bottom-left)
            if let label = overlayLabel, let duration = overlayDuration {
                VStack {
                    Spacer()
                    HStack {
                        HStack(spacing: 5) {
                            Image(systemName: "dumbbell.fill")
                                .font(.system(size: 10))
                            Text("\(label) · \(duration)")
                                .font(.rivaTagPill)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(hex: "#080806").opacity(0.78))
                        .cornerRadius(7)
                        
                        Spacer()
                    }
                    .padding(.leading, 10)
                    .padding(.bottom, 10)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .clipped()
        .photosPicker(isPresented: .constant(selectedItem != nil), selection: $selectedItem, matching: isVideo ? .videos : .images)
        .onChange(of: selectedItem) { _, newItem in
            guard let item = newItem else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImage = Image(uiImage: uiImage)
                }
            }
        }
        .onTapGesture {
            selectedItem = nil // Reset to trigger picker
            // In production, use PhotosPicker via .photosPicker(isPresented:) with a proper @State
        }
    }
    
    private var mediaPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: isVideo ? "video.fill" : "photo.fill")
                .font(.system(size: 32))
                .foregroundColor(theme.muted.opacity(0.5))
            
            Text(isVideo ? "DROP A GYM VIDEO" : "DROP A GYM PHOTO")
                .font(.rivaSectionLabel)
                .foregroundColor(theme.muted.opacity(0.5))
            
            Text("or tap to browse")
                .font(.rivaFacePile)
                .foregroundColor(theme.muted.opacity(0.3))
        }
    }
}
