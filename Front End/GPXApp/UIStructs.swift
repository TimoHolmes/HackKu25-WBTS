//
//  UIStructs.swift
//  GPXApp
//
//  Created by Spencer Addis on 4/5/25.
//

import MapKit
import SwiftUI
import Combine

struct RunRoute: Identifiable, Codable {
    let id: UUID
    let routeName: String
    let runDate: Date
    let distance: Double
    let onlySidewalks: Bool
    let roundTrip: Bool
}

struct UserInfo: Identifiable, Codable {
    // Unique identifier for the user
    let id: String
    var firstName: String
    var lastName: String
    var email: String
    // The user's current running streak (e.g., consecutive days)
    var runningStreak: Int
    var recentRoutes: [RunRoute]
}
