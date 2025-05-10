//
//  LocationManager.swift
//  ConnectUIKit
//
//  Created by Alibek Baisholanov on 06.04.2025.
//

import CoreLocation
import Combine

final class LocationManager: NSObject, CLLocationManagerDelegate {
    // MARK: - Public properties
    @Published var userLocation: CLLocation?
    
    // MARK: - Private porperties
    private let locationManager = CLLocationManager()
    
    // MARK: - Initializer
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // MARK: - Public methods
    func requestLocationAccess(){
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
    }
    
}
