//
//  MatchesView.swift
//  FI-FAN
//

import SwiftUI

struct MatchesView: View {
    // Demo data con más partidos
    let upcomingMatches: [Fixture] = [
        .init(
            homeTeam: "México",
            awayTeam: "Alemania",
            dateText: "12 Jun 2026 • 12:00 p.m.",
            stadium: "Estadio Azteca",
            city: "Ciudad de México",
            homeFlagURL: "https://flagcdn.com/w40/mx.png",
            awayFlagURL: "https://flagcdn.com/w40/de.png"
        ),
        .init(
            homeTeam: "Argentina",
            awayTeam: "Japón",
            dateText: "13 Jun 2026 • 3:00 p.m.",
            stadium: "MetLife Stadium",
            city: "Nueva Jersey",
            homeFlagURL: "https://flagcdn.com/w40/ar.png",
            awayFlagURL: "https://flagcdn.com/w40/jp.png"
        ),
        .init(
            homeTeam: "España",
            awayTeam: "Brasil",
            dateText: "14 Jun 2026 • 4:00 p.m.",
            stadium: "SoFi Stadium",
            city: "Los Ángeles",
            homeFlagURL: "https://flagcdn.com/w40/es.png",
            awayFlagURL: "https://flagcdn.com/w40/br.png"
        ),
        .init(
            homeTeam: "Francia",
            awayTeam: "Portugal",
            dateText: "15 Jun 2026 • 2:00 p.m.",
            stadium: "AT&T Stadium",
            city: "Dallas",
            homeFlagURL: "https://flagcdn.com/w40/fr.png",
            awayFlagURL: "https://flagcdn.com/w40/pt.png"
        ),
        .init(
            homeTeam: "Inglaterra",
            awayTeam: "Países Bajos",
            dateText: "16 Jun 2026 • 5:00 p.m.",
            stadium: "Mercedes-Benz Stadium",
            city: "Atlanta",
            homeFlagURL: "https://flagcdn.com/w40/gb-eng.png",
            awayFlagURL: "https://flagcdn.com/w40/nl.png"
        ),
        .init(
            homeTeam: "Italia",
            awayTeam: "Bélgica",
            dateText: "17 Jun 2026 • 1:00 p.m.",
            stadium: "Gillette Stadium",
            city: "Boston",
            homeFlagURL: "https://flagcdn.com/w40/it.png",
            awayFlagURL: "https://flagcdn.com/w40/be.png"
        ),
        .init(
            homeTeam: "Estados Unidos",
            awayTeam: "Canadá",
            dateText: "18 Jun 2026 • 6:00 p.m.",
            stadium: "Lumen Field",
            city: "Seattle",
            homeFlagURL: "https://flagcdn.com/w40/us.png",
            awayFlagURL: "https://flagcdn.com/w40/ca.png"
        )
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header con contador
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Partidos Próximos")
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                            
                            Text("\(upcomingMatches.count) partidos programados")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Botón de filtro
                        Button(action: {
                            // Acción de filtro
                        }) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.title3)
                                .foregroundColor(.fifanBlue)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)

                    LazyVStack(spacing: 12) {
                        ForEach(upcomingMatches) { fixture in
                            ModernMatchCard(fixture: fixture)
                        }
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 40)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Partidos")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

private struct ModernMatchCard: View {
    let fixture: Fixture
    
    var body: some View {
        VStack(spacing: 0) {
            // Header con fecha
            HStack {
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundColor(.fifanBlue)
                
                Text(fixture.dateText)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Etiqueta de estado (podría ser "Próximo", "En vivo", etc.)
                Text("PRÓXIMO")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.fifanGreen)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)

            // Contenido principal del partido
            HStack(spacing: 16) {
                // Equipo local
                VStack(spacing: 8) {
                    flag(fixture.homeFlagURL)
                    
                    Text(fixture.homeTeam)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }
                .frame(maxWidth: .infinity)

                // VS y hora
                VStack(spacing: 4) {
                    Text("VS")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.secondary)
                    
                    Text(extractTime(from: fixture.dateText))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.fifanBlue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.fifanBlue.opacity(0.1))
                        .clipShape(Capsule())
                }

                // Equipo visitante
                VStack(spacing: 8) {
                    flag(fixture.awayFlagURL)
                    
                    Text(fixture.awayTeam)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)

            // Footer con estadio
            HStack(spacing: 8) {
                Image(systemName: "mappin.circle.fill")
                    .font(.caption)
                    .foregroundColor(.fifanRed)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(fixture.stadium)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(fixture.city)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Botón de acción rápida
                Button(action: {
                    // Acción para ver detalles o mapa
                }) {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(
                    color: .black.opacity(0.08),
                    radius: 8,
                    x: 0,
                    y: 2
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(.systemGray4).opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 4)
    }

    private func flag(_ urlString: String) -> some View {
        AsyncImage(url: URL(string: urlString)) { phase in
            switch phase {
            case .empty:
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 32)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 32)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            case .failure:
                Image(systemName: "flag.slash")
                    .foregroundColor(.gray)
                    .frame(width: 50, height: 32)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            @unknown default:
                EmptyView()
            }
        }
        .frame(width: 50, height: 32)
    }
    
    private func extractTime(from dateText: String) -> String {
        // Extrae solo la hora del texto de fecha
        if let timeRange = dateText.range(of: "•\\s*(.*)", options: .regularExpression) {
            return String(dateText[timeRange])
                .replacingOccurrences(of: "• ", with: "")
        }
        return dateText
    }
}

// Preview para ver cómo se ve
#Preview {
    MatchesView()
}
