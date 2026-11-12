import Foundation

#if canImport(UIKit)
import UIKit
import Darwin
#endif

/// Only public, read-only OS attributes. Does not require a jailbreak.
struct DeviceProfile {
    let modelIdentifier: String
    let systemVersion: String
    let buildNumber: String
    let kernelRelease: String
    let isSimulator: Bool

    static func current() -> DeviceProfile {
        #if canImport(UIKit)
        #if targetEnvironment(simulator)
        let simulator = true
        let hardware = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"]
            ?? sysctlString("hw.machine")
        #else
        let simulator = false
        let hardware = sysctlString("hw.machine")
        #endif
        return DeviceProfile(
            modelIdentifier: hardware,
            systemVersion: UIDevice.current.systemVersion,
            buildNumber: sysctlString("kern.osversion"),
            kernelRelease: sysctlString("kern.osrelease"),
            isSimulator: simulator
        )
        #else
        return DeviceProfile(
            modelIdentifier: "неизвестно",
            systemVersion: "неизвестно",
            buildNumber: "неизвестно",
            kernelRelease: "неизвестно",
            isSimulator: true
        )
        #endif
    }

    #if canImport(UIKit)
    private static func sysctlString(_ key: String) -> String {
        var size: size_t = 0
        guard sysctlbyname(key, nil, &size, nil, 0) == 0,
              size > 1, size < 4096 else { return "не определено" }
        var bytes = [CChar](repeating: 0, count: Int(size))
        let status = bytes.withUnsafeMutableBufferPointer { buffer in
            sysctlbyname(key, buffer.baseAddress, &size, nil, 0)
        }
        guard status == 0, size > 0 else { return "не определено" }
        return String(cString: bytes)
    }
    #endif
}
