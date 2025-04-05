//
//  MapView.swift
//  GPXApp
//
//  Created by Will Lawrence on 12/30/24.
//
import MapKit
import SwiftUI
import Combine

struct MapView: View {
    @State private var position: MapCameraPosition = .automatic
    @StateObject var deviceLocationService = DeviceLocationService.shared
    @State var tokens: Set<AnyCancellable> = []
    
    // Coordinates for Lawrence, Kansas
    @State var coordinates: (lat: Double, lon: Double) = (38.9717, -95.2353)
    
    // Route
    @State private var showRoute = false
    @State private var routeDisplaying = false
    @State private var route: MKRoute?
    @State private var routeDestination: MKMapItem?
    @State private var travelInterval: TimeInterval?
    @State private var transportType: MKDirectionsTransportType = .walking
    var body: some View {
        VStack {
            Map(position: $position) {}
                .mapStyle(.hybrid(elevation: .flat))
        }
        .task {
            do {
                let osm = try await getAsyncOSMData(lon: coordinates.lon, lat: coordinates.lat, radius: 10000)
            } catch {
                print("OSM Data fetch failed", error)
            }
        }
        .onAppear {
            observeCoordinateUpdates()
            observeDeviceLocationDenied()
            deviceLocationService.requestLocationUpdates()
            
            // Move map to Lawrence, Kansas on appearance
            position = .region(
                MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: coordinates.lat, longitude: coordinates.lon),
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
        }
    }
    
    
    func observeCoordinateUpdates() {
        deviceLocationService.coordinatesPublisher
            .receive(on: DispatchQueue.main)
            .sink { _ in } receiveValue: { coordinates in
                self.coordinates = (coordinates.latitude, coordinates.longitude)
            }
            .store(in: &tokens)
    }
    
    func observeDeviceLocationDenied() {
        deviceLocationService.deniedLocationAccess
            .receive(on: DispatchQueue.main)
            .sink {
                print("Error on getting location")
            }
            .store(in: &tokens)
    }
    
    
    func fetchRoute() async {
        // Need to somehow fetch route
    }
    
    func search(for query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        request.region = MKCoordinateRegion(
            center: (CLLocationCoordinate2D(latitude: 40.7127, longitude: -73.9654)),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    }
}

// New NavigationButton above footer with an oval shape
struct NavigationButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "location.north.fill") // Directional arrow icon
                    .font(.title2)
                    .foregroundColor(.white)
                Text("Create Route")
                    .foregroundColor(.white)
                    .font(.body)
                    .padding(.leading, 5)
            }
            .padding()
            .frame(height: 60)
            .background(Color.blue)
            .clipShape(Capsule()) // Oval shape
            .shadow(radius: 5)
        }
    }
}
