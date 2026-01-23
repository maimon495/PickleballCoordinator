import SwiftUI
import SwiftData

struct CourtPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Court.name) private var courts: [Court]
    @Binding var selectedCourt: Court?
    @State private var searchText = ""

    var filteredCourts: [Court] {
        if searchText.isEmpty {
            return courts
        }
        return courts.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.address.localizedCaseInsensitiveContains(searchText)
        }
    }

    var favoriteCourts: [Court] {
        filteredCourts.filter { $0.isFavorite }
    }

    var otherCourts: [Court] {
        filteredCourts.filter { !$0.isFavorite }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: PickleballTheme.sectionSpacing) {
                    if courts.isEmpty {
                        emptyState
                    } else {
                        if !favoriteCourts.isEmpty {
                            courtSection(title: "Favorites", courts: favoriteCourts)
                        }

                        if !otherCourts.isEmpty {
                            courtSection(title: "All Courts", courts: otherCourts)
                        }
                    }
                }
                .padding(PickleballTheme.pageMargin)
            }
            .pickleballBackground()
            .navigationTitle("Select Court")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search courts")
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

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 48))
                .foregroundStyle(PickleballTheme.inkMuted)

            Text("No Courts Yet")
                .font(PickleballTheme.headline)
                .foregroundStyle(PickleballTheme.inkNavy)

            Text("Add courts in the Courts tab first.")
                .font(PickleballTheme.body)
                .foregroundStyle(PickleballTheme.inkMuted)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }

    private func courtSection(title: String, courts: [Court]) -> some View {
        VStack(alignment: .leading, spacing: PickleballTheme.itemSpacing) {
            Text(title)
                .font(PickleballTheme.smallCaps)
                .foregroundStyle(PickleballTheme.inkMuted)
                .padding(.leading, 4)

            VStack(spacing: 8) {
                ForEach(courts) { court in
                    CourtPickerRow(
                        court: court,
                        isSelected: selectedCourt?.id == court.id
                    ) {
                        selectedCourt = court
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CourtPickerRow: View {
    let court: Court
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(PickleballTheme.courtGreen)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(court.name)
                            .font(PickleballTheme.serifFont(size: 15, weight: .medium))
                            .foregroundStyle(PickleballTheme.inkNavy)

                        if court.isFavorite {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(PickleballTheme.goldAccent)
                        }
                    }

                    Text(court.address)
                        .font(PickleballTheme.caption)
                        .foregroundStyle(PickleballTheme.inkMuted)
                        .lineLimit(1)

                    Text(court.displayDetails)
                        .font(PickleballTheme.caption)
                        .foregroundStyle(PickleballTheme.courtGreen)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(PickleballTheme.courtGreen)
                        .font(.system(size: 22))
                }
            }
            .padding(12)
            .pickleballCard()
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CourtPickerView(selectedCourt: .constant(nil))
        .modelContainer(for: Court.self, inMemory: true)
}
