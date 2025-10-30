import Foundation
import Combine

final class MatchesStore: ObservableObject {
    @Published var matches: [Match] = []

    init() { load() }

    func load() {
        matches = loadJSON("matches.json") ?? []
        print("Matches loaded: \(matches.count)")
    }

    func toggleFavorite(_ match: Match) {
        if let idx = matches.firstIndex(where: { $0.id == match.id }) {
            matches[idx].favorite = !(matches[idx].favorite ?? false)
        }
    }
}

final class POIStore: ObservableObject {
    @Published var pois: [POI] = []

    init() { load() }

    func load() {
        pois = loadJSON("pois.json") ?? []
        if pois.isEmpty {
            pois = demoPOIs()
            print("POIs loaded demo: \(pois.count)")
        }
    }

    func byCity(_ city: String?) -> [POI] {
        guard let c = city?.lowercased(), !c.isEmpty else { return pois }
        return pois.filter { $0.city.lowercased().contains(c) }
    }
}

private extension POIStore {
    func demoPOIs() -> [POI] {
        return [
            .init(id: "poi-templo-mayor", name: "Templo Mayor", category: .landmark, city: "Ciudad de México", latitude: 19.4351, longitude: -99.1310, priceRange: "$",  hours: "09:00-17:00", tags: ["centro","arqueología"]),
            .init(id: "poi-museo-nal",    name: "Museo Nacional de Antropología", category: .museum,  city: "Ciudad de México", latitude: 19.4260, longitude: -99.1860, priceRange: "$$", hours: "09:00-18:00", tags: ["imperdible"]),
            .init(id: "poi-tacos",        name: "Taquería El Ídolo", category: .food,     city: "Ciudad de México", latitude: 19.4270, longitude: -99.1670, priceRange: "$",  hours: "13:00-01:00", tags: ["tacos","rápido"]),
            .init(id: "poi-bar",          name: "La Mundialista",    category: .bar,      city: "Ciudad de México", latitude: 19.4205, longitude: -99.1630, priceRange: "$$", hours: "17:00-02:00", tags: ["pantallas"]),
            // Casas de cambio
            .init(id: "poi-cambio-1",    name: "Casa de Cambio Reforma", category: .exchange, city: "Ciudad de México", latitude: 19.4280, longitude: -99.1675, priceRange: nil, hours: "09:00-19:00", tags: ["dólares","euros"]),
            .init(id: "poi-cambio-2",    name: "Money Exchange Centro", category: .exchange, city: "Ciudad de México", latitude: 19.4330, longitude: -99.1330, priceRange: nil, hours: "10:00-18:00", tags: ["mejor tasa"]),
            .init(id: "poi-cambio-3",    name: "Cambio Express Insurgentes", category: .exchange, city: "Ciudad de México", latitude: 19.4190, longitude: -99.1678, priceRange: nil, hours: "09:30-19:30", tags: ["rápido"]),
            // Hoteles CDMX
            .init(id: "poi-hotel-1",     name: "Hotel Azteca Centro", category: .hotel, city: "Ciudad de México", latitude: 19.4310, longitude: -99.1400, priceRange: "$$$", hours: "24h", tags: ["4 estrellas","wifi"]),
            .init(id: "poi-hotel-2",     name: "CDMX Suites", category: .hotel, city: "Ciudad de México", latitude: 19.4255, longitude: -99.1605, priceRange: "$$", hours: "24h", tags: ["económico","céntrico"]),
            .init(id: "poi-hotel-3",     name: "Reforma Palace", category: .hotel, city: "Ciudad de México", latitude: 19.4278, longitude: -99.1635, priceRange: "$$$$", hours: "24h", tags: ["lujo","spa"]),
            .init(id: "poi-hotel-4",     name: "Zócalo Inn", category: .hotel, city: "Ciudad de México", latitude: 19.4326, longitude: -99.1332, priceRange: "$$", hours: "24h", tags: ["histórico","vista"])
        ]
    }
}

// Utilidad:
func loadJSON<T: Decodable>(_ filename: String) -> T? {
    // Split filename into name and extension if provided like "matches.json"
    let urlFromString = URL(fileURLWithPath: filename)
    let resourceName = urlFromString.deletingPathExtension().lastPathComponent
    let ext = urlFromString.pathExtension.isEmpty ? nil : urlFromString.pathExtension

    // Try root of bundle first
    var resolvedURL: URL? = Bundle.main.url(forResource: resourceName, withExtension: ext)

    // If not found, try a common folder reference name used in projects: "Bundle/"
    if resolvedURL == nil {
        resolvedURL = Bundle.main.url(forResource: resourceName, withExtension: ext, subdirectory: "Bundle")
    }

    // As a fallback, if we have an extension, try to pick the first resource with that extension
    if resolvedURL == nil, let ext = ext {
        resolvedURL = Bundle.main.urls(forResourcesWithExtension: ext, subdirectory: nil)?.first
    }

    guard let url = resolvedURL else {
        print("JSON load error: could not find resource \(filename) in main bundle (tried root and 'Bundle/' subdirectory)")
        return nil
    }

    do {
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode(T.self, from: data)
        print("JSON loaded OK: \(url.lastPathComponent) (\(data.count) bytes)")
        return decoded
    } catch {
        print("JSON load error \(filename): \(error)")
        return nil
    }
}
