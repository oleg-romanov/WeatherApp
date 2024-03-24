//
//  WeatherScreenPresenter.swift
//  WeatherApp
//
//  Created by Олег Романов on 23.03.2024.
//

import Foundation
import CoreLocation

final class WeatherScreenPresenter {
    private weak var view: WeatherScreenViewInput?
    
    private let locationService: LocationService
    
    init(view: WeatherScreenViewInput, locationService: LocationService = LocationService()) {
        self.view = view
        self.locationService = locationService
        locationService.delegate = self
    }
}

extension WeatherScreenPresenter: WeatherScreenViewOutput {
    func getUserLocation() {
        locationService.requestAuthorization()
    }
}

extension WeatherScreenPresenter: LocationServiceDelegate {
    func locationServiceAuthIsSuccess() {
        locationService.getLocation()
    }
    
    func locationServiceAuthIsFailure() {
        view?.showLocationError(with: "Location services are not avaliable, please change your location settings in Settings")
    }
    
    func locationServiceDidUpdate(with location: UserLocation) {
        view?.fetchUserLocation(location: location)
    }
    
    func locationServiceDidFail(with error: Error) {
        view?.showLocationError(with: error.localizedDescription)
    }
}
