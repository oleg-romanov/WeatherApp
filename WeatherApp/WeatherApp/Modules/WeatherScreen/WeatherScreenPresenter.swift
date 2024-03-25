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
    
    private let networkService: APIClient
    
    private let locationService: LocationService
    
    init(view: WeatherScreenViewInput, locationService: LocationService = LocationService()) {
        self.view = view
        self.locationService = locationService
        networkService = APIClient(baseURL: URL(string: APIConstants.baseURL))
        locationService.delegate = self
    }
}

extension WeatherScreenPresenter: WeatherScreenViewOutput {
    func getUserLocation() {
        locationService.requestAuthorization()
    }
    
    func getCurrentWeather(by location: UserLocation) async {
        let latitude = location.latitude
        let longitude = location.longitude
        let appId = APIConstants.appId
        let units = APIConstants.units
        let query: [(String, String?)] = [
            ("lat", "\(latitude)"),
            ("lon", "\(longitude)"),
            ("appid", "\(appId)"),
            ("units", "\(units)")
        ]
        
        do {
            let currWeather: CurrentWeather = try await networkService.send(Request(path: "/weather", query: query)).value
            await MainActor.run {
                view?.displayCurrentWeather(weather: currWeather)
            }
        } catch {
            await MainActor.run {
                view?.showErrorAlert(with: error.localizedDescription)
            }
        }
        
    }
}

extension WeatherScreenPresenter: LocationServiceDelegate {
    func locationServiceAuthIsSuccess() {
        locationService.getLocation()
    }
    
    func locationServiceAuthIsFailure() {
        view?.showErrorAlert(with: "Location services are not avaliable, please change your location settings in Settings")
    }
    
    func locationServiceDidUpdate(with location: UserLocation) {
        view?.fetchCurrentWeather(by: location)
    }
    
    func locationServiceDidFail(with error: Error) {
        view?.showErrorAlert(with: error.localizedDescription)
    }
}
