import SwiftUI

#if canImport(FoundationModels)
import FoundationModels
#endif

/// Drops in wherever you need a list of items auto-sorted into categories. Uses guided
/// generation (`@Generable`) so the model's output is a structured group list, not text to
/// parse. Falls back to a single ungrouped bucket on devices/OS versions/regions where
/// Foundation Models isn't available.
public struct SmartTagView: View {
    private let items: [String]

    public init(items: [String]) {
        self.items = items
    }

    @State private var phase: Phase = .idle

    private enum Phase: Equatable {
        case idle
        case loading
        case finished([SmartTagGroup], usedFallback: Bool)
    }

    public var body: some View {
        Group {
            switch phase {
            case .idle, .loading:
                ProgressView("Categorizing…")
                    .frame(maxWidth: .infinity, alignment: .center)
            case .finished(let groups, let usedFallback):
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(groups) { group in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(group.category)
                                .font(.headline)
                            ForEach(group.items, id: \.self) { item in
                                Text(item)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    if usedFallback {
                        Label("Smart categorization unavailable — showing items as-is", systemImage: "sparkles.slash")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .animation(.default, value: phase)
        .task(id: items) {
            await categorize()
        }
    }

    @MainActor
    private func categorize() async {
        phase = .loading

        guard items.isEmpty == false else {
            phase = .finished([], usedFallback: false)
            return
        }

        guard ModelAvailability.current().isAvailable else {
            phase = .finished(FallbackTagger.categorize(items), usedFallback: true)
            return
        }

        #if canImport(FoundationModels)
        if #available(iOS 26, macOS 26, visionOS 26, *) {
            await generateOnDeviceTags()
            return
        }
        #endif

        phase = .finished(FallbackTagger.categorize(items), usedFallback: true)
    }

    #if canImport(FoundationModels)
    @available(iOS 26, macOS 26, visionOS 26, *)
    @MainActor
    private func generateOnDeviceTags() async {
        let session = LanguageModelSession(
            instructions: "You sort short lists of items into a small number of clear, mutually exclusive categories."
        )

        do {
            let response = try await session.respond(
                to: "Categorize these items:\n\(items.joined(separator: "\n"))",
                generating: CategorizedItems.self
            )
            let groups = response.content.groups.map {
                SmartTagGroup(category: $0.category, items: $0.items)
            }
            phase = .finished(groups, usedFallback: false)
        } catch {
            phase = .finished(FallbackTagger.categorize(items), usedFallback: true)
        }
    }
    #endif
}
