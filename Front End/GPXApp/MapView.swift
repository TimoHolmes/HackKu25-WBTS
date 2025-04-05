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
    @State private var showBottomSheet = false
    @State private var roundTrip = false
    @State private var sidewalksOnly = false
    @State private var routeDistance: String = ""

    var body: some View {
            ZStack {
                // Map layer
                Map(position: $position) {}
                    .mapStyle(.hybrid(elevation: .flat))
                    .ignoresSafeArea()

                // Floating Create Route button (only visible if the sheet is hidden)
                if !showBottomSheet {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            NavigationButton {
                                showBottomSheet = true
                            }
                            .padding(.trailing, 16)
                            .padding(.bottom, 16)
                        }
                    }
                }

                // Overlay bottom sheet if toggled
                if showBottomSheet {
                    DraggableBottomSheet(roundTrip: $roundTrip, sidewalksOnly: $sidewalksOnly, routeDistance: $routeDistance, onDismiss: {
                        showBottomSheet = false
                    })
                }
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

                // Move map to initial region
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

struct DraggableBottomSheet: View {
    @Binding var roundTrip: Bool
    @Binding var sidewalksOnly: Bool
    @Binding var routeDistance: String
    var onDismiss: () -> Void  // New callback for when the sheet should be removed
    
    @State private var offset: CGFloat = UIScreen.main.bounds.height * 0.4
    @GestureState private var dragOffset = CGFloat.zero

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    closeSheet()
                }

            VStack {
                Capsule()
                    .frame(width: 40, height: 6)
                    .foregroundColor(.gray)
                    .padding(.top, 10)

                // Toggles for settings
                VStack(alignment: .leading, spacing: 20) {
                    Toggle("Round Trip", isOn: $roundTrip)
                    Toggle("Sidewalks Only", isOn: $sidewalksOnly)
                    VStack(alignment: .leading) {
                        Text("Route Distance (mi):")
                            //.font(.subheadline)
                        TextField("Enter distance", text: $routeDistance)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                .padding()

                Spacer()
            }
            .frame(height: 600)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(20)
            .offset(y: offset + dragOffset)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation.height
                    }
                    .onEnded { value in
                        let predictedOffset = offset + value.translation.height
                        if predictedOffset > 300 {
                            closeSheet()
                        } else {
                            openSheet()
                        }
                    }
            )
            .animation(.easeOut, value: dragOffset)
        }
    }

    // Animates the sheet off-screen then calls the onDismiss callback
    func closeSheet() {
        withAnimation(.easeInOut.speed(0.5)) {
            offset = UIScreen.main.bounds.height
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }

    // Resets the sheet's offset back to its initial value
    func openSheet() {
        withAnimation(.easeInOut.speed(0.5)) {
            offset = UIScreen.main.bounds.height * 0.4
        }
    }
}
