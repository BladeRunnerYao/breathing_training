import SwiftUI

struct LogView: View {
    @EnvironmentObject private var logStore: LogStore
    @State private var selectedDate: Date = Date()

    var body: some View {
        NavigationStack {
            ZStack {
                ZenBackground()
                ScrollView {
                    VStack(spacing: 16) {
                        monthHeader
                        CalendarMonthView(selectedDate: $selectedDate)
                            .zenCard()
                        logList
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Training Log")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    // MARK: - Month Navigation

    private var monthHeader: some View {
        HStack {
            Button(action: { shiftMonth(by: -1) }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(ZenPalette.gold)
                    .font(.system(size: 18, weight: .medium))
            }
            Spacer()
            Text(monthTitle(for: selectedDate))
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundColor(ZenPalette.textPrimary)
            Spacer()
            Button(action: { shiftMonth(by: 1) }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(ZenPalette.gold)
                    .font(.system(size: 18, weight: .medium))
            }
        }
        .padding(.horizontal, 4)
    }

    // MARK: - Session List

    private var logList: some View {
        let logs = logStore.logs(on: selectedDate)
        return VStack(alignment: .leading, spacing: 12) {
            Text("Sessions on \(dateTitle(selectedDate))")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(ZenPalette.textPrimary)

            if logs.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "figure.mind.and.body")
                        .font(.system(size: 36))
                        .foregroundColor(ZenPalette.textMuted)
                    Text("No sessions recorded")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(ZenPalette.textMuted)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                ForEach(logs) { log in
                    HStack(spacing: 0) {
                        // Left accent border
                        Rectangle()
                            .fill(ZenPalette.gold)
                            .frame(width: 3)
                            .cornerRadius(1.5)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Duration: \(formatDuration(log.durationSeconds))")
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(ZenPalette.textPrimary)
                            Text("Inhale \(log.inhaleSeconds)s / Exhale \(log.exhaleSeconds)s")
                                .font(.system(size: 13, design: .rounded))
                                .foregroundColor(ZenPalette.textSecondary)
                            Text("Groups: \(log.groupCount)")
                                .font(.system(size: 13, design: .rounded))
                                .foregroundColor(ZenPalette.textSecondary)
                        }
                        .padding(.leading, 12)
                        .padding(.vertical, 12)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(ZenPalette.backgroundSurface.opacity(0.7))
                    )
                    .contextMenu {
                        Button(role: .destructive) {
                            logStore.delete(log: log)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }

            Button(role: .destructive) {
                logStore.deleteAll()
            } label: {
                Text("Delete All Logs")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundColor(ZenPalette.danger)
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Helpers

    private func shiftMonth(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: selectedDate) {
            selectedDate = newDate
        }
    }

    private func monthTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    private func dateTitle(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let rem = seconds % 60
        if minutes > 0 {
            return "\(minutes)m \(rem)s"
        }
        return "\(rem)s"
    }
}
