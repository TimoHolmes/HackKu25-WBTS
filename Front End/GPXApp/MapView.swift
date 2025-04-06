//
//  MapView.swift
//  GPXApp
//
//  Created by Will Lawrence on 12/30/24.
//
import MapKit
import SwiftUI
import Combine

// Make CLLocationCoordinate2D conform to Equatable
extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        // Two coordinates are equal if their latitudes and longitudes are equal
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

struct MapView: View {
    @State private var position: MapCameraPosition = .automatic
        @StateObject var deviceLocationService = DeviceLocationService.shared
        @State var tokens: Set<AnyCancellable> = []

        // State variable to hold the user's current location
        @State private var currentCoordinates: CLLocationCoordinate2D? = nil

        // State variable for the destination (Set this based on user input/selection)
        @State private var destinationCoordinates: CLLocationCoordinate2D? = CLLocationCoordinate2D(latitude: 38.9577, longitude: -95.2450) // Example: Fixed destination

        // State variable to hold the route polylines for display
        @State private var routeOverlays: [MKPolyline] = []

        // Remove these older state variables if you're using MKPolyline overlays
        // @State private var showRoute = false
        // @State private var routeDisplaying = false
        // @State private var route: MKRoute?
        // @State private var routeDestination: MKMapItem?
        // @State private var travelInterval: TimeInterval?
        // @State private var transportType: MKDirectionsTransportType = .walking
    
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
                Map(position: $position) {
                    // Display current location marker (Optional but good)
                    if let location = currentCoordinates {
                         Marker("My Location", coordinate: location)
                             .tint(.blue)
                    }
                    
                    // Display destination marker (Optional but good)
                    if let destination = destinationCoordinates {
                        Marker("Destination", coordinate: destination)
                            .tint(.red)
                    }

                    // Display the route overlays fetched from ORS
                    ForEach(routeOverlays, id: \.self) { polyline in
                         MapPolyline(polyline)
                             .stroke(.cyan, lineWidth: 5) // Customize route color/width
                    }
                    
                }
                    .mapStyle(.hybrid(elevation: .realistic))
                    .ignoresSafeArea()
                    .onChange(of: currentCoordinates) { oldValue, newValue in
                        Task { await fetchAndDisplayRoute() }
                    }
                    .onChange(of: destinationCoordinates) { oldValue, newValue in
                         Task { await fetchAndDisplayRoute() }
                    }
                    .onAppear {
                        observeCoordinateUpdates()
                        observeDeviceLocationDenied()
                        deviceLocationService.requestLocationUpdates()

                        // Set initial map position (e.g., Lawrence, KS, or based on user location if available)
                         let initialCenter = currentCoordinates ?? CLLocationCoordinate2D(latitude: 38.9717, longitude: -95.2353)
                        position = .region(MKCoordinateRegion(
                            center: initialCenter,
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05) // Adjust zoom level
                        ))
                        
                        // Initial route fetch if location is already available
                        Task { await fetchAndDisplayRoute() }
                    }
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
        }
    

    
    
    func observeCoordinateUpdates() {
            deviceLocationService.coordinatesPublisher
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                     if case .failure(let error) = completion {
                         print("Failed to get location updates: \(error)")
                     }
                 }, receiveValue: { coordinates in
                    // Update current location state
                    self.currentCoordinates = coordinates
                    // Optionally move the map camera, but maybe only on first load or user action
                    // self.position = .region(MKCoordinateRegion(center: coordinates, span: mapSpan))
                })
                .store(in: &tokens)
        }

        func observeDeviceLocationDenied() {
            deviceLocationService.deniedLocationAccess
                .receive(on: DispatchQueue.main)
                .sink {
                    print("Location access was denied.")
                    // Handle denied access (e.g., show an alert prompting user to enable)
                }
                .store(in: &tokens)
        }
    
    
    // Renamed from fetchRoute and integrated ORS call
        func fetchAndDisplayRoute() async {
            // Ensure we have both start and end coordinates
            guard let start = currentCoordinates, let end = destinationCoordinates else {
                print("Missing start or end coordinates for route.")
                self.routeOverlays = [] // Clear any existing route if coordinates are invalid
                return
            }

            print("Fetching ORS route from \(start) to \(end)")
            do {
                // Call the ORS API function
                let orsResponse = try await getAsyncORSData(startCoordinate: start, endCoordinate: end)

                // Clear previous overlays
                var newOverlays: [MKPolyline] = []

                if let routeFeature = orsResponse.features.first {
                    // Get coordinates ready for MapKit polyline (using the helper)
                    let routeCoordinates = routeFeature.geometry.mapKitCoordinates
                    
                    print("Number of coordinates received for polyline: \(routeCoordinates.count)")
                    if routeCoordinates.count >= 2 {
                        let polyline = MKPolyline(coordinates: routeCoordinates, count: routeCoordinates.count)
                        newOverlays.append(polyline) // Add the new polyline
                        if let polyline = newOverlays.first {
                            let routeRect = polyline.boundingMapRect
                            // Set position to slightly larger than the route bounds
                            await MainActor.run {
                                 // Add some padding around the route
                                 let padding = routeRect.width * 0.1 // 10% padding
                                 self.position = .rect(routeRect.insetBy(dx: -padding, dy: -padding))
                            }
                        }

                        // Print some details (optional)
                        let coordsWithElevation = routeFeature.geometry.coordinatesWithElevation
                        if let firstPoint = coordsWithElevation.first {
                             print("Route Start Elevation: \(firstPoint.elevation) m")
                        }
                         print("Total route distance: \(routeFeature.properties.summary?.distance ?? 0) meters")
                         print("Estimated duration: \((routeFeature.properties.summary?.duration ?? 0) / 60) minutes")

                        // Optionally adjust map position to show the whole route
                        // let routeRect = polyline.boundingMapRect
                        // self.position = .rect(routeRect.insetBy(dx: -routeRect.width * 0.1, dy: -routeRect.height * 0.1)) // Add padding

                    } else {
                        print("Not enough coordinates in ORS response geometry.")
                    }
                } else {
                    print("No route features found in ORS response.")
                }
                print("newOverlays count before state update: \(newOverlays.count)")
                
                // Update the state variable on the main thread
                 await MainActor.run {
                     self.routeOverlays = newOverlays
                 }

            } catch {
                print("ORS Data fetch or processing failed: \(error)")
                // Handle error (e.g., show an alert to the user)
                 await MainActor.run {
                     self.routeOverlays = [] // Clear route on error
                 }
            }
        }
    
    
    
    
    
    
    
    
    
    
    
//    func search(for query: String) {
//        let request = MKLocalSearch.Request()
//        request.naturalLanguageQuery = query
//        request.resultTypes = .pointOfInterest
//        request.region = MKCoordinateRegion(
//            center: (CLLocationCoordinate2D(latitude: 40.7127, longitude: -73.9654)),
//            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
//    }
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


#Preview {
    MapView()
}
