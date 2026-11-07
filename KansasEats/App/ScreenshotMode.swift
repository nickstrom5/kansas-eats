import Foundation
import CoreLocation
import UIKit

/// `-screenshot <name>` opens one screen with fixed state for App Store screenshots (scripts/capture-screenshots.sh).
/// Names: home, chicken, bbq, sliders, heritage, honors, oldest, detail, map, saved, about.
// the guide places the shots show, as the bundled data spells them (checked against data/app/places.json)
private let SHOT_HAYS = "Hays House Restaurant", SHOT_COZY = "The Cozy Inn", SHOT_ANNIE = "Chicken Annie's Original"
private let SHOT_JOES = "Joe's Kansas City Bar-B-Que"

enum ScreenshotMode {
    /// Debug builds only: an App Store build ignores the launch argument, so no one can reach seeded screens or fake locations.
    static var name: String? {
        #if DEBUG
        let args = ProcessInfo.processInfo.arguments
        guard let i = args.firstIndex(of: "-screenshot"), i + 1 < args.count else { return nil }
        return args[i + 1]
        #else
        return nil
        #endif
    }
    static var isActive: Bool { name != nil }

    @MainActor
    static func apply(to model: AppModel) {
        guard let name, model.isLoaded else { return }
        model.filters = Filters()
        // downtown Wichita (Douglas and Main), so "nearest" lists have distances without a permission prompt
        model.screenshotLocation = CLLocation(latitude: 37.6866, longitude: -97.3366)
        // by name and town, ignoring case, so a rebuild with a slightly different casing still finds the place; the hand-checked one first
        let pick = { (n: String, town: String?) -> Place? in
            let hits = model.places.filter { $0.name.caseInsensitiveCompare(n) == .orderedSame && (town == nil || $0.city == town) }
            return hits.first(where: \.handChecked) ?? hits.first
        }
        for p in [pick(SHOT_COZY, "Salina"), pick(SHOT_ANNIE, "Pittsburg"), pick(SHOT_HAYS, "Council Grove")]
            .compactMap({ $0 }) where !model.isSaved(p) {
            model.toggleSaved(p)
        }
        let open = { (g: Guide) in model.tab = .guides; model.selectedGuide = g; model.guidesPath = [.guide(g)] }
        switch name {
        case "chicken":
            // Pittsburg, between Chicken Annie's Original and Chicken Mary's and the town
            model.screenshotLocation = CLLocation(latitude: 37.4109, longitude: -94.7049)
            open(.chicken)
        case "bbq":
            // Kansas City, Kansas, by Joe's on West 47th Avenue and Slaps in Strawberry Hill
            model.screenshotLocation = CLLocation(latitude: 39.1141, longitude: -94.6275)
            open(.bbq)
        case "sliders": open(.sliders)
        case "heritage": open(.heritage)
        case "honors": open(.honors)
        case "oldest": open(.oldest)
        case "detail":
            // the Hays House: Kansas's oldest restaurant per Tasting Table, with its 1857 founding year and its note
            open(.heritage)
            if let p = pick(SHOT_HAYS, "Council Grove") ?? model.places.first {
                model.selectedPlace = p; model.guidesPath.append(.place(p))
            }
        case "map": model.tab = .map
        case "saved": model.tab = .saved
        case "about": model.tab = .about
        default: model.tab = .guides; model.selectedGuide = nil
        }
        // iPad shows the place column next to every list, so give each shot a place instead of "Pick a place": a different
        // honored or hand-checked one per shot.
        guard UIDevice.current.userInterfaceIdiom == .pad, model.selectedPlace == nil else { return }
        let place: Place? = switch name {
        case "home": pick(SHOT_HAYS, "Council Grove")
        case "chicken": pick(SHOT_ANNIE, "Pittsburg")
        case "bbq": pick(SHOT_JOES, "Kansas City")
        case "sliders": pick(SHOT_COZY, "Salina")
        case "heritage": pick(SHOT_HAYS, "Council Grove")
        case "map": pick(SHOT_COZY, "Salina")
        case "honors": pick("Drastic Measures", "Shawnee")
        case "oldest": pick(SHOT_HAYS, "Council Grove")
        case "saved": pick(SHOT_COZY, "Salina")
        case "about": nil
        default: pick(SHOT_HAYS, "Council Grove")
        }
        model.selectedPlace = place
    }
}
