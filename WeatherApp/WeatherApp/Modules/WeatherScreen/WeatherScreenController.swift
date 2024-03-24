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
    func fetchUserLocation(location: UserLocation) {
        print(location)
    }
    
    func showLocationError(with message: String) {
        print(message)
    }
}

