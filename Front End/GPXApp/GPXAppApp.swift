//
//  GPXAppApp.swift
//  GPXApp
//
//  Created by Will Lawrence on 12/29/24.
//

import SwiftUI

@main
struct GPXAppApp: App {
    var body: some Scene {
        WindowGroup {
            @State var isLoggedIn: Bool = false
            if isLoggedIn == true {
                ContentView()
            } else {
                LoginPage()
            }
        }
    }
}
