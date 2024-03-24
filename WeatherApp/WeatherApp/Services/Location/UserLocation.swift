//
//  UserLocation.swift
//  WeatherApp
//
//  Created by Олег Романов on 24.03.2024.
//

import Foundation
import CoreLocation

struct UserLocation {
    /// Широта
    let latitude: CLLocationDegrees
    /// Долгота
    let longitude: CLLocationDegrees
    /// Город
    let locality: String?
    /// Улица
    let subLocality: String?
}
