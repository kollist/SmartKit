import Foundation

/// Non-AI categorization used when on-device generation isn't available.
///
/// Deliberately doesn't try to fake intelligence with keyword heuristics -- that tends to be
/// confidently wrong, which is worse than admitting the feature is degraded. It groups
/// everything into a single bucket so the UI still has something useful to render.
enum FallbackTagger {
    static func categorize(_ items: [String]) -> [SmartTagGroup] {
        guard items.isEmpty == false else { return [] }
        return [SmartTagGroup(category: "All Items", items: items)]
    }
}
