import osmnx as ox
import networkx as nx
import numpy as np
import geopy.distance

def callOSM(coord, target_distance_miles):
    print(f"callOSM called with coord: {coord}, target_distance_miles: {target_distance_miles}")
    
    # Download graph data for the given coordinates
    G = ox.graph_from_point(coord, dist=5000, network_type='all')

    # Convert the target distance to meters
    target_distance_meters = target_distance_miles * 1609.34

    # Get nearest nodes to the coordinates
    origin_node = ox.distance.nearest_nodes(G, X=coord[1], Y=coord[0])
    
    # Initialize some parameters for the coordinate adjustment
    step_size = 0.002  # Reduced step size
    max_iterations = 100  # Increase iterations to allow for more subtle adjustments
    adjusted_coords = coord
    found_route = False

    # Iterate to adjust coordinates and search for route
    for iteration in range(max_iterations):
        print(f"Iteration {iteration + 1}: Adjusting coordinates with step {step_size}")
        
        # Adjust coordinates slightly
        adjusted_coords = [coord[0] + step_size, coord[1] + step_size]  # Adjust both lat & lon
        
        # Get the nearest node for the adjusted coordinates
        destination_node = ox.distance.nearest_nodes(G, X=adjusted_coords[1], Y=adjusted_coords[0])
        
        # Get the shortest path from the origin to the destination node
        route = nx.shortest_path(G, source=origin_node, target=destination_node, weight='length')
        
        # Get the length of the route in meters
        route_length = nx.shortest_path_length(G, source=origin_node, target=destination_node, weight='length')
        
        print(f"Adjusted coordinates: {adjusted_coords}")
        print(f"Origin node: {origin_node}, Destination node: {destination_node}")
        print(f"Current route distance: {route_length} meters")
        
        # Check if the route is close enough to the target distance
        if route_length >= target_distance_meters:
            print(f"Found a valid route with distance: {route_length} meters")
            found_route = True
            break
        
        # If route distance is too short, increase the step size for next iteration
        step_size += 0.001  # Increase step size more gradually

    if not found_route:
        print("Maximum iterations reached or no valid route found.")
        return {'nodes': [], 'edges': []}

    # Return the final route's nodes and edges
    route_edges = [(route[i], route[i+1]) for i in range(len(route) - 1)]
    return {'nodes': route, 'edges': route_edges}

# Example usage
coord = [37.774929, -122.419418]  # Coordinates for San Francisco
target_distance_miles = 5.0  # Target distance in miles
result = callOSM(coord, target_distance_miles)
print("Final Result:", result)