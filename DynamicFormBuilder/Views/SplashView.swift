//
//  SplashView.swift
//  DynamicFormBuilder
//
//  Created by Veeru Masal on 01/06/26.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: "#121212"),
                        Color(hex: "#1E1E1E")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                Image("launchIcon")
                    .resizable()
                    .frame(width: 120, height: 120)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    isActive = true
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
