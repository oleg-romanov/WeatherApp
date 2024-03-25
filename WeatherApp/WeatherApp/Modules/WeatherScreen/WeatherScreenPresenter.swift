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
    
    private let dateFormatter: DateFormatter = DateFormatter()
    
    init(view: WeatherScreenViewInput, locationService: LocationService = LocationService()) {
        self.view = view
        self.locationService = locationService
        networkService = APIClient(baseURL: URL(string: APIConstants.baseURL))
        locationService.delegate = self
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "Ru")
    }
    
    private func getDateAndWeekday(dateString: String) -> (date: String, weekday: String) {
        dateFormatter.dateFormat = "yyyy-MM-dd"
    
        guard let date = dateFormatter.date(from: dateString) else {
            print("Ошибка при преобразовании строки в дату")
            fatalError()
        }
        
        dateFormatter.dateFormat = "d MMMM"
        let formattedDate = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "EEEE"
        let weekday = dateFormatter.string(from: date)
        
        return (formattedDate, weekday)
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
            ("units", "\(units)"),
            ("lang", "ru")
        ]
        
        do {
            let currWeather: CurrentWeather = try await networkService.send(Request(path: "/weather", query: query)).value
            await MainActor.run {
                view?.displayCurrentWeather(currWeather: currWeather)
            }
        } catch {
            await MainActor.run {
                view?.showErrorAlert(with: error.localizedDescription)
            }
        }
    }
    
    func getDailyWeather(by location: UserLocation) async {
        let latitude = location.latitude
        let longitude = location.longitude
        let appId = APIConstants.appId
        let units = APIConstants.units
        let query: [(String, String?)] = [
            ("lat", "\(latitude)"),
            ("lon", "\(longitude)"),
            ("appid", "\(appId)"),
            ("units", "\(units)"),
            ("lang", "ru")
        ]
        
        do {
            let dailyWeather: DailyWeather = try await networkService.send(Request(path: "/forecast", query: query)).value
            
            let data: [Temp] = dailyWeather.list.compactMap { item in
                let date = item.dtTxt.split(separator: " ").first
                let time = item.dtTxt.split(separator: " ").last
                
                if (time == "12:00:00" || time == "21:00:00") {
                    return Temp(dateString: String(date!), timeString: String(time!), temp: item.main.temp)
                } else {
                    return nil
                }
            }
            
            var prevItem: Temp?
            
            var dailyWeatherDTOs = [DailyWeatherDTO]()
            
            for item in data {
                if let prevItem = prevItem, prevItem.dateString == item.dateString {
                    var dailyWeatherDTO: DailyWeatherDTO
                    let (date, weekday) = getDateAndWeekday(dateString: item.dateString)
                    if prevItem.timeString == "12:00:00", item.timeString == "21:00:00" {
                        dailyWeatherDTO = DailyWeatherDTO(date: date, weekday: weekday, dayTemp: "\(Int(prevItem.temp))", eveningTemp: "\(Int(item.temp))")
                    } else {
                        dailyWeatherDTO = DailyWeatherDTO(date: date, weekday: weekday, dayTemp: "\(Int(item.temp))", eveningTemp: "\(Int(prevItem.temp))")
                    }
                    dailyWeatherDTOs.append(dailyWeatherDTO)
                }
                prevItem = item
            }
            
            let dailyWeatherDTOsCopy = dailyWeatherDTOs
            
            await MainActor.run {
                view?.displayDailyWeather(dailyWeather: dailyWeatherDTOsCopy)
            }
        } catch {
            await MainActor.run {
                view?.showErrorAlert(with: error.localizedDescription)
            }
        }
    }
}

struct Temp {
    let dateString: String
    let timeString: String
    let temp: Double
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
