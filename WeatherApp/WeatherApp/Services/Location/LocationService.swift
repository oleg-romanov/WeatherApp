//
//  LocationService.swift
//  WeatherApp
//
//  Created by Олег Романов on 23.03.2024.
//

import Foundation
import CoreLocation

protocol LocationServiceDelegate: AnyObject {
    func locationServiceDidUpdate(with location: UserLocation)
    func locationServiceDidFail(with error: Error)
    func locationServiceAuthIsSuccess()
    func locationServiceAuthIsFailure()
}

final class LocationService: NSObject {
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    weak var delegate: LocationServiceDelegate?
    
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func getLocation() {
        locationManager.requestLocation()
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                delegate?.locationServiceAuthIsSuccess()
            case .restricted, .denied:
                delegate?.locationServiceAuthIsFailure()
            default:
                return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }

        geocoder.reverseGeocodeLocation(location, preferredLocale: .autoupdatingCurrent) { [weak self] placemarks, error in
            if let error = error {
                self?.delegate?.locationServiceDidFail(with: error)
            }
            guard let placemark = placemarks?.first else { return }
            
            let userLocation = UserLocation(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                locality: placemark.locality,
                subLocality: placemark.subLocality
            )
            
            self?.delegate?.locationServiceDidUpdate(with: userLocation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.locationServiceDidFail(with: error)
    }
}
