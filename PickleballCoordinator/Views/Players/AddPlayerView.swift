import SwiftUI
import SwiftData

struct AddPlayerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var phoneNumber = ""
    @State private var skillLevel: SkillLevel = .intermediate
    @State private var notes = ""
    @State private var isFavorite = false

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: PickleballTheme.sectionSpacing) {
                    // Basic Info Section
                    VStack(alignment: .leading, spacing: PickleballTheme.itemSpacing) {
                        Text("Basic Info")
                            .font(PickleballTheme.smallCaps)
                            .foregroundStyle(PickleballTheme.inkMuted)
                            .padding(.leading, 4)

                        VStack(spacing: 0) {
                            FormTextField(title: "Name", text: $name, placeholder: "Player name")
                            Divider().padding(.leading, 16)
                            FormTextField(title: "Phone", text: $phoneNumber, placeholder: "Phone number")
                                .keyboardType(.phonePad)
                        }
                        .pickleballCard()
                    }

                    // Skill Level Section
                    VStack(alignment: .leading, spacing: PickleballTheme.itemSpacing) {
                        Text("Skill Level")
                            .font(PickleballTheme.smallCaps)
                            .foregroundStyle(PickleballTheme.inkMuted)
                            .padding(.leading, 4)

                        VStack(spacing: 8) {
                            ForEach(SkillLevel.allCases, id: \.self) { level in
                                SkillLevelRow(
                                    level: level,
                                    isSelected: skillLevel == level
                                ) {
                                    skillLevel = level
                                }
                            }
                        }
                    }

                    // Options Section
                    VStack(alignment: .leading, spacing: PickleballTheme.itemSpacing) {
                        Text("Options")
                            .font(PickleballTheme.smallCaps)
                            .foregroundStyle(PickleballTheme.inkMuted)
                            .padding(.leading, 4)

                        Toggle(isOn: $isFavorite) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(PickleballTheme.goldAccent)
                                Text("Add to Favorites")
                                    .font(PickleballTheme.body)
                                    .foregroundStyle(PickleballTheme.inkNavy)
                            }
                        }
                        .tint(PickleballTheme.courtGreen)
                        .padding(16)
                        .pickleballCard()
                    }

                    // Notes Section
                    VStack(alignment: .leading, spacing: PickleballTheme.itemSpacing) {
                        Text("Notes")
                            .font(PickleballTheme.smallCaps)
                            .foregroundStyle(PickleballTheme.inkMuted)
                            .padding(.leading, 4)

                        TextEditor(text: $notes)
                            .font(PickleballTheme.body)
                            .foregroundStyle(PickleballTheme.inkCharcoal)
                            .frame(minHeight: 100)
                            .padding(12)
                            .scrollContentBackground(.hidden)
                            .pickleballCard()
                    }
                }
                .padding(PickleballTheme.pageMargin)
            }
            .pickleballBackground()
            .navigationTitle("Add Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(PickleballTheme.inkMuted)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePlayer()
                    }
                    .foregroundStyle(isValid ? PickleballTheme.courtGreen : PickleballTheme.inkMuted)
                    .disabled(!isValid)
                }
            }
        }
    }

    private func savePlayer() {
        let player = Player(
            name: name.trimmingCharacters(in: .whitespaces),
            phoneNumber: phoneNumber,
            skillLevel: skillLevel,
            isFavorite: isFavorite,
            notes: notes
        )
        modelContext.insert(player)
        dismiss()
    }
}

struct FormTextField: View {
    let title: String
    @Binding var text: String
    var placeholder: String = ""

    var body: some View {
        HStack {
            Text(title)
                .font(PickleballTheme.body)
                .foregroundStyle(PickleballTheme.inkNavy)
                .frame(width: 80, alignment: .leading)

            TextField(placeholder, text: $text)
                .font(PickleballTheme.body)
                .foregroundStyle(PickleballTheme.inkCharcoal)
        }
        .padding(16)
    }
}

struct SkillLevelRow: View {
    let level: SkillLevel
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(level.displayName)
                        .font(PickleballTheme.serifFont(size: 16, weight: .medium))
                        .foregroundStyle(PickleballTheme.inkNavy)

                    Text("Rating: \(level.rating)")
                        .font(PickleballTheme.caption)
                        .foregroundStyle(PickleballTheme.inkMuted)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(PickleballTheme.courtGreen)
                } else {
                    Circle()
                        .stroke(PickleballTheme.inkMuted.opacity(0.3), lineWidth: 1.5)
                        .frame(width: 22, height: 22)
                }
            }
            .padding(16)
            .pickleballCard()
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AddPlayerView()
        .modelContainer(for: Player.self, inMemory: true)
}
