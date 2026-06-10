import Foundation
import Observation
import SwiftUI

// MARK: - Log Lift View Model
@MainActor
@Observable
final class LogLiftViewModel {
    var exerciseName: String = ""
    var weight: Double? = nil
    var sets: Int? = nil
    var reps: Int? = nil
    var unit: WeightUnit = .lbs
    var isPR: Bool = false
    var selectedImage: UIImage? = nil
    var selectedVideoURL: URL? = nil
    var caption: String = ""
    var isLoading: Bool = false
    var errorMessage: String? = nil

    let userId: UUID
    private let supabase = SupabaseService.shared
    private var personalBestTask: Task<Void, Never>?

    var canPost: Bool {
        !exerciseName.trimmingCharacters(in: .whitespaces).isEmpty
            && weight != nil
            && sets != nil
            && reps != nil
    }

    var hasAnyField: Bool {
        !exerciseName.isEmpty
            || weight != nil
            || sets != nil
            || reps != nil
            || !caption.isEmpty
            || selectedImage != nil
            || selectedVideoURL != nil
    }

    init(userId: UUID) {
        self.userId = userId
    }

    func checkPersonalBest() {
        personalBestTask?.cancel()
        guard !exerciseName.isEmpty, let weight = weight else {
            isPR = false
            return
        }
        personalBestTask = Task {
            do {
                let isNewPR = try await supabase.checkPersonalBest(
                    userId: userId,
                    exerciseName: exerciseName,
                    weight: weight,
                    unit: unit.rawValue
                )
                guard !Task.isCancelled else { return }
                self.isPR = isNewPR
            } catch {
                guard !Task.isCancelled else { return }
                isPR = false
            }
        }
    }

    func submit(onPostCreated: @escaping () async -> Void) async {
        guard canPost, let weight = weight, let sets = sets, let reps = reps else {
            errorMessage = "Please fill in all required fields."
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            var mediaURL: String? = nil
            var mediaType: String? = nil
            if let image = selectedImage {
                let url = try await supabase.uploadImage(userId: userId, image: image)
                mediaURL = url
                mediaType = "photo"
            } else if let videoURL = selectedVideoURL {
                let url = try await supabase.uploadVideo(userId: userId, fileURL: videoURL)
                mediaURL = url
                mediaType = "video"
            }
            try await supabase.createPost(
                userId: userId,
                exerciseName: exerciseName.trimmingCharacters(in: .whitespaces),
                weight: weight,
                sets: sets,
                reps: reps,
                unit: unit.rawValue,
                isPR: isPR,
                caption: caption.isEmpty ? nil : caption.trimmingCharacters(in: .whitespaces),
                mediaURL: mediaURL,
                mediaType: mediaType
            )
            isLoading = false
            await onPostCreated()
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    func reset() {
        personalBestTask?.cancel()
        personalBestTask = nil
        exerciseName = ""
        weight = nil
        sets = nil
        reps = nil
        unit = .lbs
        isPR = false
        selectedImage = nil
        selectedVideoURL = nil
        caption = ""
        isLoading = false
        errorMessage = nil
    }
}