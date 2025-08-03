//
//  ContentView.swift
//  WeatherWear
//
//  Created by romankolivoshko on 29.07.2025.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @State private var city: String = ""
    @State private var temperature: String = "--℃"
    @State private var condition: String = ""
    @State private var clothingAdvice: String = "What to wear?"
    @State private var iconCode: String = ""
    
    @FocusState private var isInputFocused: Bool
    
    @StateObject private var locationManager = LocationManager()
    
    @State private var weatherSymbol: String = "questionmark"
    
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Weather")
                .font(.largeTitle)
                .bold()
            
            Text(city)
                .font(.title3)
                .foregroundColor(.gray)
            
            TextField("Enter the city name", text: $city)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($isInputFocused)
                .padding(.horizontal)
            
            Button("Show the weather") {
                isInputFocused = false
                if city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    if let location = locationManager.location {
                        fetchWeatherByLocation(lat: location.latitude, lon: location.longitude)
                    } else {
                        print("Weating fro GPS...")
                    }
                } else {
                    fetchWeather(for: city)
                }
            }
            .padding()
            .background(Color.blue.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(20)
            
            HStack(spacing: 10) {
                Text(temperature)
                    .font(.system(size: 50))
                    .bold()
                
                Image(systemName: weatherSymbol)
                    .font(.system(size: 40))
                    .foregroundColor(.orange)
            }
            
            Text(condition)
                .font(.title2)
            
            Divider()
            
            Text(clothingAdvice)
                .padding()
        }
        .padding()
        .task {
            if city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
               let location = locationManager.location {
                fetchWeatherByLocation(lat: location.latitude, lon: location.longitude)
            }
        }
        .onChange(of: locationManager.city) {
            if city.isEmpty {
                city = locationManager.city
            }
        }
    }
    
    func fetchWeather(for city: String) {
        let apiKey = "e80681a2c0c48d53fe4f160c832852d6"
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)&units=metric&lang=ua"

        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) {data, response, error in
            if let error = error {
                print("Reguest error : \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data")
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(WeatherData.self, from: data)
                
                DispatchQueue.main.async {
                    self.temperature = "\(Int(decodedData.main.temp))°C"
                    self.condition = decodedData.weather.first?.description.capitalized ?? "Unknown"
                    self.clothingAdvice = generateAdvice(for: decodedData.main.temp)
                    self.iconCode = decodedData.weather.first?.icon ?? ""
                    self.weatherSymbol = mapConditionToSymbol(decodedData.weather.first?.main ?? "")
                }
            } catch {
                print("Decoing error: \(error)")
            }
        }.resume()
    }
    
    func fetchWeatherByLocation(lat: Double, lon: Double) {
        let apiKey = "e80681a2c0c48d53fe4f160c832852d6"
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric&lang=ua"
        
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) {data, response, error in
            if let error = error {
                print("Reguest error : \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data")
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(WeatherData.self, from: data)
                DispatchQueue.main.async {
                    self.temperature = "\(Int(decodedData.main.temp))°C"
                    self.condition = decodedData.weather.first?.description.capitalized ?? "Unknown"
                    self.clothingAdvice = generateAdvice(for: decodedData.main.temp)
                    self.iconCode = decodedData.weather.first?.icon ?? ""
                    self.weatherSymbol = mapConditionToSymbol(decodedData.weather.first?.main ?? "")
                }
            } catch {
                print("Decoing error: \(error)")
            }
        }.resume()
    }
    
    func generateAdvice(for temp: Double) -> String {
        switch temp {
        case ..<5:
            return "🧥Wery cold. To wear a warm jacket!"
        case 5..<15:
            return "🧣Cold. Scarf and jacket would be better."
            
        case 15..<25:
            return "👕It is quite comfortable. You can weat a shirt."
            
        default:
            return "☀️It is quite warm! You can wear something light and drink more water."
        }
    }
    
    func mapConditionToSymbol(_ condition: String) -> String {
        switch condition.lowercased {
        case "clear":
            return "sun.max.fill"
        case "clouds":
            return "cloud.fill"
        case "rain":
            return "cloud.rain.fill"
        case "drizzle":
            return "cloud.drizzle.fill"
        case "thunderstorm":
            return "cloud.bolt.rain.fill"
        case "snow":
            return "snow"
        case "mist", "fog":
            return "cloud.fog.fill"
        default:
            return "questionmark"
        }
    }
    
}


#Preview {
    ContentView()
}
