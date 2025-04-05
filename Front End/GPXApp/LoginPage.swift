//
//  LoginPage.swift
//  GPXApp
//
//  Created by Will Lawrence on 4/5/25.
//

import Combine
import SwiftUI

struct LoginPage: View {
    @State private var email = ""
    @State private var password = ""
    @State private var wrongUsername = 0
    @State private var wrongPassword = 0
    @State private var isLoggedIn = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.green.ignoresSafeArea(edges: .all)
                Circle()
                    .scale(1.9)
                    .foregroundColor(.white.opacity(0.6))
                Circle()
                    .scale(1.5)
                    .foregroundColor(.white.opacity(0.8))
                
                VStack {
                    Text("Sign in to GPX Generator")
                        .font(.title)
                        .padding()
                    TextField("email", text: .constant("    apple@example.com"))
                        .padding(.top)
                        .frame(width: 300, height: 50)
                        .background(Color.white.opacity(0.1))
                        .border(.red, width: CGFloat(wrongUsername))
                        .cornerRadius(5)
                    SecureField("password", text: .constant("123456"))
                        .frame(width: 300, height: 50)
                        .background(Color.black.opacity(0.2))
                        .border(.red, width: CGFloat(wrongPassword))
                        .cornerRadius(5)
                    Button("SIGN IN") {
                        print("IN")
                    }
                    Button("SIGN UP") {
                        print("HELO")
                    }

                }
            }
        }
        .navigationBarHidden(true)
    }
}


#Preview {
    LoginPage()
}
