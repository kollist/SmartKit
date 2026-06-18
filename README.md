# SmartKit

Drop-in SwiftUI components powered by Apple's [Foundation Models](https://developer.apple.com/documentation/foundationmodels) framework — with automatic, graceful fallback when the current device, OS, or region doesn't support on-device generative AI.

Two small components:

- **`SummaryView(text:)`** — streams an on-device summary of a block of text, with a loading state built in.
- **`SmartTagView(items:)`** — auto-categorizes a list of items using guided generation (`@Generable`).

Both components fall back to a non-AI implementation automatically — no availability checks required at the call site.

## Why this exists

Foundation Models only exists on iOS/macOS/visionOS 26+, only runs on Apple Intelligence–eligible hardware, only works once Apple Intelligence is turned on (which is also how Apple gates region availability — there's no separate "is my region supported" API to check ahead of time), only works once the model assets have finished downloading, and only supports a subset of languages even when everything else lines up. Every app shipping a Foundation Models feature has to handle all of that, or it crashes/misbehaves for a meaningful slice of users. SmartKit's `ModelAvailability` does that work once:

```swift
public enum SmartKitAvailability: Sendable, Equatable {
    case available
    case unavailable(SmartKitUnavailableReason)
}

public enum SmartKitUnavailableReason: Sendable, Equatable {
    case osTooOld            // pre-iOS/macOS/visionOS 26
    case deviceNotEligible   // hardware doesn't support Apple Intelligence
    case notEnabled          // off in Settings, region not supported, or restricted
    case modelNotReady       // assets still downloading
    case unsupportedLanguage // current locale isn't supported yet
}

ModelAvailability.current() // -> SmartKitAvailability
```

`SummaryView` and `SmartTagView` call this internally and switch to a plain, deterministic fallback whenever it's anything but `.available` — so they're safe to use today, on every device, without `#if #available` checks in your own code.

## Installation

### Swift Package Manager

```swift
.package(url: "https://github.com/kollist/SmartKit.git", from: "0.1.0")
```

### CocoaPods

```ruby
pod 'SmartKit', :git => 'https://github.com/kollist/SmartKit.git', :tag => '0.1.0'
```

Minimum platforms: iOS 17, macOS 14 (SPM also supports visionOS 1; the CocoaPods spec sticks to iOS/macOS since CocoaPods' validation doesn't currently have a visionOS simulator). You don't need iOS 26 to adopt the package — you just won't get on-device AI on older OS versions, you'll get the fallback.

## Usage

```swift
import SmartKit

struct ArticleView: View {
    let articleBody: String

    var body: some View {
        SummaryView(text: articleBody)
    }
}
```

```swift
import SmartKit

struct InboxView: View {
    let subjects: [String]

    var body: some View {
        SmartTagView(items: subjects)
    }
}
```

Both views drive themselves off a `.task`, so they regenerate automatically whenever their input changes.

## How the fallback behaves

| Component      | On-device AI                                | Fallback                                                                             |
| --------------- | --------------------------------------------- | --------------------------------------------------------------------------------------- |
| `SummaryView`  | Streamed 2-3 sentence summary                | First whole sentences truncated to ~240 characters                                  |
| `SmartTagView` | Items grouped into model-chosen categories   | A single "All Items" group, with a label noting smart categorization is unavailable |

Both fallbacks are deliberately simple rather than trying to fake intelligence with keyword heuristics — a confidently wrong guess is worse than an honest "this is degraded."

## License

MIT — see [LICENSE](LICENSE).
