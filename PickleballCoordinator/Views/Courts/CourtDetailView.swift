import SwiftUI
import SwiftData

struct CourtDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var court: Court

    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: PickleballTheme.sectionSpacing) {
                // Header
                headerSection

                // Details
                detailsSection

                // Features
                featuresSection

                // Notes
                if !court.notes.isEmpty {
                    notesSection
                }

                // Actions
                actionsSection
            }
            .padding(PickleballTheme.pageMargin)
        }
        .pickleballBackground()
        .navigationTitle(court.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showingEditSheet = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }

                    Button {
                        court.isFavorite.toggle()
                    } label: {
                        Label(
                            court.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                            systemImage: court.isFavorite ? "star.slash" : "star"
                        )
                    }

                    Divider()

                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(PickleballTheme.courtGreen)
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditCourtView(court: court)
        }
        .alert("Delete Court?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                modelContext.delete(court)
                dismiss()
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(PickleballTheme.courtGreen)

            VStack(spacing: 4) {
                HStack {
                    Text(court.name)
                        .font(PickleballTheme.title)
                        .foregroundStyle(PickleballTheme.inkNavy)

                    if court.isFavorite {
                        Image(systemName: "star.fill")
                            .foregroundStyle(PickleballTheme.goldAccent)
                    }
                }

                if !court.address.isEmpty {
                    Text(court.address)
                        .font(PickleballTheme.subheadline)
                        .foregroundStyle(PickleballTheme.inkMuted)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .pickleballCard()
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: PickleballTheme.itemSpacing) {
            Text("Details")
                .font(PickleballTheme.smallCaps)
                .foregroundStyle(PickleballTheme.inkMuted)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                DetailRow(icon: "square.grid.2x2", title: "Courts", value: "\(court.numberOfCourts)")

                Divider().padding(.leading, 44)

                DetailRow(icon: "square.fill", title: "Surface", value: court.surfaceType.displayName)

                Divider().padding(.leading, 44)

                DetailRow(icon: "calendar", title: "Added", value: court.createdAt.formatted(date: .abbreviated, time: .omitted))
            }
            .pickleballCard()
        }
    }

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: PickleballTheme.itemSpacing) {
            Text("Features")
                .font(PickleballTheme.smallCaps)
                .foregroundStyle(PickleballTheme.inkMuted)
                .padding(.leading, 4)

            HStack(spacing: 12) {
                FeatureBadge(
                    icon: "building.2",
                    title: court.isIndoor ? "Indoor" : "Outdoor",
                    isActive: true
                )

                FeatureBadge(
                    icon: "lightbulb",
                    title: "Lights",
                    isActive: court.hasLights
                )
            }
        }
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: PickleballTheme.itemSpacing) {
            Text("Notes")
                .font(PickleballTheme.smallCaps)
                .foregroundStyle(PickleballTheme.inkMuted)
                .padding(.leading, 4)

            Text(court.notes)
                .font(PickleballTheme.body)
                .foregroundStyle(PickleballTheme.inkCharcoal)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .pickleballCard()
        }
    }

    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button {
                if let url = court.mapsURL {
                    UIApplication.shared.open(url)
                }
            } label: {
                HStack {
                    Image(systemName: "map")
                    Text("Get Directions")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(court.address.isEmpty)

            Button {
                // Navigate to create game with court pre-selected
            } label: {
                HStack {
                    Image(systemName: "calendar.badge.plus")
                    Text("Schedule Game Here")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .padding(.top, 8)
    }
}

struct FeatureBadge: View {
    let icon: String
    let title: String
    let isActive: Bool

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(isActive ? PickleballTheme.courtGreen : PickleballTheme.inkMuted.opacity(0.5))

            Text(title)
                .font(PickleballTheme.caption)
                .foregroundStyle(isActive ? PickleballTheme.inkNavy : PickleballTheme.inkMuted.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .pickleballCard()
        .opacity(isActive ? 1.0 : 0.6)
    }
}

#Preview {
    NavigationStack {
        CourtDetailView(court: Court(name: "Central Park Courts", address: "123 Main St"))
    }
    .modelContainer(for: Court.self, inMemory: true)
}
