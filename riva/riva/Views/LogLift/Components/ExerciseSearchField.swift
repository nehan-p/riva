import SwiftUI

// MARK: - Exercise Search Field
struct ExerciseSearchField: View {
    @Binding var text: String
    @FocusState.Binding var isFocused: Bool

    @Environment(\.rivaTheme) private var theme
    @Environment(\.rivaAccent) private var accent

    private static let exerciseList: [String] = [
        "Bench Press", "Squat", "Deadlift", "Overhead Press", "Barbell Row",
        "Pull-Up", "Dip", "Incline Bench Press", "Romanian Deadlift",
        "Leg Press", "Hip Thrust", "Lateral Raise", "Bicep Curl",
        "Tricep Pushdown", "Face Pull", "Cable Row", "Front Squat",
        "Sumo Deadlift", "Hack Squat", "Dumbbell Row",
    ]

    private var filteredSuggestions: [String] {
        guard isFocused, !text.isEmpty else { return [] }
        let query = text.lowercased()
        return Self.exerciseList.filter { $0.lowercased().contains(query) }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 13))
                    .foregroundColor(isFocused ? accent.color : theme.muted)
                    .frame(width: 18)

                TextField("Exercise name", text: $text)
                    .font(.interRegular(15))
                    .foregroundColor(theme.text)
                    .focused($isFocused)
                    .disableAutocorrection(true)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isFocused ? accent.color : theme.line, lineWidth: isFocused ? 1.5 : 1)
                    )
            )

            if !filteredSuggestions.isEmpty {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(filteredSuggestions, id: \.self) { suggestion in
                            Button {
                                text = suggestion
                                isFocused = false
                            } label: {
                                HStack {
                                    Text(suggestion)
                                        .font(.interRegular(14))
                                        .foregroundColor(theme.text)
                                    Spacer()
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                            }

                            if suggestion != filteredSuggestions.last {
                                Divider()
                                    .background(theme.line)
                                    .padding(.horizontal, 14)
                            }
                        }
                    }
                }
                .frame(maxHeight: 200)
                .background(theme.raised)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(theme.line, lineWidth: 1)
                )
                .padding(.top, 4)
            }
        }
    }
}