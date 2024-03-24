//
//  WeatherScreenProtocols.swift
//  WeatherApp
//
//  Created by Олег Романов on 23.03.2024.
//

import Foundation

protocol WeatherScreenViewInput: AnyObject {
    func fetchUserLocation(location: UserLocation)
    func showLocationError(with message: String)
}

protocol WeatherScreenViewOutput: AnyObject {
    func getUserLocation()
}
