//
//  WeatherScreenProtocols.swift
//  WeatherApp
//
//  Created by Олег Романов on 23.03.2024.
//

import Foundation

protocol WeatherScreenViewInput: AnyObject {
    func fetchCurrentWeather(by location: UserLocation)
    func displayDailyWeather(dailyWeather: [DailyWeatherDTO])
    func displayCurrentWeather(currWeather: CurrentWeather)
    func showErrorAlert(with message: String)
}

protocol WeatherScreenViewOutput: AnyObject {
    func getUserLocation()
    func getCurrentWeather(by location: UserLocation) async
    func getDailyWeather(by location: UserLocation) async
}
