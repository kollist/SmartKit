import SwiftUI

#if canImport(FoundationModels)
import FoundationModels
#endif

/// Drops in wherever you need a quick summary of a block of text. Streams the on-device
/// summary in as it's generated; falls back to a plain truncated summary on devices/OS
/// versions/regions where Foundation Models isn't available.
public struct SummaryView: View {
    private let text: String

    public init(text: String) {
        self.text = text
    }

    @State private var phase: Phase = .idle

    private enum Phase: Equatable {
        case idle
        case generating(partial: String)
        case finished(String, usedFallback: Bool)
    }

    public var body: some View {
        Group {
            switch phase {
            case .idle:
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            case .generating(let partial):
                if partial.isEmpty {
                    ProgressView("Summarizing…")
                } else {
                    Text(partial)
                }
            case .finished(let summary, let usedFallback):
                VStack(alignment: .leading, spacing: 6) {
                    Text(summary)
                    if usedFallback {
                        fallbackBadge
                    }
                }
            }
        }
        .animation(.default, value: phase)
        .task(id: text) {
            await generateSummary()
        }
    }

    private var fallbackBadge: some View {
        Label("Simplified summary — on-device AI unavailable", systemImage: "sparkles.slash")
            .font(.caption)
            .foregroundStyle(.secondary)
    }

    @MainActor
    private func generateSummary() async {
        phase = .idle

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            phase = .finished("", usedFallback: false)
            return
        }

        guard ModelAvailability.current().isAvailable else {
            phase = .finished(FallbackSummarizer.summarize(text), usedFallback: true)
            return
        }

        #if canImport(FoundationModels)
        if #available(iOS 26, macOS 26, visionOS 26, *) {
            await streamOnDeviceSummary()
            return
        }
        #endif

        phase = .finished(FallbackSummarizer.summarize(text), usedFallback: true)
    }

    #if canImport(FoundationModels)
    @available(iOS 26, macOS 26, visionOS 26, *)
    @MainActor
    private func streamOnDeviceSummary() async {
        phase = .generating(partial: "")

        let session = LanguageModelSession(
            instructions: "You write short, accurate summaries. Reply with the summary only, no preamble."
        )

        do {
            let stream = session.streamResponse(
                to: "Summarize the following text in 2-3 sentences:\n\n\(text)"
            )
            var latest = ""
            for try await snapshot in stream {
                latest = snapshot.content
                phase = .generating(partial: latest)
            }
            phase = .finished(latest, usedFallback: false)
        } catch {
            phase = .finished(FallbackSummarizer.summarize(text), usedFallback: true)
        }
    }
    #endif
}
