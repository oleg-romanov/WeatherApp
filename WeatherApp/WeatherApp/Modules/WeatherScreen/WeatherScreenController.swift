//
//  WeatherScreenController.swift
//  WeatherApp
//
//  Created by Олег Романов on 23.03.2024.
//

import UIKit

final class WeatherScreenController: UIViewController {
    
    var presenter: WeatherScreenViewOutput?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        presenter?.getUserLocation()
    }

    private func setup() {
        presenter = WeatherScreenPresenter(view: self)
    }

}

extension WeatherScreenController: WeatherScreenViewInput {
    func displayCurrentWeather(weather: CurrentWeather) {
        print(weather)
    }
    
    func fetchCurrentWeather(by location: UserLocation) {
        Task {
            await presenter?.getCurrentWeather(by: location)
        }
    }
    
    func showErrorAlert(with message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
