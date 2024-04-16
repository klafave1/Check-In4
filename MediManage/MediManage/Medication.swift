import Foundation

class Medication: Codable {
    var name: String
    var dosage: String
    var timeOfDay: Date
    var selectedDaysOfWeek: [DayOfWeek]

    init(name: String, dosage: String, timeOfDay: Date, selectedDaysOfWeek: [DayOfWeek]) {
        self.name = name
        self.dosage = dosage
        self.timeOfDay = timeOfDay
        self.selectedDaysOfWeek = selectedDaysOfWeek
    }

    static func ==(lhs: Medication, rhs: Medication) -> Bool {
        return lhs.name == rhs.name && lhs.dosage == rhs.dosage
    }

    // MARK: - Codable Conformance

    enum CodingKeys: String, CodingKey {
        case name, dosage, timeOfDay, selectedDaysOfWeek
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        dosage = try container.decode(String.self, forKey: .dosage)
        timeOfDay = try container.decodeIfPresent(Date.self, forKey: .timeOfDay) ?? Date()

        if let rawDays = try container.decodeIfPresent([String].self, forKey: .selectedDaysOfWeek) {
            selectedDaysOfWeek = rawDays.compactMap { DayOfWeek(rawValue: $0) }
        } else {
            selectedDaysOfWeek = []
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(dosage, forKey: .dosage)
        try container.encodeIfPresent(timeOfDay, forKey: .timeOfDay)

        let rawDays = selectedDaysOfWeek.map { $0.rawValue }
        try container.encode(rawDays, forKey: .selectedDaysOfWeek)
    }
}

enum DayOfWeek: String, CaseIterable {
    case sunday, monday, tuesday, wednesday, thursday, friday, saturday
}

