import Foundation
import VV00PCore

enum DayBriefError: Error {
    case missingKey
    case requestFailed(Int)
    case unreadable
}

enum TokenFactoryKey {
    static let defaultBase = "https://api.tokenfactory.nebius.com/v1"
    static let defaultModel = "nvidia/Nemotron-3_5-Lightning"

    struct Config {
        var key: String
        var baseURL: String
        var model: String
    }

    static func load() -> Config? {
        guard let url = Bundle.main.url(forResource: "TokenFactory", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any],
              let key = plist["APIKey"] as? String else { return nil }
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count > 20, !trimmed.contains("REPLACE") else { return nil }
        let base = (plist["BaseURL"] as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let model = (plist["Model"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
        return Config(
            key: trimmed,
            baseURL: (base?.isEmpty == false ? base! : defaultBase),
            model: (model?.isEmpty == false ? model! : defaultModel)
        )
    }
}

/// One short completion on Nebius Token Factory.
/// Model: nvidia/Nemotron-3_5-Lightning. Thinking stays off so the JSON is visible.
enum DayBriefClient {
    static var model: String { TokenFactoryKey.load()?.model ?? TokenFactoryKey.defaultModel }

    static func fetch(
        profile: DogProfile,
        today: PeriodTotals,
        yesterday: PeriodTotals,
        week: PeriodTotals,
        dayLabel: String,
        kind: DayBrief.Kind,
        strain: Double,
        yesterdayStrain: Double,
        averageSpeed: String
    ) async throws -> DayBrief.Note {
        guard let config = TokenFactoryKey.load() else { throw DayBriefError.missingKey }
        guard let url = URL(string: "\(config.baseURL)/chat/completions") else { throw DayBriefError.unreadable }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 45
        request.setValue("Bearer \(config.key)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "model": config.model,
            "temperature": 0.3,
            "max_tokens": 500,
            "chat_template_kwargs": ["enable_thinking": false],
            "messages": [
                ["role": "system", "content": DayBrief.systemPrompt(for: kind)],
                ["role": "user", "content": DayBrief.userPrompt(
                    profile: profile,
                    today: today,
                    yesterday: yesterday,
                    week: week,
                    dayLabel: dayLabel,
                    kind: kind,
                    strain: strain,
                    yesterdayStrain: yesterdayStrain,
                    averageSpeed: averageSpeed
                )],
            ],
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, response) = try await URLSession.shared.data(for: request)
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard (200...299).contains(status) else { throw DayBriefError.requestFailed(status) }
        guard let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = root["choices"] as? [[String: Any]],
              let message = choices.first?["message"] as? [String: Any],
              let content = message["content"] as? String,
              let note = DayBrief.parse(content) else {
            throw DayBriefError.unreadable
        }
        return note
    }
}

enum DayBriefCache {
    private static let storageKey = "vv00p.dayBrief"

    struct Entry: Codable {
        var day: String
        var kind: String
        var note: DayBrief.Note
    }

    static func dayString(for date: Date = Date()) -> String {
        let parts = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", parts.year ?? 0, parts.month ?? 0, parts.day ?? 0)
    }

    static func load(day: String, kind: String) -> DayBrief.Note? {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let entry = try? JSONDecoder().decode(Entry.self, from: data),
              entry.day == day,
              entry.kind == kind else { return nil }
        return entry.note
    }

    static func save(_ note: DayBrief.Note, day: String, kind: String) {
        let entry = Entry(day: day, kind: kind, note: note)
        guard let data = try? JSONEncoder().encode(entry) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
