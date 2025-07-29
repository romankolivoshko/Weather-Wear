//
//  ContentView.swift
//  WeatherWear
//
//  Created by romankolivoshko on 29.07.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var cityName: String = ""
    @State private var temperature: String = "--℃"
    @State private var condition: String = ""
    @State private var clothingAdvice: Array = []
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Weather")
                .font(.largeTitle)
                .bold()
            
            TextField("Enter the city name", text: $cityName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button("Schow the weather") {
                fetchWeather(for: cityName)
            }
            
        }
    }
}

#Preview {
    ContentView()
}
