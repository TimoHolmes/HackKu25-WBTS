//
//  ContentView.swift
//  GPXApp
//
//  Created by Will Lawrence on 12/29/24.
//

import SwiftUI
import MapKit
import UIKit
import Combine


struct ContentView: View {
    @State private var selectedTab: String = "Progress"
    @State var OSM: OSMResponse = OSMResponse()
    var body: some View {
        NavigationView {
            VStack {
                if selectedTab == "Progress" {
                    ProgressPage()
                } else if selectedTab == "Explore" {
                    MapView()
                } else if selectedTab == "Community" {
                    CommunityRoutesView()
                }
                
                //Spacer()
                
                HStack {
                    FooterButton(iconName: "chart.bar.fill", label: "Progress", action: {
                        selectedTab = "Progress"
                    })
                    
                    FooterButton(iconName: "person.3.fill", label: "Community", action: {
//                        print("Community button tapped")
                        selectedTab = "Community"
                    })
                    
                    //Spacer()
                    
                    FooterButton(iconName: "mappin.circle.fill", label: "Explore", action: {
                        selectedTab = "Explore"
                    })
                    
                    FooterButton(iconName: "person.crop.circle.fill", label: "Profile", action: {
                        print("Profile button tapped")
                    })
                }
                .padding(.top)
                .background(Color.gray)
                //.shadow(radius: 5)
            }
//            .overlay(
//                // Only show the NavigationButton when Explore tab is selected
//                selectedTab == "Explore" ? AnyView(
//                    VStack {
//                        Spacer()
//                        HStack {
//                            Spacer()
//                            NavigationButton {
//                                print("Create Route tapped")
//                            }
//                            .padding(.trailing, 10) // Space from right edge
//                            .padding(.bottom, 85) // Move it up a little bit
//                        }
//                    }
//                ) : AnyView(EmptyView()), alignment: .bottom
//            )
        }
    }
}

struct FooterButton: View {
    var iconName: String
    var label: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(.white)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
        }
    }
}


#Preview {
    ContentView()
}
