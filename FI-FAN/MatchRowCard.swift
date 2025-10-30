//
//  MatchRowCard.swift
//  FI-FAN
//

import SwiftUI

// MARK: - Modelo (renombrado para evitar choques)
struct MatchFixture: Identifiable, Equatable {
    let id = UUID()
    let homeTeam: String
    let awayTeam: String
    let dateText: String
    let stadium: String
    let city: String
    let homeFlagURL: URL?
    let awayFlagURL: URL?

    init(homeTeam: String,
         awayTeam: String,
         dateText: String,
         stadium: String,
         city: String,
         homeFlagURL: String,
         awayFlagURL: String)
    {
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.dateText = dateText
        self.stadium = stadium
        self.city = city
        self.homeFlagURL = URL(string: homeFlagURL)
        self.awayFlagURL = URL(string: awayFlagURL)
    }
}

// MARK: - Vista de tarjeta reutilizable
struct MatchRowCard: View {
    let fixture: MatchFixture

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack(spacing: 10) {
                flag(fixture.homeFlagURL)

                Text(fixture.homeTeam)
                    .font(.headline)

                Spacer(minLength: 8)

                Text("vs")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 8)

                Text(fixture.awayTeam)
                    .font(.headline)

                flag(fixture.awayFlagURL)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(fixture.dateText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 6) {
                    Image(systemName: "stadium.fill")
                    Text(fixture.stadium)
                    Text("• \(fixture.city)")
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline)
            }
        }
        .padding()
        .background(
            // Cambia por tus assets si quieres (GradientStart/GradientEnd)
            LinearGradient(colors: [.blue.opacity(0.95), .green.opacity(0.95)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }

    private func flag(_ url: URL?) -> some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image): image.resizable()
            default: Color.white.opacity(0.25)
            }
        }
        .frame(width: 40, height: 26)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

// MARK: - Preview rápido
#Preview {
    VStack(spacing: 16) {
        MatchRowCard(
            fixture: .init(
                homeTeam: "México",
                awayTeam: "Alemania",
                dateText: "12 Jun 2026 • 12:00 p.m.",
                stadium: "Estadio Azteca",
                city: "Ciudad de México",
                homeFlagURL: "https://flagcdn.com/w40/mx.png",
                awayFlagURL: "https://flagcdn.com/w40/de.png"
            )
        )
    }
    .padding(.vertical)
    .background(Color(.systemGroupedBackground))
}
