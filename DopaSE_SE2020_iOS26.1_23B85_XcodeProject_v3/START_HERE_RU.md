# DopaSE Diagnostics 1.2 — как запустить приложение на iPhone

## Сначала о возможностях

Приложение показывает модель, версию iOS, номер сборки, выпуск ядра, офлайн-статус Dopamine и позволяет поделиться отчётом. **Это диагностическое приложение, не готовый джейлбрейк.** На финальной iOS 26.1 (23B85) оно покажет «Не поддерживается».

## Windows / Linux — собрать в GitHub Actions

1. Распакуй архив и загрузи **всё его содержимое** в корень нового репозитория GitHub. Обязательно сохрани скрытую папку `.github` и файл `DopaSEDiagnostics/DopaSEDiagnostics.xcodeproj/project.pbxproj`. При загрузке через веб-интерфейс GitHub нужно следить, чтобы структура каталогов не изменилась.
2. В GitHub открой вкладку **Actions**, workflow **DopaSE — build unsigned iPhone IPA** и выбери **Run workflow**. Если Actions отключены, включи их в настройках репозитория.
3. После успешного запуска открой его **Artifacts** и скачай `DopaSE-iPhone-unsigned-IPA`.
4. Внутри будет `DopaSEDiagnostics-unsigned.ipa` — **настоящий скомпилированный, но неподписанный** файл. Чтобы установить его на физический iPhone, он должен быть подписан с использованием подходящего Apple provisioning profile и сертификата для твоего устройства.

GitHub Actions самостоятельно не подпишет приложение твоей подписью. Если workflow не прошёл, открой логи шага `Compile iOS app and package unsigned IPA` и проверь ошибку компилятора.

## Mac — открыть и установить через Xcode

1. Открой `DopaSEDiagnostics/DopaSEDiagnostics.xcodeproj` в Xcode.
2. В настройках проекта → `Signing & Capabilities` выбери свою Apple development team (можно использовать бесплатную персональную, если доступна) и при необходимости измени `Bundle Identifier` на уникальный.
3. Подключи собственный iPhone, при необходимости включи Apple Developer Mode, выбери его как целевое устройство и нажми **Run**.

Для сборки **неподписанного** IPA без запуска на телефоне:

```bash
bash scripts/test_swift_core.sh
bash scripts/build_ios.sh
```

IPA появится в `artifacts/DopaSEDiagnostics-unsigned.ipa`.

## Проверка проекта без Xcode

```bash
python3 -m unittest discover -s tests -v
bash scripts/test_swift_core.sh # если установлен Swift 6
python3 tools/check_compatibility.py --model iPhone12,8 --ios 26.1 --build 23B85
```

## Что означают ограничения

Описанный путь компилирует и позволяет установить приложение **только после законной подписи**. Он не даёт поддержку джейлбрейка для 23B85 и не предоставляет обходов блокировок или активации. Если в будущем официальная поддержка изменится, локальный файл `compatibility.json` придётся обновить после проверки первоисточников.
