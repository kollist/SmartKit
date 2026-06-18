import Testing
@testable import SmartKit

@Test func availabilityCheckNeverCrashes() {
    _ = ModelAvailability.current()
}

@Test func availableIsTrueOnlyForAvailableCase() {
    #expect(SmartKitAvailability.available.isAvailable)
    #expect(SmartKitAvailability.unavailable(.modelNotReady).isAvailable == false)
}
