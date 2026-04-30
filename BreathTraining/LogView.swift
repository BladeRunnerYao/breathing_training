import SwiftUI

struct LogView: View {
    @EnvironmentObject private var logStore: LogStore
    @State private var selectedDate: Date = Date()

    var body: some View {
        NavigationStack {
            ZStack {
                CalmBackground()
                ScrollView {
                    VStack(spacing: 16) {
                        monthHeader
                        CalendarMonthView(selectedDate: $selectedDate)
                            .softCard()
                        logList
                    }
                    .padding()
                }
            }
            .navigationTitle("Training Log")
        }
    }

    private var monthHeader: some View {
        HStack {
            Button(action: { shiftMonth(by: -1) }) {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text(monthTitle(for: selectedDate))
                .font(.custom("Avenir Next", size: 20))
            Spacer()
            Button(action: { shiftMonth(by: 1) }) {
                Image(systemName: "chevron.right")
            }
        }
        .padding(.horizontal, 4)
    }

    private var logList: some View {
        let logs = logStore.logs(on: selectedDate)
        return VStack(alignment: .leading, spacing: 8) {
            Text("Logs on \(dateTitle(selectedDate))")
                .font(.custom("Avenir Next", size: 18))

            if logs.isEmpty {
                Text("No training records")
                    .foregroundColor(.secondary)
            } else {
                ForEach(logs) { log in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Duration: \(formatDuration(log.durationSeconds))")
                        Text("Inhale \(log.inhaleSeconds)s / Exhale \(log.exhaleSeconds)s")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Groups: \(log.groupCount)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                    .contextMenu {
                        Button("Delete") {
                            logStore.delete(log: log)
                        }
                    }
                }
            }

            Button("Delete All Logs") {
                logStore.deleteAll()
            }
            .foregroundColor(.red)
            .padding(.top, 8)
        }
        .softCard()
    }

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
