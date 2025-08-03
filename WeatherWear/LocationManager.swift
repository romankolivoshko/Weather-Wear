//
//  LocationManager.swift
//  WeatherWear
//
//  Created by romankolivoshko on 02.08.2025.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var location: CLLocationCoordinate2D?
    @Published var lastLocation: CLLocation?
    @Published var city: String = "-"
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager (_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.first {
            self.location = loc.coordinate
            self.lastLocation = loc
            getCityName(from: loc) {[weak self] cityName in
                DispatchQueue.main.async {
                    self?.city = cityName ?? "Unknown"
                }
            }
            manager.stopUpdatingLocation()
        }
    }
    
    func getCityName(from location: CLLocation, completion: @escaping (String?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first {
                completion(placemark.locality)
            } else {
                completion(nil)
            }
        }
    }
}
