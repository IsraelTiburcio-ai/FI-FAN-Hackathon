import SwiftUI

@main
struct FIFANApp: App {
    @StateObject private var matchesStore = MatchesStore()
    @StateObject private var poiStore = POIStore()
    @StateObject private var userPrefs = UserPrefs()
    @State private var showIntro = true
    @State private var animationFinished = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showIntro {
                    IntroImageView(showIntro: $showIntro, animationFinished: $animationFinished)
                        .environmentObject(matchesStore)
                        .environmentObject(poiStore)
                        .environmentObject(userPrefs)
                } else {
                    TabView {
                        HomeView()
                            .environmentObject(matchesStore)
                            .environmentObject(poiStore)
                            .environmentObject(userPrefs)
                            .tabItem { Label("Inicio", systemImage: "house.fill") }

                        MatchesView()
                            .environmentObject(matchesStore)
                            .tabItem { Label("Partidos", systemImage: "soccerball") }

                        TourismView()
                            .environmentObject(poiStore)
                            .tabItem { Label("Turismo", systemImage: "map.fill") }

                        NewsView()
                            .tabItem { Label("News", systemImage: "newspaper.fill") }
                    }
                }
            }
        }
    }
}
