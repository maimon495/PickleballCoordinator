import SwiftUI
import SwiftData

struct EditCourtView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var court: Court

    @State private var name: String
    @State private var address: String
    @State private var numberOfCourts: Int
    @State private var isIndoor: Bool
    @State private var hasLights: Bool
    @State private var surfaceType: CourtSurface
    @State private var notes: String

    init(court: Court) {
        self.court = court
        _name = State(initialValue: court.name)
        _address = State(initialValue: court.address)
        _numberOfCourts = State(initialValue: court.numberOfCourts)
        _isIndoor = State(initialValue: court.isIndoor)
        _hasLights = State(initialValue: court.hasLights)
        _surfaceType = State(initialValue: court.surfaceType)
        _notes = State(initialValue: court.notes)
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
            .navigationTitle("Edit Court")
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
        court.name = name.trimmingCharacters(in: .whitespaces)
        court.address = address
        court.numberOfCourts = numberOfCourts
        court.isIndoor = isIndoor
        court.hasLights = hasLights
        court.surfaceType = surfaceType
        court.notes = notes
        dismiss()
    }
}

#Preview {
    EditCourtView(court: Court(name: "Test Court"))
        .modelContainer(for: Court.self, inMemory: true)
}
