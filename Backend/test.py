import requests
import networkx as nx
import json
import matplotlib.pyplot as plt
from utils import haversine_miles, create_bounding_box


def callORS(coord):
    lat, lon = coord

    bbox = create_bounding_box(lat, lon, 0.3)
    body = {"bbox": bbox}

    print(bbox)

    headers = {
        'Accept': 'application/json, application/geo+json, application/gpx+xml, img/png; charset=utf-8',
        'Authorization': '5b3ce3597851110001cf6248dd131f22f5494ac7a8c4ce2090eb473c',
        'Content-Type': 'application/json; charset=utf-8'
    }
    call = requests.post('https://api.openrouteservice.org/v2/export/driving-car', json=body, headers=headers)

    info = call.json()
    
    return info


def addInfoToGraph(g, info):
    nodes = info["nodes"]
    edges = info["edges"]

    for node in nodes:
        g.add_node(node['nodeId'], location = node['location'])

    for edge in edges:
        dist =  haversine_miles(g.nodes[edge['fromId']]['location'], g.nodes[edge['toId']]['location'])
        g.add_edge(edge['fromId'], edge['toId'], weight = dist)





def fillGraph(coords):
    lon, lat = coords

    g = nx.Graph()
    info = callORS(coords)

    print(info)
    addInfoToGraph(g, info)

    stack = []
    
    for i in range(10):
        for node in g.nodes:
            if(haversine_miles(g.nodes['location'], coords) < (0.5 * i + 1)):
                continue

            print("adding node:", node)
            info = callORS(g.nodes[node]['location'])
            stack.append(info)

        for info in stack:
            addInfoToGraph(g, info)

        stack = []

    print("finish")


    
fillGraph([-95.259277, 38.956402])



