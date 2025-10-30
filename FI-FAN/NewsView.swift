import SwiftUI

struct RSSItem: Identifiable {
    let id = UUID()
    let title: String
    let link: String
    let description: String?
    let pubDate: String?
    let imageURL: String?
}

struct NewsView: View {
    @State private var items: [RSSItem] = []
    @State private var isLoading = false
    @State private var selectedItem: RSSItem?
    @State private var showingSafari = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    if isLoading {
                        ProgressView("Cargando noticias...")
                            .frame(height: 200)
                    } else {
                        ForEach(items) { item in
                            NewsCard(item: item)
                                .onTapGesture {
                                    selectedItem = item
                                    showingSafari = true
                                }
                                .contextMenu {
                                    Button(action: {
                                        shareNews(item)
                                    }) {
                                        Label("Compartir", systemImage: "square.and.arrow.up")
                                    }
                                    
                                    Button(action: {
                                        copyLink(item)
                                    }) {
                                        Label("Copiar enlace", systemImage: "link")
                                    }
                                }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .background(Color(.systemGroupedBackground))
            .refreshable {
                await load()
            }
            .sheet(isPresented: $showingSafari) {
                if let item = selectedItem, let url = URL(string: item.link) {
                    SafariView(url: url)
                }
            }
            .task {
                await load()
            }
            .navigationTitle("Noticias")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // Feeds mejorados con más variedad
    let feeds = [
        URL(string: "https://www.espn.com/espn/rss/soccer/news")!,
        URL(string: "https://feeds.bbci.co.uk/sport/football/rss.xml")!,
        URL(string: "https://www.marca.com/rss/futbol/internacional.xml")!,
        URL(string: "https://as.com/rss/tags/ultimas_noticias.xml")!
    ]

    func load() async {
        isLoading = true
        defer { isLoading = false }
        var acc: [RSSItem] = []
        for url in feeds {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                acc.append(contentsOf: parseRSS(data: data))
            } catch {
                print("RSS error: \(error)")
            }
        }
        // Ordenar por fecha si está disponible, sino mantener orden de carga
        items = Array(acc.prefix(20))
    }

    // Parser RSS mejorado para extraer más información
    func parseRSS(data: Data) -> [RSSItem] {
        guard let xml = String(data: data, encoding: .utf8) else { return [] }
        var results: [RSSItem] = []
        let itemChunks = xml.components(separatedBy: "<item").dropFirst()
        
        for chunk in itemChunks {
            let rawTitle = match(chunk, between: "<title>", and: "</title>") ?? "Sin título"
            let title = decodeHTMLEntities(stripCDATA(rawTitle)).trimmingCharacters(in: .whitespacesAndNewlines)
            
            let rawLink = match(chunk, between: "<link>", and: "</link>") ?? "#"
            let link = stripCDATA(rawLink).trimmingCharacters(in: .whitespacesAndNewlines)
            
            let rawDescription = match(chunk, between: "<description>", and: "</description>")
            let description = rawDescription != nil ? decodeHTMLEntities(stripCDATA(rawDescription!)).trimmingCharacters(in: .whitespacesAndNewlines) : nil
            
            let rawPubDate = match(chunk, between: "<pubDate>", and: "</pubDate>")
            let pubDate = rawPubDate != nil ? formatDate(rawPubDate!) : nil
            
            let imageURL = extractImageURL(from: chunk) ?? extractImageURL(from: description ?? "")
            
            results.append(RSSItem(
                title: title,
                link: link,
                description: description,
                pubDate: pubDate,
                imageURL: imageURL
            ))
        }
        return results
    }

    func extractImageURL(from text: String) -> String? {
        // Buscar URLs de imagen en el texto
        let patterns = [
            "src=\"(.*?\\.(jpg|jpeg|png|gif))\"",
            "src='(.*?\\.(jpg|jpeg|png|gif))'",
            "<media:content url=\"(.*?\\.(jpg|jpeg|png|gif))\"",
            "<enclosure url=\"(.*?\\.(jpg|jpeg|png|gif))\""
        ]
        
        for pattern in patterns {
            if let range = text.range(of: pattern, options: .regularExpression),
               let urlRange = text.range(of: "(http[^\"']+\\.(jpg|jpeg|png|gif))", options: .regularExpression, range: range) {
                return String(text[urlRange])
            }
        }
        return nil
    }

    func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        // Intentar diferentes formatos de fecha RSS
        let formats = [
            "EEE, dd MMM yyyy HH:mm:ss Z",
            "EEE, dd MMM yyyy HH:mm Z",
            "dd MMM yyyy HH:mm:ss Z"
        ]
        
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: dateString) {
                let outputFormatter = DateFormatter()
                outputFormatter.locale = Locale(identifier: "es_MX")
                outputFormatter.dateStyle = .medium
                outputFormatter.timeStyle = .short
                return outputFormatter.string(from: date)
            }
        }
        
        return dateString
    }

    func match(_ s: String, between a: String, and b: String) -> String? {
        guard let r1 = s.range(of: a), let r2 = s.range(of: b, range: r1.upperBound..<s.endIndex) else { return nil }
        return String(s[r1.upperBound..<r2.lowerBound])
    }

    func stripCDATA(_ s: String) -> String {
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("<![CDATA[") && trimmed.hasSuffix("]]>"),
           let startRange = trimmed.range(of: "<![CDATA["),
           let endRange = trimmed.range(of: "]]>", options: .backwards) {
            return String(trimmed[startRange.upperBound..<endRange.lowerBound])
        }
        return trimmed
    }

    func decodeHTMLEntities(_ s: String) -> String {
        if let data = s.data(using: .utf8) {
            if let attributed = try? NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
            ) {
                return attributed.string
            }
        }
        return s
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&apos;", with: "'")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&nbsp;", with: " ")
    }

    private func shareNews(_ item: RSSItem) {
        guard let url = URL(string: item.link) else { return }
        let activityVC = UIActivityViewController(activityItems: [item.title, url], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }

    private func copyLink(_ item: RSSItem) {
        UIPasteboard.general.string = item.link
    }
}

// MARK: - NewsCard Component
struct NewsCard: View {
    let item: RSSItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Imagen de la noticia
            if let imageURL = item.imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 200)
                            .overlay(
                                ProgressView()
                                    .scaleEffect(0.8)
                            )
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                    case .failure:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 120)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                .cornerRadius(12)
            }
            
            // Contenido de la noticia
            VStack(alignment: .leading, spacing: 8) {
                // Título
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                // Descripción
                if let description = item.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                // Footer con fecha y fuente
                HStack {
                    if let pubDate = item.pubDate {
                        Label(pubDate, systemImage: "clock")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(sourceName(from: item.link))
                        .font(.caption2)
                        .foregroundColor(.fifanBlue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.fifanBlue.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(
                    color: .black.opacity(0.1),
                    radius: 8,
                    x: 0,
                    y: 2
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray4).opacity(0.3), lineWidth: 1)
        )
    }
    
    private func sourceName(from url: String) -> String {
        if url.contains("espn.com") { return "ESPN" }
        else if url.contains("bbci.co.uk") { return "BBC" }
        else if url.contains("marca.com") { return "Marca" }
        else if url.contains("as.com") { return "AS" }
        else { return "Noticia" }
    }
}

// MARK: - SafariView para mostrar noticias
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        return SFSafariViewController(url: url, configuration: config)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

// MARK: - Preview
#Preview {
    NewsView()
}
