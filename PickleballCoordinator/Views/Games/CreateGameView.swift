import SwiftUI
import SwiftData

struct CreateGameView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Player.name) private var allPlayers: [Player]
    @Query(sort: \Court.name) private var allCourts: [Court]

    @State private var title = ""
    @State private var gameType: GameType = .doubles
    @State private var minimumPlayers = 4
    @State private var selectedCourt: Court?
    @State private var selectedPlayers: Set<Player> = []
    @State private var timeOptions: [Date] = []
    @State private var notes = ""

    @State private var showingPlayerPicker = false
    @State private var showingCourtPicker = false
    @State private var showingDatePicker = false
    @State private var newDateTime = Date()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: PickleballTheme.sectionSpacing) {
                    // Game Info Section
                    gameInfoSection

                    // Location Section
                    locationSection

                    // Time Options Section
                    timeOptionsSection

                    // Invite Players Section
                    playersSection

                    // Notes Section
                    notesSection
                }
                .padding(PickleballTheme.pageMargin)
            }
            .pickleballBackground()
            .navigationTitle("New Game")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(PickleballTheme.inkMuted)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createGame()
                    }
                    .foregroundStyle(PickleballTheme.courtGreen)
                    .disabled(timeOptions.isEmpty)
                }
            }
            .sheet(isPresented: $showingPlayerPicker) {
                PlayerPickerView(selectedPlayers: $selectedPlayers)
            }
            .sheet(isPresented: $showingCourtPicker) {
                CourtPickerView(selectedCourt: $selectedCourt)
            }
            .sheet(isPresented: $showingDatePicker) {
                DatePickerSheet(selectedDate: $newDateTime) {
                    timeOptions.append(newDateTime)
                    newDateTime = Date()
                }
            }
        }
    }

    private var gameInfoSection: some View {
        VStack(alignment: .leading, spacing: PickleballTheme.itemSpacing) {
            Text("Game Info")
                .font(PickleballTheme.smallCaps)
                .foregroundStyle(PickleballTheme.inkMuted)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                FormTextField(title: "Title", text: $title, placeholder: "Optional game title")

                Divider().padding(.leading, 16)

                HStack {
                    Text("Type")
                        .font(PickleballTheme.body)
                        .foregroundStyle(PickleballTheme.inkNavy)
                        .frame(width: 80, alignment: .leading)

                    Picker("", selection: $gameType) {
                        ForEach(GameType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(16)

                Divider().padding(.leading, 16)

                HStack {
                    Text("Players")
                        .font(PickleballTheme.body)
                        .foregroundStyle(PickleballTheme.inkNavy)
                        .frame(width: 80, alignment: .leading)

                    Picker("", selection: $minimumPlayers) {
                        Text("2").tag(2)
                        Text("4").tag(4)
                        Text("6").tag(6)
                    }
                    .pickerStyle(.segmented)
                }
                .padding(16)
            }
            .pickleballCard()
        }
    }

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: PickleballTheme.itemSpacing) {
            Text("Location")
                .font(PickleballTheme.smallCaps)
                .foregroundStyle(PickleballTheme.inkMuted)
                .padding(.leading, 4)

            Button {
                showingCourtPicker = true
            } label: {
                HStack {
                    if let court = selectedCourt {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(court.name)
                                .font(PickleballTheme.serifFont(size: 16, weight: .medium))
                                .foregroundStyle(PickleballTheme.inkNavy)

                            Text(court.address)
                                .font(PickleballTheme.caption)
                                .foregroundStyle(PickleballTheme.inkMuted)
                                .lineLimit(1)
                        }
                    } else {
                        HStack(spacing: 8) {
                            Image(systemName: "mappin.circle")
                                .foregroundStyle(PickleballTheme.courtGreen)
                            Text("Select Court")
                                .font(PickleballTheme.body)
                                .foregroundStyle(PickleballTheme.inkMuted)
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(PickleballTheme.inkMuted.opacity(0.5))
                }
                .padding(16)
                .pickleballCard()
            }
            .buttonStyle(.plain)
        }
    }

    private var timeOptionsSection: some View {
        VStack(alignment: .leading, spacing: PickleballTheme.itemSpacing) {
            HStack {
                Text("Time Options")
                    .font(PickleballTheme.smallCaps)
                    .foregroundStyle(PickleballTheme.inkMuted)

                Spacer()

                Button {
                    showingDatePicker = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("Add")
                    }
                    .font(PickleballTheme.caption)
                    .foregroundStyle(PickleballTheme.courtGreen)
                }
            }
            .padding(.horizontal, 4)

            if timeOptions.isEmpty {
                HStack {
                    Image(systemName: "calendar.badge.plus")
                        .foregroundStyle(PickleballTheme.inkMuted)
                    Text("Add at least one time option")
                        .font(PickleballTheme.body)
                        .foregroundStyle(PickleballTheme.inkMuted)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .pickleballCard()
            } else {
                VStack(spacing: 8) {
                    ForEach(timeOptions.sorted(), id: \.self) { date in
                        TimeOptionRow(date: date) {
                            timeOptions.removeAll { $0 == date }
                        }
                    }
                }
            }
        }
    }

    private var playersSection: some View {
        VStack(alignment: .leading, spacing: PickleballTheme.itemSpacing) {
            HStack {
                Text("Invite Players")
                    .font(PickleballTheme.smallCaps)
                    .foregroundStyle(PickleballTheme.inkMuted)

                Spacer()

                Button {
                    showingPlayerPicker = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("Add")
                    }
                    .font(PickleballTheme.caption)
                    .foregroundStyle(PickleballTheme.courtGreen)
                }
            }
            .padding(.horizontal, 4)

            if selectedPlayers.isEmpty {
                HStack {
                    Image(systemName: "person.badge.plus")
                        .foregroundStyle(PickleballTheme.inkMuted)
                    Text("Select players to invite")
                        .font(PickleballTheme.body)
                        .foregroundStyle(PickleballTheme.inkMuted)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .pickleballCard()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(selectedPlayers)) { player in
                            SelectedPlayerChip(player: player) {
                                selectedPlayers.remove(player)
                            }
                        }
                    }
                }

                Text("\(selectedPlayers.count) player\(selectedPlayers.count == 1 ? "" : "s") selected")
                    .font(PickleballTheme.caption)
                    .foregroundStyle(PickleballTheme.inkMuted)
                    .padding(.leading, 4)
            }
        }
    }

    private var notesSection: some View {
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

    private func createGame() {
        let game = Game(
            title: title.isEmpty ? "Pickleball Game" : title,
            gameType: gameType,
            minimumPlayers: minimumPlayers,
            notes: notes
        )
        game.court = selectedCourt
        game.players = Array(selectedPlayers)

        // Create time options
        var options: [GameTimeOption] = []
        for date in timeOptions {
            let option = GameTimeOption(proposedDate: date)
            option.game = game
            options.append(option)
        }
        game.timeOptions = options

        modelContext.insert(game)
        dismiss()
    }
}

