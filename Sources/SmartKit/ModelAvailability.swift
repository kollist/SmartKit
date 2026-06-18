import Foundation

#if canImport(FoundationModels)
import FoundationModels
#endif

/// Whether SmartKit's on-device AI features can run right now.
public enum SmartKitAvailability: Sendable, Equatable {
    case available
    case unavailable(SmartKitUnavailableReason)

    public var isAvailable: Bool { self == .available }
}

/// Why on-device generation isn't usable, in terms a UI can act on.
public enum SmartKitUnavailableReason: Sendable, Equatable {
    /// The app was built against (or is running on) an OS release that predates
    /// Foundation Models support entirely.
    case osTooOld
    /// The hardware doesn't meet the Apple Intelligence requirements.
    case deviceNotEligible
    /// Apple Intelligence is off. This is also where Apple folds region support:
    /// there's no separate "unsupported region" signal -- a device in an unsupported
    /// region simply never gets Apple Intelligence enabled.
    case notEnabled
    /// Apple Intelligence is enabled but the model assets are still downloading.
    case modelNotReady
    /// Apple Intelligence is available, but not for the user's current language/locale.
    case unsupportedLanguage

    /// A short, user-facing-safe explanation, useful for logging or debug UI.
    public var debugDescription: String {
        switch self {
        case .osTooOld:
            return "This OS release doesn't support Foundation Models (needs iOS/macOS/visionOS 26+)."
        case .deviceNotEligible:
            return "This device doesn't meet the Apple Intelligence hardware requirements."
        case .notEnabled:
            return "Apple Intelligence isn't enabled (off in Settings, region not supported yet, or restricted)."
        case .modelNotReady:
            return "The on-device model is still downloading."
        case .unsupportedLanguage:
            return "The current language/region isn't supported by the on-device model yet."
        }
    }
}

/// Single place SmartKit's views ask "can I use the on-device model right now?"
///
/// This is the part every app shipping a Foundation Models feature has to solve on its own:
/// the framework doesn't exist pre-iOS 26 (so even importing/calling it has to be guarded),
/// hardware eligibility varies, Apple Intelligence can be off (which is also how region
/// restrictions surface -- there's no dedicated "wrong region" API), the model asset can
/// still be downloading, and a supported device can still lack support for the user's
/// language. `current()` collapses all of that into one value views can switch on.
public enum ModelAvailability {
    public static func current() -> SmartKitAvailability {
        #if canImport(FoundationModels)
        guard #available(iOS 26, macOS 26, visionOS 26, *) else {
            return .unavailable(.osTooOld)
        }
        return currentOnSupportedOS()
        #else
        return .unavailable(.osTooOld)
        #endif
    }

    #if canImport(FoundationModels)
    @available(iOS 26, macOS 26, visionOS 26, *)
    private static func currentOnSupportedOS() -> SmartKitAvailability {
        let model = SystemLanguageModel.default

        if case .unavailable(let reason) = model.availability {
            switch reason {
            case .deviceNotEligible:
                return .unavailable(.deviceNotEligible)
            case .modelNotReady:
                return .unavailable(.modelNotReady)
            case .appleIntelligenceNotEnabled:
                return .unavailable(.notEnabled)
            @unknown default:
                return .unavailable(.notEnabled)
            }
        }

        guard model.supportsLocale(Locale.current) else {
            return .unavailable(.unsupportedLanguage)
        }

        return .available
    }
    #endif
}
