import SwiftUI
import MapKit

struct TourismView: View {
    @EnvironmentObject var poiStore: POIStore
    @State private var searchText: String = ""
    @State private var selectedCategory: POI.Category? = nil
    @State private var selectedPOI: POI?
    @State private var showingMap = false
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332), // CDMX
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )

    // POIs de ejemplo mexicanos
    let mexicanPOIs: [POI] = [
        // Estadios
        .init(id: "estadio-azteca", name: "Estadio Azteca", category: .stadium, city: "Ciudad de México", latitude: 19.3029, longitude: -99.1505, priceRange: "$$", hours: "10:00-18:00", tags: ["futbol", "mundial", "iconico"]),
        .init(id: "akron", name: "Estadio Akron", category: .stadium, city: "Guadalajara", latitude: 20.6815, longitude: -103.4625, priceRange: "$$", hours: "10:00-18:00", tags: ["futbol", "chivas"]),
        .init(id: "bbva", name: "Estadio BBVA", category: .stadium, city: "Monterrey", latitude: 25.6696, longitude: -100.2385, priceRange: "$$", hours: "10:00-18:00", tags: ["futbol", "rayados"]),
        
        // Museos
        .init(id: "museo-antropologia", name: "Museo Nacional de Antropología", category: .museum, city: "Ciudad de México", latitude: 19.4260, longitude: -99.1860, priceRange: "$$", hours: "09:00-18:00", tags: ["cultura", "historia", "imperdible"]),
        .init(id: "museo-bellas-artes", name: "Palacio de Bellas Artes", category: .museum, city: "Ciudad de México", latitude: 19.4350, longitude: -99.1412, priceRange: "$$", hours: "10:00-17:00", tags: ["arte", "arquitectura"]),
        .init(id: "museo-frida", name: "Museo Frida Kahlo", category: .museum, city: "Ciudad de México", latitude: 19.3550, longitude: -99.1620, priceRange: "$$$", hours: "10:00-17:30", tags: ["arte", "coyoacan"]),
        
        // Lugares emblemáticos
        .init(id: "templo-mayor", name: "Templo Mayor", category: .landmark, city: "Ciudad de México", latitude: 19.4351, longitude: -99.1310, priceRange: "$", hours: "09:00-17:00", tags: ["aztecas", "centro", "arqueologia"]),
        .init(id: "chapultepec", name: "Castillo de Chapultepec", category: .landmark, city: "Ciudad de México", latitude: 19.4206, longitude: -99.1818, priceRange: "$", hours: "09:00-17:00", tags: ["historia", "vistas"]),
        .init(id: "teotihuacan", name: "Teotihuacán", category: .landmark, city: "Estado de México", latitude: 19.6925, longitude: -98.8435, priceRange: "$$", hours: "09:00-17:00", tags: ["piramides", "arqueologia"]),
        
        // Comida
        .init(id: "taqueria-idolo", name: "Taquería El Ídolo", category: .food, city: "Ciudad de México", latitude: 19.4270, longitude: -99.1670, priceRange: "$", hours: "13:00-01:00", tags: ["tacos", "rapido", "tradicional"]),
        .init(id: "pujol", name: "Pujol", category: .food, city: "Ciudad de México", latitude: 19.4255, longitude: -99.1945, priceRange: "$$$$", hours: "13:00-23:00", tags: ["gourmet", "mole"]),
        .init(id: "contramar", name: "Contramar", category: .food, city: "Ciudad de México", latitude: 19.4190, longitude: -99.1665, priceRange: "$$$", hours: "12:00-18:00", tags: ["mariscos", "atun"]),
        
        // Bares
        .init(id: "la-mundialista", name: "La Mundialista", category: .bar, city: "Ciudad de México", latitude: 19.4205, longitude: -99.1630, priceRange: "$$", hours: "17:00-02:00", tags: ["pantallas", "ambiente"]),
        .init(id: "licoreria-limantour", name: "Licorería Limantour", category: .bar, city: "Ciudad de México", latitude: 19.4235, longitude: -99.1635, priceRange: "$$$", hours: "18:00-02:00", tags: ["cocteles", "top"]),
        .init(id: "parker-lenox", name: "Parker & Lenox", category: .bar, city: "Ciudad de México", latitude: 19.4340, longitude: -99.1405, priceRange: "$$", hours: "19:00-02:00", tags: ["jazz", "elegante"]),
        
        // Hoteles
        .init(id: "hotel-reforma", name: "Hotel Reforma", category: .hotel, city: "Ciudad de México", latitude: 19.4320, longitude: -99.1520, priceRange: "$$$", hours: "24h", tags: ["centrico", "lujo"]),
        .init(id: "condesa-df", name: "Condesa DF", category: .hotel, city: "Ciudad de México", latitude: 19.4135, longitude: -99.1670, priceRange: "$$$$", hours: "24h", tags: ["boutique", "design"]),
        
        // Cambio de divisas
        .init(id: "cambio-reforma", name: "Casa de Cambio Reforma", category: .exchange, city: "Ciudad de México", latitude: 19.4280, longitude: -99.1675, priceRange: nil, hours: "09:00-19:00", tags: ["dolares", "euros"]),
        .init(id: "cambio-centro", name: "Money Exchange Centro", category: .exchange, city: "Ciudad de México", latitude: 19.4330, longitude: -99.1330, priceRange: nil, hours: "10:00-18:00", tags: ["mejor-tasa"])
    ]

    var filteredPOIs: [POI] {
        let basePOIs = poiStore.pois.isEmpty ? mexicanPOIs : poiStore.pois
        
        return basePOIs.filter { poi in
            let matchesSearch = searchText.isEmpty ||
                poi.name.localizedCaseInsensitiveContains(searchText) ||
                poi.city.localizedCaseInsensitiveContains(searchText) ||
            ((poi.tags?.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })) != nil)
            
            let matchesCategory = selectedCategory == nil || poi.category == selectedCategory
            
            return matchesSearch && matchesCategory
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header con búsqueda
                VStack(spacing: 12) {
                    SearchBar(text: $searchText, placeholder: "Buscar lugares...")
                    
                    CategoryFilterScrollView(selectedCategory: $selectedCategory)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .background(Color(.systemBackground))

                // Selector de vista
                Picker("Vista", selection: $showingMap) {
                    Text("Lista").tag(false)
                    Text("Mapa").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.vertical, 8)

                // Contenido principal
                if showingMap {
                    MapView(pois: filteredPOIs, selectedPOI: $selectedPOI, region: $region)
                        .edgesIgnoringSafeArea(.bottom)
                } else {
                    POIListView(pois: filteredPOIs, selectedPOI: $selectedPOI)
                }
            }
            .navigationTitle("Turismo")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedPOI) { poi in
                POIDetailView(poi: poi)
            }
        }
    }
}

