import SwiftUI

struct CalendarMonthView: View {
    @EnvironmentObject private var logStore: LogStore
    @Binding var selectedDate: Date
    private let calendar = Calendar.current

    var body: some View {
        let monthDates = daysInMonthGrid(for: selectedDate)
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(ZenPalette.textMuted)
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
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(isSelected ? ZenPalette.gold : ZenPalette.textPrimary)
                        .frame(maxWidth: .infinity)
                    Circle()
                        .fill(hasLog ? ZenPalette.gold : Color.clear)
                        .frame(width: 5, height: 5)
                }
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? ZenPalette.gold.opacity(0.25) : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? ZenPalette.gold : Color.clear, lineWidth: 1.5)
                )
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
