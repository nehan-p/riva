import SwiftUI
import PhotosUI
import AVKit

// MARK: - Media Attachment View
struct MediaAttachmentView: View {
    @Binding var selectedImage: UIImage?
    @Binding var selectedVideoURL: URL?

    @State private var showActionSheet = false
    @State private var showCamera = false
    @State private var showPhotoPicker = false
    @State private var videoThumbnail: UIImage? = nil

    @Environment(\.rivaTheme) private var theme

    private var thumbnail: UIImage? {
        if let image = selectedImage { return image }
        return videoThumbnail
    }

    var body: some View {
        Button { showActionSheet = true } label: {
            if let thumb = thumbnail {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: thumb)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .cornerRadius(12)

                    if selectedVideoURL != nil {
                        ZStack {
                            Circle().fill(theme.raised.opacity(0.85)).frame(width: 36, height: 36)
                            Image(systemName: "play.fill").font(.system(size: 16)).foregroundColor(theme.text)
                        }
                        .padding(8)
                    }

                    Button { removeMedia() } label: {
                        ZStack {
                            Circle().fill(theme.raised).frame(width: 28, height: 28)
                            Image(systemName: "xmark").font(.system(size: 12, weight: .bold)).foregroundColor(theme.text)
                        }
                        .rivaShadow(color: theme.hardShadow, x: 4, y: 4)
                    }
                    .padding(8)
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "camera.fill").font(.system(size: 28)).foregroundColor(theme.muted)
                    Text("Add Photo or Video").font(.interMedium(14)).foregroundColor(theme.sub)
                    Text("Tap to attach media").font(.interRegular(12)).foregroundColor(theme.muted)
                }
                .frame(height: 100)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.surface)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(theme.line, lineWidth: 1))
                )
            }
        }
        .confirmationDialog("Add Media", isPresented: $showActionSheet, titleVisibility: .visible) {
            Button("Take Photo") { showCamera = true }
            Button("Choose from Library") { showPhotoPicker = true }
            Button("Cancel", role: .cancel) {}
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraPicker(selectedImage: $selectedImage, selectedVideoURL: $selectedVideoURL).ignoresSafeArea()
        }
        .sheet(isPresented: $showPhotoPicker) {
            PhotoLibraryPicker(selectedImage: $selectedImage, selectedVideoURL: $selectedVideoURL)
        }
        .onChange(of: selectedVideoURL) { _, newURL in
            videoThumbnail = nil
            if let url = newURL {
                Task { await generateVideoThumbnail(from: url) }
            }
        }
    }

    private func removeMedia() {
        selectedImage = nil
        selectedVideoURL = nil
        videoThumbnail = nil
    }

    private func generateVideoThumbnail(from url: URL) async {
        let result: UIImage? = await Task.detached(priority: .userInitiated) {
            let asset = AVAsset(url: url)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            do {
                let cgImage = try generator.copyCGImage(at: .zero, actualTime: nil)
                return UIImage(cgImage: cgImage)
            } catch { return nil }
        }.value
        await MainActor.run {
            if selectedVideoURL == url {
                videoThumbnail = result
            }
        }
    }
}

// MARK: - Camera Picker
struct CameraPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var selectedVideoURL: URL?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = ["public.image", "public.movie"]
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        init(parent: CameraPicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
                parent.selectedVideoURL = nil
            } else if let videoURL = info[.mediaURL] as? URL {
                parent.selectedVideoURL = videoURL
                parent.selectedImage = nil
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { parent.dismiss() }
    }
}

// MARK: - Photo Library Picker
struct PhotoLibraryPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var selectedVideoURL: URL?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .any(of: [.images, .videos])
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoLibraryPicker
        init(parent: PhotoLibraryPicker) { self.parent = parent }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard let result = results.first else { parent.dismiss(); return }
            let provider = result.itemProvider

            if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                provider.loadObject(ofClass: UIImage.self) { reading, _ in
                    let image = reading as? UIImage
                    Task { @MainActor in
                        if let image = image {
                            self.parent.selectedImage = image
                            self.parent.selectedVideoURL = nil
                        }
                        self.parent.dismiss()
                    }
                }
            } else if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                provider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, _ in
                    guard let url = url else { DispatchQueue.main.async { self.parent.dismiss() }; return }
                    let tempURL = FileManager.default.temporaryDirectory
                        .appendingPathComponent(UUID().uuidString)
                        .appendingPathExtension(url.pathExtension)
                    try? FileManager.default.copyItem(at: url, to: tempURL)
                    DispatchQueue.main.async {
                        self.parent.selectedVideoURL = tempURL
                        self.parent.selectedImage = nil
                        self.parent.dismiss()
                    }
                }
            } else { parent.dismiss() }
        }
    }
}