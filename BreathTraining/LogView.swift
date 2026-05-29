import SwiftUI

struct LogView: View {
    @EnvironmentObject private var logStore: LogStore
    @State private var selectedDate: Date = Date()
    @Environment(\.zen) private var zen

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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    EmptyView()
                }
            }
        }
    }

    // MARK: - Month Navigation

    private var monthHeader: some View {
        HStack {
            Button(action: { shiftMonth(by: -1) }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(zen.gold)
                    .font(.system(size: 18, weight: .medium))
            }
            Spacer()
            Text(monthTitle(for: selectedDate))
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundColor(zen.textPrimary)
            Spacer()
            Button(action: { shiftMonth(by: 1) }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(zen.gold)
                    .font(.system(size: 18, weight: .medium))
            }
        }
        .padding(.horizontal, 4)
    }

    // MARK: - Session List

    private var logList: some View {
        let logs = logStore.logs(on: selectedDate)
        return VStack(alignment: .leading, spacing: 0) {
            Text(dateTitle(selectedDate))
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(zen.textMuted)
                .tracking(1)
                .textCase(.uppercase)
                .padding(.bottom, 12)

            if logs.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "leaf")
                            .font(.system(size: 28))
                            .foregroundColor(zen.textMuted.opacity(0.5))
                        Text("Rest day")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(zen.textMuted)
                    }
                    .padding(.vertical, 24)
                    Spacer()
                }
            } else {
                ForEach(Array(logs.enumerated()), id: \.element.id) { index, log in
                    VStack(spacing: 0) {
                        if index > 0 {
                            zen.divider
                                .frame(height: 0.5)
                        }
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(formatDuration(log.durationSeconds))
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(zen.textPrimary)
                                Text("\(log.inhaleSeconds)s in · \(log.exhaleSeconds)s out · \(log.groupCount) groups")
                                    .font(.system(size: 13, design: .rounded))
                                    .foregroundColor(zen.textSecondary)
                            }
                            Spacer()
                            Text(timeOfDay(log.startDate))
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundColor(zen.textMuted)
                        }
                        .padding(.vertical, 12)
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            logStore.delete(log: log)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
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

    private func timeOfDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