struct TimeOptionRow: View {
    let date: Date
    let onDelete: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .font(PickleballTheme.serifFont(size: 15, weight: .medium))
                    .foregroundStyle(PickleballTheme.inkNavy)

                Text(date.formatted(date: .omitted, time: .shortened))
                    .font(PickleballTheme.caption)
                    .foregroundStyle(PickleballTheme.inkMuted)
            }

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(PickleballTheme.inkMuted.opacity(0.5))
            }
        }
        .padding(12)
        .pickleballCard()
    }
}

struct SelectedPlayerChip: View {
    let player: Player
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            PlayerAvatar(player: player, size: 24)

            Text(player.name.split(separator: " ").first.map(String.init) ?? player.name)
                .font(PickleballTheme.caption)
                .foregroundStyle(PickleballTheme.inkNavy)

            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(PickleballTheme.inkMuted)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(PickleballTheme.cream)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(PickleballTheme.inkMuted.opacity(0.2), lineWidth: 1)
        )
    }
}

struct DatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDate: Date
    let onAdd: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                DatePicker(
                    "Select Date & Time",
                    selection: $selectedDate,
                    in: Date()...,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.graphical)
                .tint(PickleballTheme.courtGreen)

                Button("Add Time Option") {
                    onAdd()
                    dismiss()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding()
            .navigationTitle("Add Time Option")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(PickleballTheme.inkMuted)
                }
            }
        }
    }
}

#Preview {
    CreateGameView()
        .modelContainer(for: [Game.self, Player.self, Court.self], inMemory: true)
}
