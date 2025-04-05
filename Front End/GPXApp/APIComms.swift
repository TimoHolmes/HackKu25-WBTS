//
//  APIComms.swift
//  GPXApp
//
//  Created by Will Lawrence on 12/29/24.
//

// OSM Async Functions

import Foundation
import CoreLocation


struct OSMResponse : Codable {
    var version: Float?
    var generator: String?
    var osm3s: [String:String]?
    var elements: [OSMElements]?
}

struct OSMElements : Codable {
    var type: String
    var id: Int64?
    var lat: Double?
    var lon: Double?
    var nodes: [Int64]?
    var tags: [String: String]?
}


func getAsyncOSMData(lon: Double, lat: Double, radius: Double) async throws -> OSMResponse {
    // Calls the overpass api with the long ass http
    
    guard let url = URL(string: "https://overpass-api.de/api/interpreter") else {
        print("Invalid URL")
        let nothing = OSMResponse(version: 0.0, generator: "", osm3s: [:], elements: [])
        return nothing
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    
    // Trying out the around feature in the call. Should be useful for when user selects a distance they want i think
    let httpBody = """
    [out:json][timeout:25];
    // Define the bounding box for Overland Park, Kansas
    (
      // Select sidewalks that are NOT part of highways
      way["footway"="sidewalk"](around:1000,37.334730,-122.406417)
        [!highway];

      // Include trails and paths
      way["highway"="path"](around:1000,37.334730,-122.406417);
      way["highway"="footway"](around:1000,37.334730,-122.406417);
    );
    // Get ways
    (._; >;); // Grabs the longitude and latitude of the nodes
    out body;
    """
    
    request.httpBody = httpBody.data(using: .utf8)
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    //request.setValue(NSLocalizedString("lang", comment: ""), forHTTPHeaderField:"Accept-Language");
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    // 5. Validate the Response
    guard let httpResponse = response as? HTTPURLResponse,
          (200...299).contains(httpResponse.statusCode) else {
        throw URLError(.badServerResponse)
    }
    // 6. Decode the JSON Response
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    do {
        let osmResponse = try decoder.decode(OSMResponse.self, from: data)
        if let elements = osmResponse.elements {
            for element in elements {
                if element.type == "node", let lat = element.lat, let lon = element.lon {
                    // print("Node ID \(element.id ?? 0) -> Lat: \(lat), Lon: \(lon)")
                } else if element.type == "way", let nodeIDs = element.nodes {
                    // print("Way ID \(element.id ?? 0) -> Nodes: \(nodeIDs)")
                }
            }
        }
        print(osmResponse)
        return osmResponse
    }
    catch {
        print("error decoding")
    }
    
    return OSMResponse()
}


// --
struct ORSDirectionsResponse: Codable {
    let type: String
    let features: [ORSFeature]
    // Add bbox, metadata if needed from the actual API response
}

struct ORSFeature: Codable {
    let type: String
    let properties: ORSProperties
    let geometry: ORSGeometry
    // Add bbox if needed
}

struct ORSProperties: Codable {
    // Add more properties as needed from the response (e.g., segments, summary)
    let summary: ORSSummary?
}

struct ORSGeometry: Codable {
    let type: String // e.g., "LineString"
    // Coordinates format from ORS with elevation: [longitude, latitude, elevation]
    let coordinates: [[Double]]
}

struct ORSSummary: Codable {
    let distance: Double? // in meters
    let duration: Double? // in seconds
}

// Helper extension to convert ORS coordinates easily
extension ORSGeometry {
    // Returns coordinates suitable for MKPolyline (ignores elevation)
    var mapKitCoordinates: [CLLocationCoordinate2D] {
        // ORS coordinates are [longitude, latitude, elevation]
        coordinates.map { CLLocationCoordinate2D(latitude: $0[1], longitude: $0[0]) }
    }

    // Returns coordinates including elevation if you need it for other calculations
    var coordinatesWithElevation: [(coordinate: CLLocationCoordinate2D, elevation: Double)] {
         // ORS coordinates are [longitude, latitude, elevation]
         coordinates.map { (CLLocationCoordinate2D(latitude: $0[1], longitude: $0[0]), $0[2]) }
     }
}



// New API Call for OpenRouteService
func getAsyncORSData(startCoordinate: CLLocationCoordinate2D, endCoordinate: CLLocationCoordinate2D, typeOfPath: String="foot-path") async throws -> ORSDirectionsResponse {
    let apiKey = ""
    
    guard let url = URL(string: "https://api.openrouteservice.org/v2/directions/\(typeOfPath)/geojson") else {
            print("Invalid ORS URL")
            throw URLError(.badURL)
        }
    
    var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json, application/geo+json, application/gpx+xml, img/png; charset=utf-8", forHTTPHeaderField: "Accept")
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")

        // Note: ORS expects coordinates as [longitude, latitude]
        let requestBody: [String: Any] = [
            "coordinates": [
                [startCoordinate.longitude, startCoordinate.latitude],
                [endCoordinate.longitude, endCoordinate.latitude]
            ],
            "elevation": true // Request elevation data
            // Add alternative_routes dictionary here if needed
            // "alternative_routes": ["target_count": 3, "share_factor": 0.6, "weight_factor": 1.4]
        ]
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
        print("No HTTP response")
        throw URLError(.badServerResponse)
    }
    
    let decoder = JSONDecoder()
    
    do {
        let osrResponse = try decoder.decode(ORSDirectionsResponse.self, from: data)
        return osrResponse
    } catch {
        print("Error decoding ORS response: \(error)")
                print("Raw response data: \(String(data: data, encoding: .utf8) ?? "Undecodable data")")
                throw error
    }
}


func userSignUp(email: String, password: String, firstName: String, lastName: String) async throws -> Void {
    guard let url = URL(string: "http://127.0.0.1:8000/newUser") else {
            print("Invalid ORS URL")
            throw URLError(.badURL)
        }
    
    var request = URLRequest(url:url)
    request.httpMethod = "POST"
    
    let requestBody: String = """
            "FirstName": "\(email)",
            "LastName": "\(password)",
            "Email": "\(firstName)",
            "Password": "\(lastName)"
        """
    
    request.httpBody = requestBody.data(using: .utf8)
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    // 5. Validate the Response
    guard let httpResponse = response as? HTTPURLResponse,
          (200...299).contains(httpResponse.statusCode) else {
        throw URLError(.badServerResponse)
    }
}


func userLogin(email: String, password: String) async throws -> String {
    guard let url = URL(string: "http://127.0.0.1:8000/login") else {
            print("Invalid ORS URL")
            throw URLError(.badURL)
        }
    
    var request = URLRequest(url:url)
    request.httpMethod = "POST"
    
    let requestBody: String = """
        {
            "Email": "\(email)",
            "Password": "\(password)"
        }
        """
    
    request.httpBody = requestBody.data(using: .utf8)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse,
          (200...299).contains(httpResponse.statusCode) else {
        throw URLError(.badServerResponse)
    }
    
    let decoder = JSONDecoder()
    do {
        let loginResponse = try decoder.decode(userLoginResponse.self, from: data)
        print(loginResponse.Token)
        return loginResponse.Token
    } catch {
        print("Raw JSON data: \(String(data: data, encoding: .utf8) ?? "Unable to convert data to string")")

        print("Error decoding JSON: \(error)") // Keep your original error print
            // ... other error handling ...
    }
    return ""
}


struct userLoginResponse: Decodable {
    var status: Int32
    var Token: String
    var info: String
}
