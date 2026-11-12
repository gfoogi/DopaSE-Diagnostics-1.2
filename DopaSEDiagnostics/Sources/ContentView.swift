import SwiftUI

// DopaSE Lab is an unprivileged research preview. It never executes a kernel exploit.
private enum LabStatus: String {
    case passed = "ПРОЙДЕНО"
    case blocked = "НЕДОСТУПНО"
    case skipped = "НЕ ЗАПУЩЕНО"

    var tint: Color {
        switch self {
        case .passed: return .green
        case .blocked: return .orange
        case .skipped: return .secondary
        }
    }

    var symbol: String {
        switch self {
        case .passed: return "checkmark.circle.fill"
        case .blocked: return "exclamationmark.shield.fill"
        case .skipped: return "minus.circle"
        }
    }
}

private struct LabStage: Identifiable {
    let id: Int
    let title: String
    let detail: String
    let status: LabStatus
}

private struct LabRun {
    let started: Date
    let profile: DeviceProfile
    let stages: [LabStage]

    static func perform(profile: DeviceProfile, manifest: CompatibilityManifest?) -> LabRun {
        var stages: [LabStage] = []
        let expectedModel = manifest?.targetMachine ?? "iPhone12,8"
        let correctDevice = !profile.isSimulator && profile.modelIdentifier == expectedModel
        let correctBuild = profile.systemVersion == "26.1" && profile.buildNumber == "23B85"

        stages.append(LabStage(
            id: 1,
            title: "Идентификация iPhone",
            detail: "Устройство: \(profile.modelIdentifier). Сверка с iPhone SE 2020 (A13).",
            status: correctDevice ? .passed : .blocked
        ))
        stages.append(LabStage(
            id: 2,
            title: "Проверка версии iOS",
            detail: "Найдена iOS \(profile.systemVersion), сборка \(profile.buildNumber). Цель эксперимента: 26.1 (23B85).",
            status: correctBuild ? .passed : .blocked
        ))
        stages.append(LabStage(
            id: 3,
            title: "Метаданные Dopamine",
            detail: manifest == nil
                ? "Локальный список совместимости отсутствует."
                : "Список загружен. Он не подтверждает поддержку финальной 23B85.",
            status: manifest == nil ? .blocked : .passed
        ))

        // One harmless in-process memory check. This is NOT a kernel vulnerability probe.
        var sample = Data(repeating: 0xA5, count: 4096)
        sample[0] = 0x5A
        let localMemoryOK = sample.count == 4096 && sample[0] == 0x5A && sample[1] == 0xA5
        stages.append(LabStage(
            id: 4,
            title: "Локальный тест памяти",
            detail: "Проверены чтение и изменение 4096 байт памяти собственного приложения. Ядро iOS не затрагивается.",
            status: localMemoryOK ? .passed : .blocked
        ))
        stages.append(LabStage(
            id: 5,
            title: "Доступ к памяти ядра",
            detail: "Для 23B85 нет подтверждённого рабочего механизма. Настоящая эксплуатация не запускается.",
            status: .blocked
        ))
        stages.append(LabStage(
            id: 6,
            title: "Установка джейлбрейка",
            detail: "Пропущено. Запуск bootstrap без подтверждённой цепочки не выполняется.",
            status: .skipped
        ))

        return LabRun(started: Date(), profile: profile, stages: stages)
    }

    var report: String {
        (
            [
                "DopaSE Lab 1.3 — ПРОБНЫЙ ПРОГОН (БЕЗ ЭКСПЛОЙТА)",
                "Время: \(started.formatted(date: .numeric, time: .standard))",
                "Устройство: \(profile.modelIdentifier)",
                "iOS: \(profile.systemVersion) (\(profile.buildNumber))",
                "Ядро: \(profile.kernelRelease)",
                "РЕЗУЛЬТАТ: Джейлбрейк не выполнен; изменения системы не производились.",
                ""
            ] +
            stages.map { "\($0.id). \($0.title) — \($0.status.rawValue)\n\($0.detail)" }
        ).joined(separator: "\n")
    }
}

struct ContentView: View {
    @State private var device = DeviceProfile.current()
    @State private var run: LabRun?
    private let manifest = CompatibilityManifest.load()

