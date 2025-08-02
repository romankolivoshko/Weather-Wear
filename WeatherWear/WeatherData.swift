//
//  WeatherData.swift
//  WeatherWear
//
//  Created by romankolivoshko on 30.07.2025.
//

import Foundation

struct WeatherData: Codable {
    let main: Main
    let weather: [Weather]
}

struct Main: Codable {
    let temp: Double
}

struct Weather: Codable {
    let description: String
}
