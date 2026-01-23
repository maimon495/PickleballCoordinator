import SwiftUI
import SwiftData

struct AddCourtView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var address = ""
    @State private var numberOfCourts = 1
    @State private var isIndoor = false
    @State private var hasLights = false
    @State private var surfaceType: CourtSurface = .concrete
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
                            FormTextField(title: "Name", text: $name, placeholder: "Court name")
                            Divider().padding(.leading, 16)
                            FormTextField(title: "Address", text: $address, placeholder: "Full address")
                        }
                        .pickleballCard()
                    }

                    // Court Details Section
                    VStack(alignment: .leading, spacing: PickleballTheme.itemSpacing) {
                        Text("Court Details")
                            .font(PickleballTheme.smallCaps)
                            .foregroundStyle(PickleballTheme.inkMuted)
                            .padding(.leading, 4)

                        VStack(spacing: 0) {
                            HStack {
                                Text("Number of Courts")
                                    .font(PickleballTheme.body)
                                    .foregroundStyle(PickleballTheme.inkNavy)

                                Spacer()

                                Stepper("\(numberOfCourts)", value: $numberOfCourts, in: 1...20)
                                    .labelsHidden()

                                Text("\(numberOfCourts)")
                                    .font(PickleballTheme.body)
                                    .foregroundStyle(PickleballTheme.inkCharcoal)
                                    .frame(width: 30)
                            }
                            .padding(16)

                            Divider().padding(.leading, 16)

                            HStack {
                                Text("Surface Type")
                                    .font(PickleballTheme.body)
                                    .foregroundStyle(PickleballTheme.inkNavy)

                                Spacer()

                                Picker("", selection: $surfaceType) {
                                    ForEach(CourtSurface.allCases, id: \.self) { surface in
                                        Text(surface.displayName).tag(surface)
                                    }
                                }
                                .tint(PickleballTheme.courtGreen)
                            }
                            .padding(16)
                        }
                        .pickleballCard()
                    }

                    // Features Section
                    VStack(alignment: .leading, spacing: PickleballTheme.itemSpacing) {
                        Text("Features")
                            .font(PickleballTheme.smallCaps)
                            .foregroundStyle(PickleballTheme.inkMuted)
                            .padding(.leading, 4)

                        VStack(spacing: 0) {
                            Toggle(isOn: $isIndoor) {
                                HStack {
                                    Image(systemName: "building.2")
                                        .foregroundStyle(PickleballTheme.courtGreen)
                                    Text("Indoor Courts")
                                        .font(PickleballTheme.body)
                                        .foregroundStyle(PickleballTheme.inkNavy)
                                }
                            }
                            .tint(PickleballTheme.courtGreen)
                            .padding(16)

                            Divider().padding(.leading, 44)

                            Toggle(isOn: $hasLights) {
                                HStack {
                                    Image(systemName: "lightbulb")
                                        .foregroundStyle(PickleballTheme.courtGreen)
                                    Text("Has Lights")
                                        .font(PickleballTheme.body)
                                        .foregroundStyle(PickleballTheme.inkNavy)
                                }
                            }
                            .tint(PickleballTheme.courtGreen)
                            .padding(16)

                            Divider().padding(.leading, 44)

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
                        }
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
                            .frame(minHeight: 80)
                            .padding(12)
                            .scrollContentBackground(.hidden)
                            .pickleballCard()
                    }
                }
                .padding(PickleballTheme.pageMargin)
            }
            .pickleballBackground()
            .navigationTitle("Add Court")
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
                        saveCourt()
                    }
                    .foregroundStyle(isValid ? PickleballTheme.courtGreen : PickleballTheme.inkMuted)
                    .disabled(!isValid)
                }
            }
        }
    }

    private func saveCourt() {
        let court = Court(
            name: name.trimmingCharacters(in: .whitespaces),
            address: address,
            numberOfCourts: numberOfCourts,
            isIndoor: isIndoor,
            hasLights: hasLights,
            surfaceType: surfaceType,
            notes: notes
        )
        court.isFavorite = isFavorite
        modelContext.insert(court)
        dismiss()
    }
}

#Preview {
    AddCourtView()
        .modelContainer(for: Court.self, inMemory: true)
}
