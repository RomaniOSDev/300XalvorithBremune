import SwiftUI

struct DaylightInsightView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var expandedMonths: Set<Int> = []
    @State private var showSynced = false
    @State private var noteDraft = ""
    @State private var notingMonth: Int?

    private let monthNames = Calendar.current.monthSymbols

    var body: some View {
        VStack(spacing: 0) {
            if store.daylightData.isEmpty {
                emptyState
            } else {
                List {
                    if let last = store.lastSyncDate {
                        Text("Last sync: \(last.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .listRowBackground(Color.clear)
                    }

                    ForEach(1...12, id: \.self) { month in
                        monthSection(month)
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }

            Button {
                HapticFeedback.light()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    store.syncDaylightInsights()
                    showSynced = true
                }
            } label: {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("Sync Now")
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .font(.headline)
                .foregroundStyle(Color("AppTextPrimary"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [Color("AppPrimary"), Color("AppAccent")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: Color("AppAccent").opacity(0.4), radius: 10, y: 4)
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .padding(.bottom, AppLayout.tabContentBottomPadding)
        }
        .overlay {
            SuccessPulse(visible: $showSynced)
        }
        .dismissKeyboardOnTap()
        .alert("Add Note", isPresented: Binding(
            get: { notingMonth != nil },
            set: { if !$0 { notingMonth = nil } }
        )) {
            TextField("Observation", text: $noteDraft)
            Button("Save") {
                if let month = notingMonth {
                    let content = noteDraft.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !content.isEmpty {
                        store.addNote(UserNote(content: "\(monthNames[month - 1]): \(content)"))
                        HapticFeedback.medium()
                        SoundPlayer.success()
                    }
                }
                noteDraft = ""
                notingMonth = nil
            }
            Button("Cancel", role: .cancel) {
                noteDraft = ""
                notingMonth = nil
            }
        } message: {
            Text("Add a short observation for this month.")
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            ZStack {
                Image(systemName: "moon.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Color("AppTextSecondary"))
                    .offset(x: -28)
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Color("AppAccent"))
                    .offset(x: 20)
            }
            Text("No data available. Sync to get insights on your location's daylight patterns.")
                .font(.body)
                .foregroundStyle(Color("AppTextSecondary"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
            Text("Explore Daylight Patterns")
                .font(.headline)
                .foregroundStyle(Color("AppTextPrimary"))
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func monthSection(_ month: Int) -> some View {
        let entries = store.daylightData.filter { $0.month == month }
        let isExpanded = expandedMonths.contains(month)
        let avg = entries.isEmpty ? 0 : entries.map(\.durationHours).reduce(0, +) / Double(entries.count)

        VStack(alignment: .leading, spacing: 10) {
            Button {
                HapticFeedback.light()
                withAnimation(.easeInOut(duration: 0.3)) {
                    if isExpanded {
                        expandedMonths.remove(month)
                    } else {
                        expandedMonths.insert(month)
                    }
                }
            } label: {
                HStack {
                    Text(monthNames[month - 1])
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                    Spacer()
                    Text(String(format: "%.1fh avg", avg))
                        .font(.caption)
                        .foregroundStyle(Color("AppAccent"))
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                MonthChart(entries: entries)
                    .frame(height: 120)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.vertical, 6)
        .listRowBackground(Color("AppSurface"))
        .swipeActions(edge: .leading) {
            Button {
                notingMonth = month
            } label: {
                Label("Note", systemImage: "square.and.pencil")
            }
            .tint(Color("AppPrimary"))
        }
    }
}

struct MonthChart: View {
    let entries: [DaylightEntry]

    var body: some View {
        GeometryReader { geo in
            let values = entries.map(\.durationHours)
            let minV = (values.min() ?? 0) - 0.3
            let maxV = (values.max() ?? 24) + 0.3
            let range = max(maxV - minV, 0.1)
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("AppBackground").opacity(0.5))
                Path { path in
                    guard entries.count > 1 else { return }
                    for (index, entry) in entries.enumerated() {
                        let x = geo.size.width * CGFloat(index) / CGFloat(entries.count - 1)
                        let y = geo.size.height * (1 - CGFloat((entry.durationHours - minV) / range))
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(
                    LinearGradient(
                        colors: [Color("AppPrimary"), Color("AppAccent")],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                )
                .shadow(color: Color("AppAccent").opacity(0.5), radius: 6)
            }
        }
    }
}
