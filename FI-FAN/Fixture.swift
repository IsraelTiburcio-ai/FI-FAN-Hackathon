//
//  Fixture.swift
//  FI-FAN
//

import Foundation

struct Fixture: Identifiable, Equatable {
    let id = UUID()
    let homeTeam: String
    let awayTeam: String
    let dateText: String
    let stadium: String
    let city: String
    let homeFlagURL: String
    let awayFlagURL: String
}
