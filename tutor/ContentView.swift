//
//  ContentView.swift
//  tutor
//
//  Created by gokul on 20/03/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            JSHomeView()
                .tabItem {
                    Label("JavaScript", systemImage: "curlybraces")
                }
                .tag(0)
            
            PythonHomeView()
                .tabItem {
                    Label("Python", systemImage: "terminal")
                }
                .tag(1)
        }
        .edgesIgnoringSafeArea(.top)
    }
}

#Preview {
    ContentView()
}
