//
//  LocationService.swift
//  WeatherSheet
//
//  Created by 김인환 on 10/27/24.
//

import Foundation
import CoreLocation
import Dependencies

struct LocationService {
    var currentLocation: @MainActor () async throws -> CLLocation?
}

extension LocationService: DependencyKey {
    private static func live() -> Self {
        Self(
            currentLocation: {
                let locationService = LocationManagerCoordinator()
                return try await locationService.currentLocation()
            }
        )
    }
    
    static let liveValue: Self = live()
    
    static let previewValue: Self = .init(
        currentLocation: { CLLocation(latitude: 37.5667, longitude: 126.978) }
    )
}

extension DependencyValues {
    var locationService: LocationService {
        get { self[LocationService.self] }
        set { self[LocationService.self] = newValue }
    }
}

final class LocationManagerCoordinator: NSObject, CLLocationManagerDelegate {
    private let locationManager: CLLocationManager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocation, any Error>?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.requestWhenInUseAuthorization()
    }
    
    func currentLocation() async throws -> CLLocation {
        try await withCheckedThrowingContinuation { continuation in
            locationContinuation = continuation
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            locationContinuation?.resume(returning: location)
            locationContinuation = nil
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        locationContinuation?.resume(throwing: error)
        locationContinuation = nil
    }
}