// MARK: - Componentes

struct SearchBar: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct CategoryFilterScrollView: View {
    @Binding var selectedCategory: POI.Category?
    let categories: [POI.Category] = [.stadium, .museum, .landmark, .food, .bar, .hotel, .exchange]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // Filtro "Todos"
                Button(action: { selectedCategory = nil }) {
                    Text("Todos")
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(selectedCategory == nil ? Color.fifanBlue : Color(.systemGray5))
                        .foregroundColor(selectedCategory == nil ? .white : .primary)
                        .clipShape(Capsule())
                }
                
                ForEach(categories, id: \.self) { category in
                    Button(action: { selectedCategory = category }) {
                        HStack(spacing: 6) {
                            categoryIcon(category)
                            Text(categoryName(category))
                                .font(.caption.weight(.medium))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(selectedCategory == category ? categoryColor(category) : Color(.systemGray5))
                        .foregroundColor(selectedCategory == category ? .white : .primary)
                        .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
    
    private func categoryIcon(_ category: POI.Category) -> some View {
        let iconName: String = {
            switch category {
            case .stadium: return "sportscourt.fill"
            case .museum: return "building.columns.fill"
            case .landmark: return "location.fill"
            case .food: return "fork.knife"
            case .bar: return "wineglass.fill"
            case .hotel: return "bed.double.fill"
            case .exchange: return "dollarsign.circle.fill"
            }
        }()
        
        return Image(systemName: iconName)
            .font(.system(size: 12))
    }
    
    private func categoryName(_ category: POI.Category) -> String {
        switch category {
        case .stadium: return "Estadios"
        case .museum: return "Museos"
        case .landmark: return "Lugares"
        case .food: return "Comida"
        case .bar: return "Bares"
        case .hotel: return "Hoteles"
        case .exchange: return "Cambio"
        }
    }
    
    private func categoryColor(_ category: POI.Category) -> Color {
        switch category {
        case .stadium: return .fifanGreen
        case .museum: return .orange
        case .landmark: return .fifanBlue
        case .food: return .red
        case .bar: return .purple
        case .hotel: return .brown
        case .exchange: return .green
        }
    }
}

struct POIListView: View {
    let pois: [POI]
    @Binding var selectedPOI: POI?
    
    var body: some View {
        List {
            ForEach(pois, id: \.id) { poi in
                POIRow(poi: poi)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedPOI = poi
                    }
                    .listRowSeparator(.visible)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct POIRow: View {
    let poi: POI
    
    var body: some View {
        HStack(spacing: 12) {
            // Icono de categoría
            CategoryIcon(category: poi.category)
                .font(.title3)
                .foregroundColor(categoryColor(poi.category))
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(poi.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack(spacing: 6) {
                    Label(poi.city, systemImage: "location.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let hours = poi.hours {
                        Text("•")
                            .foregroundColor(.gray.opacity(0.5))
                        Label(hours, systemImage: "clock.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let priceRange = poi.priceRange {
                    Text(priceRange)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.fifanGreen.opacity(0.2))
                        .foregroundColor(.fifanGreen)
                        .clipShape(Capsule())
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private func categoryColor(_ category: POI.Category) -> Color {
        switch category {
        case .stadium: return .fifanGreen
        case .museum: return .orange
        case .landmark: return .fifanBlue
        case .food: return .red
        case .bar: return .purple
        case .hotel: return .brown
        case .exchange: return .green
        }
    }
}

struct CategoryIcon: View {
    let category: POI.Category
    
    var body: some View {
        let iconName: String = {
            switch category {
            case .stadium: return "sportscourt.fill"
            case .museum: return "building.columns.fill"
            case .landmark: return "location.circle.fill"
            case .food: return "fork.knife.circle.fill"
            case .bar: return "wineglass.fill"
            case .hotel: return "bed.double.circle.fill"
            case .exchange: return "dollarsign.circle.fill"
            }
        }()
        
        return Image(systemName: iconName)
    }
}

struct MapView: View {
    let pois: [POI]
    @Binding var selectedPOI: POI?
    @Binding var region: MKCoordinateRegion
    
    var body: some View {
        Map(coordinateRegion: $region, annotationItems: pois) { poi in
            MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: poi.latitude, longitude: poi.longitude)) {
                MapAnnotationView(poi: poi)
                    .onTapGesture {
                        selectedPOI = poi
                    }
            }
        }
    }
}

struct MapAnnotationView: View {
    let poi: POI
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: annotationIcon)
                .font(.system(size: 20))
                .foregroundColor(.white)
                .padding(8)
                .background(annotationColor)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
            
            Text(poi.name)
                .font(.system(size: 10, weight: .semibold))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.white)
                .foregroundColor(.black)
                .clipShape(Capsule())
                .shadow(radius: 2)
        }
    }
    
    private var annotationIcon: String {
        switch poi.category {
        case .stadium: return "sportscourt.fill"
        case .museum: return "building.columns.fill"
        case .landmark: return "location.fill"
        case .food: return "fork.knife"
        case .bar: return "wineglass.fill"
        case .hotel: return "bed.double.fill"
        case .exchange: return "dollarsign.circle.fill"
        }
    }
    
    private var annotationColor: Color {
        switch poi.category {
        case .stadium: return .fifanGreen
        case .museum: return .orange
        case .landmark: return .fifanBlue
        case .food: return .red
        case .bar: return .purple
        case .hotel: return .brown
        case .exchange: return .green
        }
    }
}

struct POIDetailView: View {
    let poi: POI
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top) {
                            CategoryIcon(category: poi.category)
                                .font(.title)
                                .foregroundColor(categoryColor)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(poi.name)
                                    .font(.title2.bold())
                                
                                Text(poi.city)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        if let priceRange = poi.priceRange {
                            Text(priceRange)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(categoryColor.opacity(0.2))
                                .foregroundColor(categoryColor)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal)
                    
                    // Información
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        if let hours = poi.hours {
                            InfoCard(icon: "clock.fill", title: "Horario", value: hours, color: .orange)
                        }
                        
                        InfoCard(icon: "location.fill", title: "Ciudad", value: poi.city, color: .fifanBlue)
                        
                        InfoCard(icon: "tag.fill", title: "Categoría", value: categoryName, color: .fifanGreen)
                    }
                    .padding(.horizontal)
                    
                    // Tags
                    if !poi.tags!.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Características")
                                .font(.headline)
                            
                            FlowLayout(spacing: 8) {
                                ForEach(poi.tags!, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color(.systemGray6))
                                        .foregroundColor(.primary)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Botones de acción
                    VStack(spacing: 12) {
                        Button(action: openInMaps) {
                            HStack {
                                Image(systemName: "map.fill")
                                Text("Abrir en Maps")
                                Spacer()
                                Image(systemName: "arrow.up.forward")
                            }
                            .padding()
                            .background(Color.fifanBlue.opacity(0.1))
                            .foregroundColor(.fifanBlue)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        Button(action: openInUber) {
                            HStack {
                                Image(systemName: "car.fill")
                                Text("Pedir Uber")
                                Spacer()
                                Image(systemName: "arrow.up.forward")
                            }
                            .padding()
                            .background(Color.black.opacity(0.1))
                            .foregroundColor(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var categoryColor: Color {
        switch poi.category {
        case .stadium: return .fifanGreen
        case .museum: return .orange
        case .landmark: return .fifanBlue
        case .food: return .red
        case .bar: return .purple
        case .hotel: return .brown
        case .exchange: return .green
        }
    }
    
    private var categoryName: String {
        switch poi.category {
        case .stadium: return "Estadio"
        case .museum: return "Museo"
        case .landmark: return "Lugar Emblemático"
        case .food: return "Restaurante"
        case .bar: return "Bar"
        case .hotel: return "Hotel"
        case .exchange: return "Casa de Cambio"
        }
    }
    
    private func openInMaps() {
        let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: poi.latitude, longitude: poi.longitude))
        let item = MKMapItem(placemark: placemark)
        item.name = poi.name
        item.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
    }
    
    private func openInUber() {
        let lat = poi.latitude, lon = poi.longitude
        let appURL = URL(string: "uber://?action=setPickup&dropoff[latitude]=\(lat)&dropoff[longitude]=\(lon)")!
        let webURL = URL(string: "https://m.uber.com/ul/?action=setPickup&dropoff[latitude]=\(lat)&dropoff[longitude]=\(lon)")!
        
        if UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL)
        } else {
            UIApplication.shared.open(webURL)
        }
    }
}

struct InfoCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// Helper para diseño de tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        
        var totalHeight: CGFloat = 0
        var totalWidth: CGFloat = 0
        
        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0
        
        for size in sizes {
            if lineWidth + size.width + spacing > proposal.width ?? 0 {
                totalHeight += lineHeight + spacing
                totalWidth = max(totalWidth, lineWidth)
                lineWidth = size.width
                lineHeight = size.height
            } else {
                lineWidth += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
        }
        
        totalHeight += lineHeight
        totalWidth = max(totalWidth, lineWidth)
        
        return CGSize(width: totalWidth, height: totalHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        
        var lineX = bounds.minX
        var lineY = bounds.minY
        var lineHeight: CGFloat = 0
        
        for index in subviews.indices {
            if lineX + sizes[index].width > bounds.maxX {
                lineY += lineHeight + spacing
                lineHeight = 0
                lineX = bounds.minX
            }
            
            subviews[index].place(
                at: CGPoint(x: lineX, y: lineY),
                proposal: ProposedViewSize(sizes[index])
            )
            
            lineX += sizes[index].width + spacing
            lineHeight = max(lineHeight, sizes[index].height)
        }
    }
}

#Preview {
    TourismView()
        .environmentObject(POIStore())
}
