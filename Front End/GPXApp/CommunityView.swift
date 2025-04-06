//
//  CommunityView.swift
//  GPXApp
//
//  Created by Spencer Addis on 4/5/25.
//

import MapKit
import SwiftUI
import Combine

// MARK: - Data Models

//struct RunRoute: Identifiable, Codable {
//    let id: String
//    let routeName: String
//    let runDate: Date
//    let distance: Double
//}

private let dateFormatter: DateFormatter = {
   let formatter = DateFormatter()
   formatter.dateStyle = .medium
   formatter.timeStyle = .short
   return formatter
}()

// MARK: - View Model

// Simulated view model for community routes.
class CommunityRoutesViewModel: ObservableObject {
    @Published var recentRoutes: [RunRoute] = [
        RunRoute(id: UUID(), routeName: "Morning Run", runDate: Date().addingTimeInterval(-600), distance: 5.2, onlySidewalks: true, roundTrip: false),
        RunRoute(id: UUID(), routeName: "Eric Stonestreet", runDate: Date().addingTimeInterval(-600), distance: 30.1, onlySidewalks: true, roundTrip: false),
    ]
    
    @Published var topRatedRoutes: [RunRoute] = [
        RunRoute(id: UUID(), routeName: "Run #5", runDate: Date().addingTimeInterval(-600), distance: 7.00, onlySidewalks: true, roundTrip: true),
        RunRoute(id: UUID(), routeName: "Squillem", runDate: Date().addingTimeInterval(-600), distance: 384.333, onlySidewalks: false, roundTrip: false),
    ]
}

// MARK: - Category Enum

enum CommunityRouteCategory: String, CaseIterable, Identifiable {
    case recent = "Recent Community Routes"
    case topRated = "Top Rated Community Routes"
    
    var id: String { self.rawValue }
}

// MARK: - Main Community Routes View

struct CommunityRoutesView: View {
    @State private var selectedCategory: CommunityRouteCategory = .recent
    @StateObject var viewModel = CommunityRoutesViewModel()
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack(alignment: .center) {
                    Text("Community Runs")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }.padding([.horizontal, .top])
                // Drop-down menu (Picker styled as a Menu)
                Picker("Routes", selection: $selectedCategory) {
                    ForEach(CommunityRouteCategory.allCases) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                
                // List of routes based on selected category
                ScrollView {
                    VStack(spacing: 16) {
                        if selectedCategory == .recent {
                            ForEach(viewModel.recentRoutes) { route in
                                RouteCard(route: route)
                            }
                        } else {
                            ForEach(viewModel.topRatedRoutes) { route in
                                RouteCard(route: route)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
    }
}

// MARK: - Preview

struct CommunityRoutesView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityRoutesView()
    }
}