    private var compatibility: CompatibilityResult {
        CompatibilityResult.evaluate(device, manifest: manifest)
    }

    private var headerColor: Color { .init(red: 0.30, green: 0.37, blue: 0.95) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    targetCard
                    runCard

                    if let run {
                        resultsCard(run)
                        ShareLink(item: run.report) {
                            Label("Экспортировать результат", systemImage: "square.and.arrow.up")
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(.bordered)
                    }

                    sourcesCard
                }
                .padding(16)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("DopaSE Lab")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                Image(systemName: "atom")
                    .font(.system(size: 40, weight: .light))
                    .foregroundStyle(.white)
                    .frame(width: 66, height: 66)
                    .background(.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 20))
                VStack(alignment: .leading, spacing: 5) {
                    Text("DopaSE Lab")
                        .font(.title.bold())
                    Text("Research Preview 1.3")
                        .font(.subheadline)
                        .opacity(0.8)
                }
                Spacer()
            }
            Text("Пробная последовательность проверок, похожая на интерфейс джейлбрейка Dopamine.")
                .font(.subheadline)
            Label("Не является эксплойтом или джейлбрейком", systemImage: "info.circle.fill")
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 11)
                .padding(.vertical, 7)
                .background(.white.opacity(0.16), in: Capsule())
        }
        .foregroundStyle(.white)
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [headerColor, .init(red: 0.18, green: 0.23, blue: 0.48)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 22)
        )
    }

    private var targetCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Целевое устройство", systemImage: "iphone.gen3")
                .font(.headline)

            HStack {
                Text("Устройство")
                Spacer()
                Text(device.modelIdentifier).foregroundStyle(.secondary)
            }
            HStack {
                Text("iOS")
                Spacer()
                Text("\(device.systemVersion) (\(device.buildNumber))")
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text("Ядро")
                Spacer()
                Text(device.kernelRelease)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Divider()
            HStack(spacing: 9) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                Text(compatibility.state.rawValue)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text("23B85")
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
            }
            Text("Официальный Dopamine не заявляет поддержку этой финальной сборки. Пробный прогон не меняет этот статус.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .labCard()
    }

    private var runCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Лабораторный прогон", systemImage: "bolt.horizontal.circle")
                .font(.headline)
            Text("Запустит реальные безопасные проверки модели, версии и памяти приложения, затем покажет, где эксперимент останавливается.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button {
                device = DeviceProfile.current()
                run = LabRun.perform(profile: device, manifest: manifest)
            } label: {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Запустить пробный прогон")
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 7)
            }
            .buttonStyle(.borderedProminent)
            .tint(headerColor)
            Text("Нет доступа к памяти ядра, обхода защит или установки bootstrap. Безопасно для данных устройства.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .labCard()
    }

    private func resultsCard(_ run: LabRun) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Этапы пробного прогона", systemImage: "list.bullet.rectangle")
                .font(.headline)
            ForEach(run.stages) { stage in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: stage.status.symbol)
                        .foregroundStyle(stage.status.tint)
                        .font(.title3)
                        .frame(width: 23)
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text(stage.title)
                                .font(.subheadline.weight(.semibold))
                            Spacer(minLength: 6)
                        }
                        Text(stage.status.rawValue)
                            .font(.caption2.bold())
                            .foregroundStyle(stage.status.tint)
                        Text(stage.detail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                if stage.id != 6 {
                    Divider().padding(.leading, 35)
                }
            }
            Text("Итог: тесты приложения выполнены, джейлбрейк НЕ выполнен.")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.orange)
        }
        .labCard()
    }

    private var sourcesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Источники и ограничения", systemImage: "book.closed")
                .font(.headline)
            Link("Официальный Dopamine", destination: URL(string: "https://github.com/opa334/Dopamine")!)
            Link("Совместимость momentarius", destination: URL(string: "https://github.com/opa334/Dopamine/blob/3.x/Application/Dopamine/Exploits/momentarius/Info.plist")!)
            Text("Это независимый исследовательский интерфейс DopaSE, не связанный с разработчиками Dopamine. Эксперимент не использует уязвимости ядра.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .labCard()
    }
}

private struct LabCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
    }
}

private extension View {
    func labCard() -> some View { modifier(LabCardModifier()) }
}
