import SwiftUI

// MARK: - MODELOS

struct TeamStanding: Identifiable {
    let id = UUID()
    let countryKey: String      // ej. "mexico", "england"
    let displayName: String     // ej. "México", "Inglaterra"
    let played: Int
    let wins: Int
    let draws: Int
    let losses: Int
    let goalsFor: Int
    let goalsAgainst: Int
    let last5: [MatchResult]    // max 5: .win / .draw / .loss

    var goalDiff: Int { goalsFor - goalsAgainst }
    var points: Int { wins * 3 + draws }
}

enum MatchResult { case win, draw, loss }

struct GroupStanding: Identifiable {
    let id = UUID()
    let name: String            // "Grupo A", "Grupo B", ...
    var teams: [TeamStanding]
}

// MARK: - VISTA PRINCIPAL

struct StandingsView: View {
    // Demo: Qatar 2022 (datos finales de fase de grupos simplificados)
    private var groups: [GroupStanding] = [
        GroupStanding(name: "Grupo A", teams: [
            .init(countryKey: "netherlands", displayName: "Países Bajos", played: 3, wins: 2, draws: 1, losses: 0, goalsFor: 5, goalsAgainst: 1, last5: [.win,.draw,.win]),
            .init(countryKey: "senegal",     displayName: "Senegal",       played: 3, wins: 2, draws: 0, losses: 1, goalsFor: 5, goalsAgainst: 4, last5: [.loss,.win,.win]),
            .init(countryKey: "ecuador",     displayName: "Ecuador",       played: 3, wins: 1, draws: 1, losses: 1, goalsFor: 4, goalsAgainst: 3, last5: [.win,.draw,.loss]),
            .init(countryKey: "qatar",       displayName: "Catar",         played: 3, wins: 0, draws: 0, losses: 3, goalsFor: 1, goalsAgainst: 7, last5: [.loss,.loss,.loss])
        ]),
        GroupStanding(name: "Grupo B", teams: [
            .init(countryKey: "england",      displayName: "Inglaterra",    played: 3, wins: 2, draws: 1, losses: 0, goalsFor: 9, goalsAgainst: 2, last5: [.win,.draw,.win]),
            .init(countryKey: "unitedstates", displayName: "Estados Unidos",played: 3, wins: 1, draws: 2, losses: 0, goalsFor: 2, goalsAgainst: 1, last5: [.draw,.draw,.win]),
            .init(countryKey: "iran",         displayName: "Irán",          played: 3, wins: 1, draws: 0, losses: 2, goalsFor: 4, goalsAgainst: 7, last5: [.loss,.win,.loss]),
            .init(countryKey: "wales",        displayName: "Gales",         played: 3, wins: 0, draws: 1, losses: 2, goalsFor: 1, goalsAgainst: 6, last5: [.draw,.loss,.loss])
        ]),
        GroupStanding(name: "Grupo C", teams: [
            .init(countryKey: "argentina",    displayName: "Argentina",     played: 3, wins: 2, draws: 0, losses: 1, goalsFor: 5, goalsAgainst: 2, last5: [.loss,.win,.win]),
            .init(countryKey: "poland",       displayName: "Polonia",       played: 3, wins: 1, draws: 1, losses: 1, goalsFor: 2, goalsAgainst: 2, last5: [.win,.draw,.loss]),
            .init(countryKey: "mexico",       displayName: "México",        played: 3, wins: 1, draws: 1, losses: 1, goalsFor: 2, goalsAgainst: 3, last5: [.draw,.loss,.win]),
            .init(countryKey: "saudiarabia",  displayName: "Arabia Saudita",played: 3, wins: 1, draws: 0, losses: 2, goalsFor: 3, goalsAgainst: 5, last5: [.win,.loss,.loss])
        ])
        // Puedes añadir grupos D–H con el mismo formato
    ]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    headerRow()
                }
                .listRowInsets(EdgeInsets()) // header ancho completo

                ForEach(groups) { group in
                    Section(group.name) {
                        ForEach(sorted(group.teams)) { t in
                            StandingRow(team: t)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Fase de grupos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("Fase de grupos · 2026")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func sorted(_ teams: [TeamStanding]) -> [TeamStanding] {
        teams.sorted { lhs, rhs in
            if lhs.points != rhs.points { return lhs.points > rhs.points }
            if lhs.goalDiff != rhs.goalDiff { return lhs.goalDiff > rhs.goalDiff }
            if lhs.goalsFor != rhs.goalsFor { return lhs.goalsFor > rhs.goalsFor }
            return lhs.displayName < rhs.displayName
        }
    }

    @ViewBuilder
    private func headerRow() -> some View {
        HStack {
            Text("Equipo").frame(maxWidth: .infinity, alignment: .leading).font(.caption.bold())
            statHeader("PJ")
            statHeader("G")
            statHeader("E")
            statHeader("P")
            statHeader("GF")
            statHeader("GC")
            statHeader("DG")
            statHeader("Pts")
            Text("Últimos 5").font(.caption.bold()).frame(width: 110, alignment: .center)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 8)
        .background(
            LinearGradient(colors: [.fifanBlue.opacity(0.95), .fifanGreen.opacity(0.95)],
                           startPoint: .leading, endPoint: .trailing)
        )
        .foregroundStyle(.white)
    }

    private func statHeader(_ s: String) -> some View {
        Text(s)
            .font(.caption.bold())
            .frame(width: 32, alignment: .trailing)
    }
}

// MARK: - FILA DE EQUIPO

private struct StandingRow: View {
    let team: TeamStanding

    var body: some View {
        HStack(spacing: 8) {
            // Escudo/flag + nombre
            HStack(spacing: 8) {
                Image("flag_\(team.countryKey)")
                    .resizable().scaledToFit()
                    .frame(width: 24, height: 18)
                    .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 3).stroke(.black.opacity(0.08), lineWidth: 0.5))
                Text(team.displayName)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            stat(team.played)
            stat(team.wins)
            stat(team.draws)
            stat(team.losses)
            stat(team.goalsFor)
            stat(team.goalsAgainst)
            stat(team.goalDiff)
                .foregroundStyle(team.goalDiff >= 0 ? .green : .red)

            Text("\(team.points)")
                .font(.subheadline.weight(.semibold))
                .frame(width: 32, alignment: .trailing)

            LastFiveView(results: team.last5)
                .frame(width: 110, alignment: .center)
        }
        .padding(.vertical, 6)
    }

    private func stat(_ v: Int) -> some View {
        Text("\(v)")
            .font(.subheadline)
            .frame(width: 32, alignment: .trailing)
            .foregroundStyle(.primary)
    }
}

// MARK: - ÚLTIMOS 5

private struct LastFiveView: View {
    let results: [MatchResult] // hasta 5

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<5, id: \.self) { i in
                let symbol: (String, Color) = {
                    guard i < results.count else { return ("circle", .gray.opacity(0.3)) }
                    switch results[i] {
                    case .win:  return ("checkmark.circle.fill", .green)
                    case .draw: return ("minus.circle.fill",     .gray)
                    case .loss: return ("xmark.circle.fill",     .red)
                    }
                }()
                Image(systemName: symbol.0)
                    .foregroundStyle(symbol.1)
                    .font(.caption)
            }
        }
    }
}

