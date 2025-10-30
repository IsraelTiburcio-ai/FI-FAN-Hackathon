import SwiftUI
import MapKit

struct HomeView: View {
    @EnvironmentObject var matchesStore: MatchesStore
    @EnvironmentObject var poiStore: POIStore
    @EnvironmentObject var userPrefs: UserPrefs
    
    @State private var isAnimating = false
    @State private var showChat = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Lema / encabezado
                    VStack(alignment: .leading, spacing: 6) {
                        Text("FI-FAN")
                            .font(.largeTitle.bold())
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.fifanBlue, .fifanGreen],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        Text("Tu mejor guIA para vivir el Mundial")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Próximo partido - MEJORADO
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Próximo Partido")
                                .font(.title3.bold())
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "Mariposa")
                                .foregroundColor(.fifanGreen)
                                .font(.caption)
                        }
                        .padding(.horizontal)
                        
                        if let next = nextMatch() {
                            NextMatchCard(match: next)
                                .padding(.horizontal)
                        } else {
                            NoMatchCard()
                                .padding(.horizontal)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("¿Quieres matar el tiempo?")
                                .font(.title3.weight(.semibold))
                            Spacer()
                        }
                        
                        CategoryChips(selected: .constant(nil))
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 14) {
                                ForEach(suggestions(), id: \.id) { poi in
                                    SuggestionCard(
                                        poi: poi,
                                        mapsAction: { openInMaps(poi: poi) },
                                        uberAction: { openInUber(poi: poi) }
                                    )
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                    .padding(.horizontal)
                    
                    // NUEVA BURBUJA IA CON EFECTO ARCOÍRIS
                    VStack(spacing: 16) {
                        Text("Planifica tu día con IA")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Button(action: {
                            showChat = true
                        }) {
                            ZStack {
                                // Burbuja principal
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.white, Color(.systemGray6)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 120, height: 120)
                                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                                
                                // Anillo arcoíris giratorio
                                Circle()
                                    .stroke(
                                        AngularGradient(
                                            gradient: Gradient(colors: [
                                                .fifanRed, .orange, .yellow, .fifanGreen,
                                                .fifanBlue, .purple, .fifanRed
                                            ]),
                                            center: .center,
                                            startAngle: .degrees(0),
                                            endAngle: .degrees(360)
                                        ),
                                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                                    )
                                    .frame(width: 140, height: 140)
                                    .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                                
                                // Icono y texto dentro de la burbuja
                                VStack(spacing: 8) {
                                    Image("Mariposa")
                                        .resizable()
                                        .frame(width: 60, height: 60)
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [.fifanBlue, .fifanGreen],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                    
                                    Text("Plan IA")
                                        .font(.caption.weight(.semibold))
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                        .buttonStyle(ScaleButtonStyle())
                        
                        Text("Toca para crear tu itinerario personalizado")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    )
                    .padding(.horizontal)
                    
                    NavigationLink {
                        StandingsView()
                    } label: {
                        HStack {
                            Image(systemName: "table.fill")
                            Text("Posiciones (Fase de grupos)")
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(colors: [.fifanRed.opacity(0.9), .fifanBlue.opacity(0.9)],
                                           startPoint: .leading, endPoint: .trailing)
                        )
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                    
                    // Cambio de divisas
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Cambio de divisas")
                                .font(.title3.weight(.semibold))
                            Spacer()
                        }
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 14) {
                                ForEach(exchangePOIs(), id: \.id) { poi in
                                    SuggestionCard(
                                        poi: poi,
                                        mapsAction: { openInMaps(poi: poi) },
                                        uberAction: { openInUber(poi: poi) }
                                    )
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Hoteles recomendados
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Hoteles recomendados")
                                .font(.title3.weight(.semibold))
                            Spacer()
                        }
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 14) {
                                ForEach(hotelPOIs(), id: \.id) { poi in
                                    SuggestionCard(
                                        poi: poi,
                                        mapsAction: { openInMaps(poi: poi) },
                                        uberAction: { openInUber(poi: poi) }
                                    )
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 24)
                }
                .padding(.top, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Inicio")
            .onAppear {
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
            .navigationDestination(isPresented: $showChat) {
                PlanView(agent: SimplePlanner())
                    .environmentObject(matchesStore)
                    .environmentObject(poiStore)
                    .environmentObject(userPrefs)
            }
        }
    }
    
    // MARK: - Helpers (el resto del código se mantiene igual)
    
    private func nextMatch() -> Match? {
        let now = Date()
        let src = matchesStore.matches.isEmpty ? demoMatches() : matchesStore.matches
        return src.sorted(by: { $0.date < $1.date }).first { $0.date >= now } ?? src.first
    }
    
    // ... (todos los demás métodos helpers se mantienen igual)
    private func convertToMatchFixture(_ match: Match) -> MatchFixture {
        return MatchFixture(
            homeTeam: match.teams.first ?? "Home",
            awayTeam: match.teams.last ?? "Away",
            dateText: formatDate(match.date),
            stadium: match.venueName,
            city: match.city,
            homeFlagURL: flagURL(for: match.teams.first),
            awayFlagURL: flagURL(for: match.teams.last)
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy HH:mm"
        return formatter.string(from: date)
    }
    
    private func flagURL(for team: String?) -> String {
        guard let team = team else { return "" }
        return "https://flagcdn.com/w320/\(team).png"
    }
    
    private func suggestions(limit: Int = 8) -> [POI] {
        let city = (userPrefs.currentCity ?? "Ciudad de México").lowercased()
        let base = poiStore.pois.isEmpty ? demoPOIs() : poiStore.pois
        let cats: Set<POI.Category> = [.food, .museum, .landmark]
        let filtered = base.filter { poi in
            (poi.city.lowercased().contains(city) || city.isEmpty) && cats.contains(poi.category)
        }
        return Array(filtered.prefix(limit))
    }
    
    private func exchangePOIs(limit: Int = 8) -> [POI] {
        let city = (userPrefs.currentCity ?? "Ciudad de México").lowercased()
        let store = poiStore.pois
        let demos = demoPOIs()
        let fromStore = store.filter { poi in
            (poi.city.lowercased().contains(city) || city.isEmpty) && poi.category == .exchange
        }
        let fromDemo = demos.filter { poi in
            (poi.city.lowercased().contains(city) || city.isEmpty) && poi.category == .exchange
        }
        let source = fromStore.isEmpty ? fromDemo : fromStore
        return Array(source.prefix(limit))
    }
    
    private func hotelPOIs(limit: Int = 8) -> [POI] {
        let city = (userPrefs.currentCity ?? "Ciudad de México").lowercased()
        let store = poiStore.pois
        let demos = demoPOIs()
        let fromStore = store.filter { poi in
            (poi.city.lowercased().contains(city) || city.isEmpty) && poi.category == .hotel
        }
        let fromDemo = demos.filter { poi in
            (poi.city.lowercased().contains(city) || city.isEmpty) && poi.category == .hotel
        }
        let source = fromStore.isEmpty ? fromDemo : fromStore
        return Array(source.prefix(limit))
    }
    
    private func openInMaps(poi: POI) {
        let placemark = MKPlacemark(coordinate: .init(latitude: poi.latitude, longitude: poi.longitude))
        let item = MKMapItem(placemark: placemark)
        item.name = poi.name
        item.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
    }
    
    private func openInUber(poi: POI) {
        let lat = poi.latitude, lon = poi.longitude
        let appURL = URL(string: "uber://?action=setPickup&dropoff[latitude]=\(lat)&dropoff[longitude]=\(lon)")!
        let webURL = URL(string: "https://m.uber.com/ul/?action=setPickup&dropoff[latitude]=\(lat)&dropoff[longitude]=\(lon)")!
        if UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL)
        } else {
            UIApplication.shared.open(webURL)
        }
    }
    
    // MARK: - Demo fallback
    
    private func demoMatches() -> [Match] {
        [
            Match(id: "mx-001", dateISO: "2026-06-12T18:00:00Z", city: "Ciudad de México", venueName: "Estadio Azteca", teams: ["mexico","germany"], stage: "Inaugural", favorite: true),
            Match(id: "mx-002", dateISO: "2026-06-13T19:00:00Z", city: "Guadalajara", venueName: "Estadio Akron", teams: ["brazil","switzerland"], stage: "Fase de grupos")
        ]
    }
    
    private func demoPOIs() -> [POI] {
        [
            .init(id: "poi-templo-mayor", name: "Templo Mayor", category: .landmark, city: "Ciudad de México", latitude: 19.4351, longitude: -99.1310, priceRange: "$",  hours: "09:00-17:00", tags: ["centro","arqueología"]),
            .init(id: "poi-museo-nal",    name: "Museo Nacional de Antropología", category: .museum,  city: "Ciudad de México", latitude: 19.4260, longitude: -99.1860, priceRange: "$$", hours: "09:00-18:00", tags: ["imperdible"]),
            .init(id: "poi-tacos",        name: "Taquería El Ídolo", category: .food,     city: "Ciudad de México", latitude: 19.4270, longitude: -99.1670, priceRange: "$",  hours: "13:00-01:00", tags: ["tacos","rápido"]),
            .init(id: "poi-bar",          name: "La Mundialista",    category: .bar,      city: "Ciudad de México", latitude: 19.4205, longitude: -99.1630, priceRange: "$$", hours: "17:00-02:00", tags: ["pantallas"]),
            .init(id: "poi-cambio-1",    name: "Casa de Cambio Reforma", category: .exchange, city: "Ciudad de México", latitude: 19.4280, longitude: -99.1675, priceRange: nil, hours: "09:00-19:00", tags: ["dólares","euros"]),
            .init(id: "poi-cambio-2",    name: "Money Exchange Centro", category: .exchange, city: "Ciudad de México", latitude: 19.4330, longitude: -99.1330, priceRange: nil, hours: "10:00-18:00", tags: ["mejor tasa"]),
            .init(id: "poi-hotel-1",     name: "Hotel Azteca Centro", category: .hotel, city: "Ciudad de México", latitude: 19.4310, longitude: -99.1400, priceRange: "$$$", hours: "24h", tags: ["4 estrellas","wifi"]),
            .init(id: "poi-hotel-2",     name: "CDMX Suites", category: .hotel, city: "Ciudad de México", latitude: 19.4255, longitude: -99.1605, priceRange: "$$", hours: "24h", tags: ["económico","céntrico"])
        ]
    }
}

// MARK: - ScaleButtonStyle para efecto de pulsación
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - NextMatchCard (se mantiene igual)
struct NextMatchCard: View {
    let match: Match
    
    var body: some View {
        VStack(spacing: 0) {
            // Header con información del torneo
            HStack {
                Image(systemName: "trophy.fill")
                    .font(.caption2)
                    .foregroundColor(.orange)
                
                Text(match.stage.uppercased())
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.orange)
                
                Spacer()
                
                Text("PRÓXIMO")
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.fifanGreen)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            // Equipos y banderas
            HStack(spacing: 16) {
                // Equipo local
                VStack(spacing: 8) {
                    TeamFlag(teamCode: match.teams.first ?? "mx")
                    
                    Text(teamName(for: match.teams.first))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                
                // VS y hora
                VStack(spacing: 6) {
                    Text("VS")
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(.secondary)
                    
                    Text(formatMatchTime(match.date))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.fifanBlue)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.fifanBlue.opacity(0.1))
                        .clipShape(Capsule())
                }
                
                // Equipo visitante
                VStack(spacing: 8) {
                    TeamFlag(teamCode: match.teams.last ?? "de")
                    
                    Text(teamName(for: match.teams.last))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            
            // Información del estadio
            HStack(spacing: 12) {
                Image(systemName: "stadium.fill")
                    .font(.caption)
                    .foregroundColor(.fifanGreen)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(match.venueName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(match.city)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Botón de acción
                Button(action: {
                    // Acción para ver detalles del partido
                }) {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.title3)
                        .foregroundColor(.fifanBlue)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(.systemGray6))
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(
                    color: .black.opacity(0.1),
                    radius: 10,
                    x: 0,
                    y: 4
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.fifanBlue.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func formatMatchTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private func teamName(for teamCode: String?) -> String {
        guard let teamCode = teamCode else { return "TBD" }
        let teamNames: [String: String] = [
            "mexico": "México",
            "germany": "Alemania",
            "brazil": "Brasil",
            "argentina": "Argentina",
            "spain": "España",
            "france": "Francia",
            "italy": "Italia",
            "england": "Inglaterra"
        ]
        return teamNames[teamCode] ?? teamCode.capitalized
    }
}

// ... (el resto de los structs TeamFlag, NoMatchCard, CategoryChips, SuggestionCard, CategoryBadge se mantienen igual)
    // MARK: - TeamFlag Component
    struct TeamFlag: View {
        let teamCode: String
        
        var body: some View {
            AsyncImage(url: URL(string: "https://flagcdn.com/w80/\(flagCode(for: teamCode)).png")) { phase in
                switch phase {
                case .empty:
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 40)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                case .failure:
                    Image(systemName: "flag.slash")
                        .foregroundColor(.gray)
                        .frame(width: 60, height: 40)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 60, height: 40)
        }
        
        private func flagCode(for teamCode: String) -> String {
            let flagCodes: [String: String] = [
                "mexico": "mx",
                "germany": "de",
                "brazil": "br",
                "argentina": "ar",
                "spain": "es",
                "france": "fr",
                "italy": "it",
                "england": "gb-eng"
            ]
            return flagCodes[teamCode] ?? teamCode
        }
    }

    // MARK: - NoMatchCard
    struct NoMatchCard: View {
        var body: some View {
            VStack(spacing: 16) {
                Image(systemName: "soccerball.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.gray.opacity(0.5))
                
                VStack(spacing: 8) {
                    Text("No hay partidos próximos")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Revisa más tarde para ver los próximos encuentros")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
        }
    }
    // MARK: - Demo fallback
    
    private func demoMatches() -> [Match] {
        [
            Match(id: "mx-001", dateISO: "2026-06-12T18:00:00Z", city: "Ciudad de México", venueName: "Estadio Azteca", teams: ["mexico","germany"], stage: "Inaugural", favorite: true),
            Match(id: "mx-002", dateISO: "2026-06-13T19:00:00Z", city: "Guadalajara", venueName: "Estadio Akron", teams: ["brazil","switzerland"], stage: "Fase de grupos")
        ]
    }
    
    private func demoPOIs() -> [POI] {
        [
            .init(id: "poi-templo-mayor", name: "Templo Mayor", category: .landmark, city: "Ciudad de México", latitude: 19.4351, longitude: -99.1310, priceRange: "$",  hours: "09:00-17:00", tags: ["centro","arqueología"]),
            .init(id: "poi-museo-nal",    name: "Museo Nacional de Antropología", category: .museum,  city: "Ciudad de México", latitude: 19.4260, longitude: -99.1860, priceRange: "$$", hours: "09:00-18:00", tags: ["imperdible"]),
            .init(id: "poi-tacos",        name: "Taquería El Ídolo", category: .food,     city: "Ciudad de México", latitude: 19.4270, longitude: -99.1670, priceRange: "$",  hours: "13:00-01:00", tags: ["tacos","rápido"]),
            .init(id: "poi-bar",          name: "La Mundialista",    category: .bar,      city: "Ciudad de México", latitude: 19.4205, longitude: -99.1630, priceRange: "$$", hours: "17:00-02:00", tags: ["pantallas"]),
            .init(id: "poi-cambio-1",    name: "Casa de Cambio Reforma", category: .exchange, city: "Ciudad de México", latitude: 19.4280, longitude: -99.1675, priceRange: nil, hours: "09:00-19:00", tags: ["dólares","euros"]),
            .init(id: "poi-cambio-2",    name: "Money Exchange Centro", category: .exchange, city: "Ciudad de México", latitude: 19.4330, longitude: -99.1330, priceRange: nil, hours: "10:00-18:00", tags: ["mejor tasa"]),
            .init(id: "poi-hotel-1",     name: "Hotel Azteca Centro", category: .hotel, city: "Ciudad de México", latitude: 19.4310, longitude: -99.1400, priceRange: "$$$", hours: "24h", tags: ["4 estrellas","wifi"]),
            .init(id: "poi-hotel-2",     name: "CDMX Suites", category: .hotel, city: "Ciudad de México", latitude: 19.4255, longitude: -99.1605, priceRange: "$$", hours: "24h", tags: ["económico","céntrico"])
        ]
    }



// MARK: - CategoryChips View
struct CategoryChips: View {
    @Binding var selected: POI.Category?
    let categories: [POI.Category] = [.food, .museum, .landmark, .bar, .stadium]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        selected = category
                    }) {
                        Text(categoryName(category))
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selected == category ? categoryColor(category) : categoryColor(category).opacity(0.15))
                            .foregroundColor(selected == category ? .white : categoryColor(category))
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
    
    private func categoryName(_ category: POI.Category) -> String {
        switch category {
        case .food: return "🍕 Comida"
        case .museum: return "🏛️ Museos"
        case .landmark: return "🏙️ Lugares"
        case .bar: return "🍻 Bares"
        case .stadium: return "⚽ Estadios"
        case .hotel: return "🏨 Hoteles"
        case .exchange: return "💱 Cambio"
        }
    }
    
    private func categoryColor(_ category: POI.Category) -> Color {
        switch category {
        case .food: return .fifanGreen
        case .museum, .landmark: return .fifanBlue
        case .bar: return .fifanRed
        case .stadium: return .green
        case .hotel: return .purple
        case .exchange: return .orange
        }
    }
}

// MARK: - SuggestionCard View
struct SuggestionCard: View {
    let poi: POI
    let mapsAction: () -> Void
    let uberAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(poi.name)
                    .font(.headline)
                    .lineLimit(2)
                Spacer()
                CategoryBadge(category: poi.category)
            }
            
            HStack(spacing: 10) {
                Label(poi.priceRange ?? "—", systemImage: "coloncurrencysign.circle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Label(etaText(), systemImage: "figure.walk")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                Button { mapsAction() } label: {
                    Label("Maps", systemImage: "map.fill")
                        .padding(.vertical, 8).padding(.horizontal, 12)
                        .background(Color.fifanBlue.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                Button { uberAction() } label: {
                    Label("Uber", systemImage: "car.fill")
                        .padding(.vertical, 8).padding(.horizontal, 12)
                        .background(Color.fifanGreen.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
            .font(.subheadline)
        }
        .padding(12)
        .frame(width: 260, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(LinearGradient(colors: [.white, .white.opacity(0.95)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
        )
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.black.opacity(0.06)))
        .shadow(color: .black.opacity(0.07), radius: 5, x: 0, y: 3)
    }
    
    private func etaText() -> String {
        switch poi.category {
        case .food: return "~10–15 min"
        case .museum, .landmark: return "~15–25 min"
        case .bar, .stadium: return "~10–20 min"
        case .hotel: return "24h recepción"
        case .exchange: return "Consulta tasa"
        }
    }
}

// MARK: - CategoryBadge View
struct CategoryBadge: View {
    let category: POI.Category
    var body: some View {
        let (label, color): (String, Color) = {
            switch category {
            case .food:      return ("Comida", .fifanGreen)
            case .bar:       return ("Bar", .fifanRed)
            case .museum:    return ("Museo", .fifanBlue)
            case .landmark:  return ("Lugar", .fifanBlue)
            case .stadium:   return ("Estadio", .fifanGreen)
            case .hotel:     return ("Hotel", .purple)
            case .exchange:  return ("Cambio", .orange)
            }
        }()
        return Text(label)
            .font(.caption2.weight(.semibold))
            .padding(.vertical, 4).padding(.horizontal, 8)
            .background(color.opacity(0.12))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}
