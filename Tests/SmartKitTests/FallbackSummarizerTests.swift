import Testing
@testable import SmartKit

@Test func shortTextIsReturnedUnchanged() {
    let short = "This is a short sentence."
    #expect(FallbackSummarizer.summarize(short) == short)
}

@Test func longTextIsTruncatedToWholeSentences() {
    let long = Array(repeating: "This is one sentence", count: 30).joined(separator: ". ") + "."
    let result = FallbackSummarizer.summarize(long, maxLength: 100)
    #expect(result.count <= 101)
    #expect(result.hasSuffix(".") || result.hasSuffix("…"))
}

@Test func textWithNoSentenceBoundariesStillTruncates() {
    let long = String(repeating: "a", count: 500)
    let result = FallbackSummarizer.summarize(long, maxLength: 100)
    #expect(result.hasSuffix("…"))
    #expect(result.count <= 101)
}

@Test func emptyTextStaysEmpty() {
    #expect(FallbackSummarizer.summarize("   ") == "")
}
