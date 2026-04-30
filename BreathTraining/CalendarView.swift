import SwiftUI

struct CalendarMonthView: View {
    @EnvironmentObject private var logStore: LogStore
    @Binding var selectedDate: Date
    private let calendar = Calendar.current

    var body: some View {
        let monthDates = daysInMonthGrid(for: selectedDate)
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            ForEach(monthDates, id: \.self) { date in
                dayCell(date: date)
            }
        }
    }

    private func dayCell(date: Date?) -> some View {
        Group {
            if let date {
                let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                let hasLog = logStore.hasLogs(on: date)
                VStack(spacing: 4) {
                    Text("\(calendar.component(.day, from: date))")
                        .font(.callout)
                        .frame(maxWidth: .infinity)
                    Circle()
                        .fill(hasLog ? CalmPalette.accent : Color.clear)
                        .frame(width: 6, height: 6)
                }
                .padding(6)
                .background(isSelected ? CalmPalette.accent.opacity(0.18) : Color.clear)
                .cornerRadius(8)
                .onTapGesture {
                    selectedDate = date
                }
            } else {
                Text(" ")
                    .padding(6)
            }
        }
    }

    private var weekdaySymbols: [String] {
        let symbols = calendar.shortStandaloneWeekdaySymbols
        let first = calendar.firstWeekday - 1
        return Array(symbols[first...] + symbols[..<first])
    }

    private func daysInMonthGrid(for date: Date) -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date) else { return [] }
        let startOfMonth = monthInterval.start
        let daysRange = calendar.range(of: .day, in: .month, for: date) ?? 1..<2
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let leadingEmpty = (firstWeekday - calendar.firstWeekday + 7) % 7

        var dates: [Date?] = Array(repeating: nil, count: leadingEmpty)
        for day in daysRange {
            if let dayDate = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                dates.append(dayDate)
            }
        }
        return dates
    }
}
