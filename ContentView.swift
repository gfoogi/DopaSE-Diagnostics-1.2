import SwiftUI

struct ContentView: View {
    @State private var device = DeviceProfile.current()
    private let manifest = CompatibilityManifest.load()

    private var result: CompatibilityResult {
        CompatibilityResult.evaluate(device, manifest: manifest)
    }

    private var report: String {
        [
            "DopaSE Diagnostics — локальный отчёт",
            "Создан: \(Date().formatted(date: .abbreviated, time: .shortened))",
            "Сведения о таблице: \(manifest?.researchDate ?? "нет данных")",
            "Модель: \(device.modelIdentifier)",
            "iOS: \(device.systemVersion)",
            "Номер сборки: \(device.buildNumber)",
            "Версия ядра: \(device.kernelRelease)",
            "Симулятор: \(device.isSimulator ? "да" : "нет")",
            "Совместимость: \(result.state.rawValue)",
            "Пояснение: \(result.explanation)",
            "Проверено офлайн. Приложение не изменяет iOS и не выполняет джейлбрейк."
        ].joined(separator: "\n")
    }

    private var statusColor: Color {
        switch result.state {
        case .supported: return .green
        case .unsupported: return .red
        case .unknown: return .orange
        case .otherDevice: return .secondary
        }
    }

    private var statusIcon: String {
        switch result.state {
        case .supported: return "checkmark.shield.fill"
        case .unsupported: return "xmark.shield.fill"
        case .unknown: return "questionmark.shield.fill"
        case .otherDevice: return "iphone.gen3"
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(alignment: .top, spacing: 14) {
                        Image(systemName: statusIcon)
                            .font(.system(size: 32, weight: .medium))
                            .foregroundStyle(statusColor)
                            .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 7) {
                            Text(result.state.rawValue)
                                .font(.title3.bold())
                            Text(result.explanation)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 10)
                    .accessibilityElement(children: .combine)
                } header: {
                    Text("Совместимость с Dopamine")
                } footer: {
                    Text("Оценка основана на сохранённых официальных метаданных, а не на попытке джейлбрейка.")
                }

                Section("Мой iPhone") {
                    LabeledContent("Модель", value: device.modelIdentifier)
                    LabeledContent("iOS", value: device.systemVersion)
                    LabeledContent("Сборка", value: device.buildNumber)
                    LabeledContent("Ядро", value: device.kernelRelease)
                    LabeledContent("Целевой процессор", value: manifest?.targetChip ?? "A13 Bionic")
                }

                Section("Инструменты") {
                    Button {
                        device = DeviceProfile.current()
                    } label: {
                        Label("Обновить диагностику", systemImage: "arrow.clockwise")
                    }
                    ShareLink(item: report) {
                        Label("Экспортировать отчёт", systemImage: "square.and.arrow.up")
                    }
                }

                Section("Исходные данные") {
                    LabeledContent("Дата проверки данных", value: manifest?.researchDate ?? "неизвестна")
                    Link(destination: URL(string: "https://github.com/opa334/Dopamine")!) {
                        Label("Официальный проект Dopamine", systemImage: "arrow.up.right.square")
                    }
                    Link(destination: URL(string: "https://github.com/opa334/Dopamine/blob/3.x/Application/Dopamine/Exploits/momentarius/Info.plist")!) {
                        Label("Список поддерживаемых сборок", systemImage: "doc.text")
                    }
                }

                Section("Ограничения") {
                    Text("DopaSE Diagnostics — самостоятельная исследовательская утилита, не связанная с разработчиками Dopamine. Она не содержит эксплойтов, не меняет систему и не устанавливает джейлбрейк.")
                    Text("Статусы могут устареть после новых релизов. Проверяй официальные источники.")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("DopaSE")
        }
    }
}