// MARK: - Colores de marca (mismos que usas en Home/Matches)

extension Color {
    static let fifanGreen = Color(red: 0.06, green: 0.45, blue: 0.33)
    static let fifanBlue  = Color(red: 0.05, green: 0.19, blue: 0.38)
    static let fifanRed   = Color(red: 0.79, green: 0.06, blue: 0.18)
}

@ViewBuilder
private func flagImage(_ key: String) -> some View {
    let assetName = "flag_\(key)"
    if let ui = UIImage(named: assetName) {
        Image(uiImage: ui)
            .resizable().scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 3).stroke(.black.opacity(0.08), lineWidth: 0.5))
    } else {
        // Fallback si no existe el asset: usa emoji o SF Symbol genérico
        Text(emojiForCountry(key))
            .font(.system(size: 14))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
    }
}

private func emojiForCountry(_ key: String) -> String {
    // Añade los que uses. Esto evita que se vea vacío si falta el PNG.
    let map: [String:String] = [
        "mexico":"🇲🇽","germany":"🇩🇪","brazil":"🇧🇷","switzerland":"🇨🇭",
        "argentina":"🇦🇷","japan":"🇯🇵","unitedstates":"🇺🇸","france":"🇫🇷",
        "spain":"🇪🇸","canada":"🇨🇦","england":"🏴","netherlands":"🇳🇱",
        "senegal":"🇸🇳","ecuador":"🇪🇨","qatar":"🇶🇦","iran":"🇮🇷",
        "wales":"🏴","poland":"🇵🇱","saudiarabia":"🇸🇦"
    ]
    return map[key, default: "🏳️"]
}

private func displayNameFallback(for key: String) -> String {
    let map: [String:String] = [
        "mexico":"México","germany":"Alemania","brazil":"Brasil","switzerland":"Suiza",
        "argentina":"Argentina","japan":"Japón","unitedstates":"Estados Unidos","france":"Francia",
        "spain":"España","canada":"Canadá","england":"Inglaterra","netherlands":"Países Bajos",
        "senegal":"Senegal","ecuador":"Ecuador","qatar":"Catar","iran":"Irán",
        "wales":"Gales","poland":"Polonia","saudiarabia":"Arabia Saudita"
    ]
    return map[key, default: key.capitalized]
}
