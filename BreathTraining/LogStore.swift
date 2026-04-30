import Foundation

final class LogStore: ObservableObject {
    @Published private(set) var logs: [TrainingLog] = []

    private let fileURL: URL

    init() {
        let folder = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let appFolder = folder.appendingPathComponent("BreathTraining", isDirectory: true)
        try? FileManager.default.createDirectory(at: appFolder, withIntermediateDirectories: true)
        self.fileURL = appFolder.appendingPathComponent("training_logs.json")
        load()
    }

    func add(_ log: TrainingLog) {
        logs.insert(log, at: 0)
        save()
    }

    func delete(log: TrainingLog) {
        logs.removeAll { $0.id == log.id }
        save()
    }

    func deleteAll() {
        logs.removeAll()
        save()
    }

    func logs(on date: Date) -> [TrainingLog] {
        let calendar = Calendar.current
        return logs.filter { calendar.isDate($0.startDate, inSameDayAs: date) }
    }

    func hasLogs(on date: Date) -> Bool {
        let calendar = Calendar.current
        return logs.contains { calendar.isDate($0.startDate, inSameDayAs: date) }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let loaded = try? JSONDecoder().decode([TrainingLog].self, from: data) else {
            logs = []
            return
        }
        logs = loaded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(logs) else { return }
        try? data.write(to: fileURL, options: [.atomic])
    }
}
