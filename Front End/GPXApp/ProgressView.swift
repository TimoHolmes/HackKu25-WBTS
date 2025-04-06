//
//  ProgressView.swift
//  GPXApp
//
//  Created by Spencer Addis on 4/4/25.
//

import MapKit
import SwiftUI
import Combine
import Foundation


class RouteViewModel: ObservableObject {
    @Published var runRoutes: [RunRoute] = []
    
    init () {
        fetchRoutes()
    }
    
    func fetchRoutes() {
        // Simulated database fetch (replace with your actual database code)
        let sampleRoutes = [
            RunRoute(id: UUID(), routeName: "Morning Run", runDate: Date().addingTimeInterval(-600), distance: 5.2, onlySidewalks: true, roundTrip: false),
            RunRoute(id: UUID(), routeName: "Evening Jog", runDate: Date().addingTimeInterval(-3600), distance: 3.4, onlySidewalks: true, roundTrip: false),
            RunRoute(id: UUID(), routeName: "Weekend Sprint", runDate: Date().addingTimeInterval(-7200), distance: 2.1, onlySidewalks: true, roundTrip: false),
            RunRoute(id: UUID(), routeName: "Preworkout Run", runDate: Date().addingTimeInterval(-7200), distance: 1.5, onlySidewalks: true, roundTrip: false),
            RunRoute(id: UUID(), routeName: "Quickie", runDate: Date().addingTimeInterval(-7200), distance: 0.3, onlySidewalks: true, roundTrip: false),
            RunRoute(id: UUID(), routeName: "Sunday Route", runDate: Date().addingTimeInterval(-7200), distance: 4.4, onlySidewalks: true, roundTrip: false),
            RunRoute(id: UUID(), routeName: "Run Club #43", runDate: Date().addingTimeInterval(-7200), distance: 7.2, onlySidewalks: true, roundTrip: false),
            RunRoute(id: UUID(), routeName: "Iron Man", runDate: Date().addingTimeInterval(-7200), distance: 26.2, onlySidewalks: true, roundTrip: false),
        ]
        
        // Sort so that the most recent run (largest date) is at the top
        self.runRoutes = sampleRoutes.sorted { $0.runDate > $1.runDate }
    }
}

struct RouteCard: View {
    let route: RunRoute
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Display the route name and date on the top line
            HStack {
                Text(route.routeName)
                    .font(.headline)
                Spacer()
                Text("\(route.runDate, formatter: dateFormatter)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Text("Distance: \(route.distance, specifier: "%.1f") mi")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}

private let dateFormatter: DateFormatter = {
   let formatter = DateFormatter()
   formatter.dateStyle = .medium
   formatter.timeStyle = .short
   return formatter
}()

struct ProgressPage: View {
    let user = UserInfo(id: "1",
                        firstName: "John",
                        lastName: "Doe",
                        email: "john.doe@example.com",
                        runningStreak: 7,
                        recentRoutes: [])
    @StateObject var viewModel = RouteViewModel()
    
    var body: some View {
            NavigationView {
                VStack(alignment: .leading) {
                    // Custom header view
                    HStack(alignment: .center) {
                        Text("Recent Runs")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        // Display the running streak, styled as needed.
                        VStack(alignment: .trailing) {
//                            Text("Streak")
//                                .font(.caption)
//                                .foregroundColor(.gray)
                            Text("🔥 \(user.runningStreak)")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                        }
                    }
                    .padding([.horizontal, .top])
                    
                    // Main content: Scrollable list of recent routes.
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(viewModel.runRoutes) { route in
                                NavigationLink(destination: RouteDetailView(route: route)) {
                                    RouteCard(route: route)
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarHidden(true) // Hide the default nav bar if using a custom header
            }
        }
}



