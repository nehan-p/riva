import SwiftUI

// MARK: - Lift Input Row
struct LiftInputRow: View {
    @Binding var weight: Double?
    @Binding var sets: Int?
    @Binding var reps: Int?
    @Binding var unit: WeightUnit

    var onWeightFieldBlur: (() -> Void)? = nil

    @FocusState private var weightIsFocused: Bool

    @Environment(\.rivaTheme) private var theme
    @Environment(\.rivaAccent) private var accent

    private var weightDisplay: Binding<String> {
        Binding(
            get: {
                guard let w = weight else { return "" }
                let trimmed = w.truncatingRemainder(dividingBy: 1) == 0
                    ? String(format: "%.0f", w)
                    : String(format: "%.1f", w)
                return trimmed
            },
            set: { newValue in
                let cleaned = newValue.trimmingCharacters(in: .whitespaces)
                guard !cleaned.isEmpty else {
                    weight = nil
                    return
                }
                if let parsed = Double(cleaned.replacingOccurrences(of: ",", with: ".")) {
                    weight = parsed
                }
            }
        )
    }

    private var setsDisplay: Binding<String> {
        Binding(
            get: { sets.map { "\($0)" } ?? "" },
            set: { newValue in
                let cleaned = newValue.trimmingCharacters(in: .whitespaces)
                guard !cleaned.isEmpty else {
                    sets = nil
                    return
                }
                if let parsed = Int(cleaned) {
                    sets = parsed
                }
            }
        )
    }

    private var repsDisplay: Binding<String> {
        Binding(
            get: { reps.map { "\($0)" } ?? "" },
            set: { newValue in
                let cleaned = newValue.trimmingCharacters(in: .whitespaces)
                guard !cleaned.isEmpty else {
                    reps = nil
                    return
                }
                if let parsed = Int(cleaned) {
                    reps = parsed
                }
            }
        )
    }

    var body: some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("WEIGHT")
                    .font(.interRegular(10))
                    .foregroundColor(theme.sub)
                    .tracking(1)

                HStack(spacing: 10) {
                    Image(systemName: "scalemass")
                        .font(.system(size: 13))
                        .foregroundColor(weightIsFocused ? accent.color : theme.muted)
                        .frame(width: 18)

                    TextField("Weight", text: weightDisplay)
                        .keyboardType(.decimalPad)
                        .font(.interRegular(15))
                        .foregroundColor(theme.text)
                        .focused($weightIsFocused)
                        .onChange(of: weightIsFocused) { _, newValue in
                            if !newValue {
                                onWeightFieldBlur?()
                            }
                        }

                    HStack(spacing: 0) {
                        ForEach(WeightUnit.allCases, id: \.self) { u in
                            Button {
                                unit = u
                            } label: {
                                Text(u.displayName)
                                    .font(.interSemiBold(12))
                                    .foregroundColor(unit == u ? accent.onAccentText : theme.muted)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(unit == u ? accent.color : theme.chip)
                            }
                        }
                    }
                    .background(theme.chip)
                    .cornerRadius(8)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(weightIsFocused ? accent.color : theme.line, lineWidth: weightIsFocused ? 1.5 : 1)
                        )
                )
            }

            HStack(spacing: 12) {
                metricField(label: "SETS", icon: "repeat", placeholder: "Sets", text: setsDisplay, keyboard: .numberPad)
                metricField(label: "REPS", icon: "arrow.clockwise", placeholder: "Reps", text: repsDisplay, keyboard: .numberPad)
            }
        }
    }

    private func metricField(
        label: String,
        icon: String,
        placeholder: String,
        text: Binding<String>,
        keyboard: UIKeyboardType
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.interRegular(10))
                .foregroundColor(theme.sub)
                .tracking(1)

            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundColor(theme.muted)
                    .frame(width: 18)

                TextField(placeholder, text: text)
                    .keyboardType(keyboard)
                    .font(.interRegular(15))
                    .foregroundColor(theme.text)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(theme.line, lineWidth: 1)
                    )
            )
        }
    }
}