# DopaSE Diagnostics 1.2 — iOS приложение для iPhone SE 2020

**Исходный код настоящего SwiftUI iOS-приложения**, с включённым проектом Xcode, схемой запуска, тестами и GitHub Actions workflow. Создано для диагностики совместимости iPhone SE 2020 (`iPhone12,8`, A13) с Dopamine.

**Важное ограничение:** это **не джейлбрейк**, приложение не содержит рабочей цепочки эксплойтов и **не сможет выполнить джейлбрейк** на iOS 26.1 `23B85`. В текущих официальных метаданных Dopamine эта сборка не поддерживается. Это исследовательское приложение третьей стороны.

## Что сделано

- Интерфейс SwiftUI на русском языке, iOS 16.0+.
- Получение модели iPhone, версии iOS, номера сборки и версии ядра через штатные API только для чтения.
- Офлайн-правила в `Resources/compatibility.json`, отличающие финальную 26.1 `23B85` от трёх поддерживаемых ранних beta-сборок.
- Повторная диагностика, объяснение статуса и системная функция поделиться текстовым отчётом.
- Готовый проект **`DopaSEDiagnostics/DopaSEDiagnostics.xcodeproj`**. XcodeGen **не обязателен**.
- `scripts/build_ios.sh` и `.github/workflows/se2020-diagnostics.yml`: компиляция на macOS и упаковка **неподписанного** IPA.
- Отдельные тесты на Swift и Python + тест целостности Xcode-проекта.

## Как получить IPA

Смотри **`START_HERE_RU.md`**: вариант через GitHub Actions (в том числе с Windows) либо Xcode на Mac.

**Принципиальная оговорка:** этот ZIP содержит исходники и проект Xcode, **не скомпилированный `.ipa`**. В текущей среде нет Xcode/iOS SDK; компиляция и проверка на физическом iPhone не проводились. Самостоятельная сборка в GitHub Actions создаёт неподписанный IPA, который потребует корректной подписи для установки.

## Дерево проекта

- `DopaSEDiagnostics/Sources/` — SwiftUI и офлайн-механизм проверки.
- `DopaSEDiagnostics/Resources/` — декларативная матрица совместимости.
- `DopaSEDiagnostics/DopaSEDiagnostics.xcodeproj/` — подготовленный проект и shared scheme.
- `DopaSEDiagnostics/project.yml` — дополнительная спецификация для XcodeGen (при необходимости).
- `tests/` и `scripts/test_swift_core.sh` — тесты.
- `scripts/build_ios.sh` — сборка unsigned IPA на macOS.
- `.github/workflows/` — автоматическая сборка на GitHub.
- `scripts/copy_into_fork.sh` — копирование диагностического проекта в существующий форк Dopamine, **без модификации эксплойтов**.
- `ROADMAP.md` — проверенные факты и ограничения.

## Проверенные первоисточники (12 ноября 2026)

- Официальный репозиторий: https://github.com/opa334/Dopamine
- Релизы: https://github.com/opa334/Dopamine/releases
- PPL-механизм `momentarius`: https://github.com/opa334/Dopamine/blob/3.x/Application/Dopamine/Exploits/momentarius/Info.plist
- Руководство: https://ios.cfw.guide/installing-dopamine/

Код данного самостоятельного приложения распространяется на условиях MIT (файл `LICENSE`). Исходники Dopamine сюда не включены.
