#if canImport(FoundationModels)
import FoundationModels

/// Guided-generation schema SmartTagView asks the model to fill in. Internal -- callers get
/// results back as the plain `SmartTagGroup` type, not these FoundationModels-backed ones.
@available(iOS 26, macOS 26, visionOS 26, *)
@Generable
struct CategorizedItems {
    @Guide(description: "Groups of related items, organized by category. Every item from the input list must appear in exactly one group, copied exactly as given.")
    var groups: [ItemGroup]
}

@available(iOS 26, macOS 26, visionOS 26, *)
@Generable
struct ItemGroup {
    @Guide(description: "A short, human-readable category name, e.g. 'Groceries' or 'Work'.")
    var category: String
    @Guide(description: "The items belonging to this category, copied exactly from the input.")
    var items: [String]
}
#endif
