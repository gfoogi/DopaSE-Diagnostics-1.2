import Foundation

struct VersionRange: Decodable {
    let min: String
    let max: String
}

struct CompatibilityManifest: Decodable {
    let researchDate: String
    let targetMachine: String
    let targetName: String
    let targetChip: String
    let explicitlySupportedBuilds: [String]
    let explicitlyUnsupportedBuilds: [String]
    let supportedVersionRanges: [VersionRange]
    let sources: [String]
    let notice: String

    static func load() -> CompatibilityManifest? {
        guard let url = Bundle.main.url(forResource: "compatibility", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(CompatibilityManifest.self, from: data)
    }
}

enum CompatibilityState: String {
    case supported = "В официальном диапазоне"
    case unsupported = "Не поддерживается"
    case unknown = "Поддержка не подтверждена"
    case otherDevice = "Другое устройство"
}

struct CompatibilityResult {
    let state: CompatibilityState
    let explanation: String

    static func evaluate(_ profile: DeviceProfile, manifest: CompatibilityManifest?) -> CompatibilityResult {
        guard let manifest else {
            return .init(state: .unknown, explanation: "Не удалось загрузить локальную таблицу совместимости. Данные о поддержке недоступны.")
        }
        if profile.isSimulator {
            return .init(state: .otherDevice, explanation: "Симулятор не позволяет проверить совместимость настоящего устройства.")
        }
        guard profile.modelIdentifier == manifest.targetMachine else {
            return .init(state: .otherDevice, explanation: "Данная таблица проверяет только iPhone SE 2020 (iPhone12,8, A13).")
        }
        // This explicitly blocks the user's final build regardless of spoofed OS version.
        if manifest.explicitlyUnsupportedBuilds.contains(profile.buildNumber) {
            return .init(state: .unsupported, explanation: "Для финальной iOS 26.1 (23B85) в опубликованном Dopamine 3.x нет подтверждённой поддержки. Это приложение не пытается запускать эксплойты.")
        }
        // Listed beta exceptions belong to 26.1 only, never to an arbitrary OS version.
        if manifest.explicitlySupportedBuilds.contains(profile.buildNumber) {
            guard profile.systemVersion == "26.1" else {
                return .init(state: .unknown, explanation: "Номер сборки и версия iOS противоречат друг другу; статус нельзя подтвердить.")
            }
            return .init(state: .supported, explanation: "Сборка входит в список исключений для ранних бета-версий iOS 26.1. Это не гарантия успешного джейлбрейка.")
        }
        if manifest.supportedVersionRanges.contains(where: { inRange(profile.systemVersion, from: $0.min, through: $0.max) }) {
            return .init(state: .supported, explanation: "Версия iOS входит в опубликованный диапазон поддержки A13. Фактический статус проверяй по официальным релизам.")
        }
        return .init(state: .unknown, explanation: "Для этой комбинации модели, версии и сборки подтверждённой поддержки в локальной таблице нет.")
    }

    static func inRange(_ version: String, from lower: String, through upper: String) -> Bool {
        guard let value = parts(version), let low = parts(lower), let high = parts(upper) else { return false }
        return compare(value, low) >= 0 && compare(value, high) <= 0
    }

    private static func parts(_ value: String) -> [Int]? {
        let parts = value.split(separator: ".", omittingEmptySubsequences: false)
        guard !parts.isEmpty, parts.count <= 4 else { return nil }
        let numbers = parts.compactMap { component -> Int? in
            guard !component.isEmpty, component.allSatisfy({ $0.isASCII && $0.isNumber }) else { return nil }
            return Int(component)
        }
        return numbers.count == parts.count ? numbers : nil
    }

    private static func compare(_ a: [Int], _ b: [Int]) -> Int {
        for index in 0..<max(a.count, b.count) {
            let lhs = index < a.count ? a[index] : 0
            let rhs = index < b.count ? b[index] : 0
            if lhs != rhs { return lhs < rhs ? -1 : 1 }
        }
        return 0
    }
}
