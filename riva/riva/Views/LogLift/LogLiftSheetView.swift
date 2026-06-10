import SwiftUI

// MARK: - Log Lift Sheet View
struct LogLiftSheetView: View {
    @State private var viewModel: LogLiftViewModel
    @FocusState private var exerciseFocused: Bool
    @State private var showDiscardAlert = false

    let onPostCreated: () async -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.rivaTheme) private var theme
    @Environment(\.rivaAccent) private var accent

    init(userId: UUID, onPostCreated: @escaping () async -> Void) {
        _viewModel = State(initialValue: LogLiftViewModel(userId: userId))
        self.onPostCreated = onPostCreated
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ExerciseSearchField(text: $viewModel.exerciseName, isFocused: $exerciseFocused)

                    LiftInputRow(
                        weight: $viewModel.weight,
                        sets: $viewModel.sets,
                        reps: $viewModel.reps,
                        unit: $viewModel.unit,
                        onWeightFieldBlur: { viewModel.checkPersonalBest() }
                    )

                    if viewModel.isPR {
                        PRBadge().frame(maxWidth: .infinity, alignment: .leading)
                    }

                    MediaAttachmentView(
                        selectedImage: $viewModel.selectedImage,
                        selectedVideoURL: $viewModel.selectedVideoURL
                    )

                    VStack(alignment: .leading, spacing: 6) {
                        Text("CAPTION")
                            .font(.interRegular(10))
                            .foregroundColor(theme.sub)
                            .tracking(1)

                        TextField("Add a caption (optional)", text: $viewModel.caption, axis: .vertical)
                            .font(.interRegular(15))
                            .foregroundColor(theme.text)
                            .lineLimit(3...6)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(theme.surface)
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(theme.line, lineWidth: 1))
                            )
                    }

                    AuthButton(
                        label: "Post",
                        action: {
                            Task {
                                await viewModel.submit {
                                    await onPostCreated()
                                    dismiss()
                                }
                            }
                        },
                        isLoading: viewModel.isLoading,
                        isDisabled: !viewModel.canPost
                    )
                    .padding(.top, 8)
                }
                .padding(20)
            }
            .background(theme.background)
            .navigationTitle("Log Lift")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Log Lift")
                        .font(.archivoSemiBold(17))
                        .foregroundColor(theme.text)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        if viewModel.hasAnyField { showDiscardAlert = true } else { dismiss() }
                    }
                    .font(.interMedium(15))
                    .foregroundColor(theme.muted)
                }
            }
            .alert("Discard Lift?", isPresented: $showDiscardAlert) {
                Button("Keep Editing", role: .cancel) {}
                Button("Discard", role: .destructive) { dismiss() }
            } message: {
                Text("You have filled in some fields. Are you sure you want to discard this lift?")
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK") {}
            } message: {
                if let error = viewModel.errorMessage { Text(error) }
            }
            .interactiveDismissDisabled(viewModel.hasAnyField)
        }
    }
}