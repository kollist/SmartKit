import Foundation

/// Non-AI summary used when on-device generation isn't available.
///
/// Just trims to the longest prefix of whole sentences that fits `maxLength`. It won't be
/// as good as a model-written summary, but it degrades the feature instead of breaking it.
enum FallbackSummarizer {
    static func summarize(_ text: String, maxLength: Int = 240) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count > maxLength else { return trimmed }

        var result = ""
        for rawSentence in trimmed.split(separator: ".", omittingEmptySubsequences: true) {
            let sentence = String(rawSentence).trimmingCharacters(in: .whitespacesAndNewlines)
            guard sentence.isEmpty == false else { continue }
            let candidate = result.isEmpty ? "\(sentence)." : "\(result) \(sentence)."
            guard candidate.count <= maxLength else { break }
            result = candidate
        }

        if result.isEmpty {
            let cutoff = trimmed.index(trimmed.startIndex, offsetBy: maxLength, limitedBy: trimmed.endIndex) ?? trimmed.endIndex
            result = trimmed[..<cutoff] + "…"
        }
        return result
    }
}
