import Foundation
import CoreLocation
import Combine

struct Match: Identifiable, Codable {
    let id: String
    let dateISO: String
    let city: String
    let venueName: String
    let teams: [String]
    let stage: String
    var favorite: Bool? = false

    var date: Date {
        ISO8601DateFormatter().date(from: dateISO) ?? .now
    }
}

struct POI: Identifiable, Codable {
    enum Category: String, Codable { case stadium, food, bar, museum, landmark, hotel, exchange }
    let id: String
    let name: String
    let category: Category
    let city: String
    let latitude: Double
    let longitude: Double
    let priceRange: String?
    let hours: String?
    let tags: [String]?
}

struct ItineraryBlock: Identifiable, Codable {
    var id: UUID = UUID()
    let startISO: String
    let endISO: String
    let title: String
    let poiId: String?
}

struct Itinerary: Identifiable, Codable {
    var id: UUID = UUID()
    let dateISO: String
    var blocks: [ItineraryBlock]
    var notes: String?
}

final class UserPrefs: ObservableObject {
    @Published var budgetPerDay: Int = 800
    @Published var diets: [String] = [] // ["vegan","gluten-free"]
    @Published var nightlifeLevel: Int = 2 // 0-3
    @Published var favTeams: [String] = []
    @Published var currentCity: String? = nil
}

