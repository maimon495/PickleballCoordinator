import SwiftUI
import SwiftData

struct EditPlayerView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var player: Player

    @State private var name: String
    @State private var phoneNumber: String
    @State private var skillLevel: SkillLevel
    @State private var notes: String
    @State private var preferredDays: Set<Int>

    init(player: Player) {
        self.player = player
        _name = State(initialValue: player.name)
        _phoneNumber = State(initialValue: player.phoneNumber)
        _skillLevel = State(initialValue: player.skillLevel)
        _notes = State(initialValue: player.notes)
        _preferredDays = State(initialValue: Set(player.preferredDays))
    }

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

                    // Availability Section
                    VStack(alignment: .leading, spacing: PickleballTheme.itemSpacing) {
                        Text("Preferred Days")
                            .font(PickleballTheme.smallCaps)
                            .foregroundStyle(PickleballTheme.inkMuted)
                            .padding(.leading, 4)

                        HStack(spacing: 8) {
                            ForEach(Array(zip(["S", "M", "T", "W", "T", "F", "S"].indices, ["S", "M", "T", "W", "T", "F", "S"])), id: \.0) { index, day in
                                let dayNumber = index + 1

                                Button {
                                    if preferredDays.contains(dayNumber) {
                                        preferredDays.remove(dayNumber)
                                    } else {
                                        preferredDays.insert(dayNumber)
                                    }
                                } label: {
                                    Text(day)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(
                                            preferredDays.contains(dayNumber)
                                            ? PickleballTheme.cream
                                            : PickleballTheme.inkMuted
                                        )
                                        .frame(width: 36, height: 36)
                                        .background(
                                            Circle()
                                                .fill(
                                                    preferredDays.contains(dayNumber)
                                                    ? PickleballTheme.courtGreen
                                                    : PickleballTheme.cream
                                                )
                                        )
                                }
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity)
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
            .navigationTitle("Edit Player")
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
                        saveChanges()
                    }
                    .foregroundStyle(isValid ? PickleballTheme.courtGreen : PickleballTheme.inkMuted)
                    .disabled(!isValid)
                }
            }
        }
    }

    private func saveChanges() {
        player.name = name.trimmingCharacters(in: .whitespaces)
        player.phoneNumber = phoneNumber
        player.skillLevel = skillLevel
        player.notes = notes
        player.preferredDays = Array(preferredDays).sorted()
        dismiss()
    }
}

#Preview {
    EditPlayerView(player: Player(name: "John Smith"))
        .modelContainer(for: Player.self, inMemory: true)
}
