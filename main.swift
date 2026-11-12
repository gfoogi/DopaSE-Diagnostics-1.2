import Foundation

func verify(_ condition: @autoclosure () -> Bool, _ label: String) {
    guard condition() else {
        fputs("FAILED: \(label)\n", stderr)
        exit(1)
    }
    print("OK: \(label)")
}

let manifestURL = URL(fileURLWithPath: CommandLine.arguments[1])
let manifest = try JSONDecoder().decode(CompatibilityManifest.self, from: Data(contentsOf: manifestURL))

func profile(_ version: String, _ build: String, model: String = "iPhone12,8", sim: Bool = false) -> DeviceProfile {
    DeviceProfile(modelIdentifier: model, systemVersion: version, buildNumber: build,
                  kernelRelease: "test", isSimulator: sim)
}

verify(CompatibilityResult.evaluate(profile("26.1", "23B85"), manifest: manifest).state == .unsupported, "23B85 blocked")
verify(CompatibilityResult.evaluate(profile("26.1", "23B5044l"), manifest: manifest).state == .supported, "beta 1 known")
verify(CompatibilityResult.evaluate(profile("26.1", "23B5059e"), manifest: manifest).state == .supported, "beta 2 known")
verify(CompatibilityResult.evaluate(profile("26.1", "23B5064e"), manifest: manifest).state == .supported, "beta 3 known")
verify(CompatibilityResult.evaluate(profile("26.0.1", "23A355"), manifest: manifest).state == .supported, "26.0.1 in range")
verify(CompatibilityResult.evaluate(profile("26.2", "23C1"), manifest: manifest).state == .unknown, "26.2 unverified")
verify(CompatibilityResult.evaluate(profile("26.0", "23B5044l"), manifest: manifest).state == .unknown, "beta version conflict")
verify(CompatibilityResult.evaluate(profile("26.1", "23B85", model: "iPhone13,2"), manifest: manifest).state == .otherDevice, "other model")
verify(CompatibilityResult.evaluate(profile("26.1", "23B85", sim: true), manifest: manifest).state == .otherDevice, "simulator")
verify(CompatibilityResult.evaluate(profile("26.1", "23B85"), manifest: nil).state == .unknown, "missing manifest")
verify(CompatibilityResult.inRange("26.0.1", from: "26.0", through: "26.0.1"), "inclusive version range")
verify(!CompatibilityResult.inRange("26.0beta", from: "26.0", through: "26.0.1"), "reject invalid OS version")
print("PASS: 12 Swift core checks")
