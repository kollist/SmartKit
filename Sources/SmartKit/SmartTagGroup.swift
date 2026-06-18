/// A category and the items SmartTagView placed into it.
///
/// Plain Swift, with no dependency on FoundationModels types, so it's usable as view/app
/// state on any OS version regardless of whether on-device generation actually ran.
public struct SmartTagGroup: Identifiable, Equatable, Sendable {
    public let id: String
    public let category: String
    public let items: [String]

    public init(category: String, items: [String]) {
        self.id = category
        self.category = category
        self.items = items
    }
}
