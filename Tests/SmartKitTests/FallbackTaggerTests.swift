import Testing
@testable import SmartKit

@Test func emptyItemsProduceNoGroups() {
    #expect(FallbackTagger.categorize([]).isEmpty)
}

@Test func itemsAreGroupedIntoASingleBucket() {
    let items = ["Milk", "Eggs", "Quarterly Report"]
    let groups = FallbackTagger.categorize(items)
    #expect(groups.count == 1)
    #expect(groups.first?.items == items)
}
