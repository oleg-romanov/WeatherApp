//
//  WeatherScreenController.swift
//  WeatherApp
//
//  Created by Олег Романов on 23.03.2024.
//

import UIKit

final class WeatherScreenController: UIViewController {
    
    private struct Appearance {
        let stackViewTopAnchor: CGFloat = 40
        
        let subLocalityTopAnchor: CGFloat = 28
        
        let temperatureLabelTopAnchor: CGFloat = 24
        let temperatureLabelHeightAnchor: CGFloat = 80
        
        let tableViewTopAnchor: CGFloat = 36
        let tableViewLeadingAnchor: CGFloat = 8
        let tableViewTrailingAnchor: CGFloat = -8
        let tableViewCornerRadius: CGFloat = 20
        let cellReuseIdentifier: String = "DailyWeatherCell"
        let tableViewSectionHeaderText: String = "Погода на ближайшие дни:"
        
        let activityIndicatorTopAnchor: CGFloat = 16
        let activityIndicatorTrailingAnchor: CGFloat = -16
    }
    
    private let appearance = Appearance()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let spiner = UIActivityIndicatorView(style: .large)
        spiner.color = .white
        spiner.translatesAutoresizingMaskIntoConstraints = false
        spiner.isHidden = true
        return spiner
    }()
    
    private let subLocalityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.text = ""
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.font = .systemFont(ofSize: 30, weight: .medium)
        return label
    }()
    
    private let localityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.text = ""
        return label
    }()
    
    private let temperatureLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 80, weight: .regular)
        label.text = "--º"
        return label
    }()
    
    private let weatherDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    private let feelsLikeTempLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    private let minAndMaxTempLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [subLocalityLabel, localityLabel, temperatureLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16
        return stackView
    }()
    
    private lazy var descriptionStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [weatherDescriptionLabel, feelsLikeTempLabel, minAndMaxTempLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 6
        return stackView
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(DailyWeatherCell.self, forCellReuseIdentifier: appearance.cellReuseIdentifier)
        return tableView
    }()
    
    var presenter: WeatherScreenViewOutput?
    
    private var days = [DailyWeatherDTO]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        addSubviews()
        makeConstraints()
        activityIndicatorStartAnimating()
        presenter?.getUserLocation()
    }

    private func setup() {
        view.backgroundColor = UIColor.skyColor
        presenter = WeatherScreenPresenter(view: self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = appearance.tableViewCornerRadius
    }
    
    private func addSubviews() {
        view.addSubview(stackView)
        view.addSubview(descriptionStackView)
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
    }
    
    private func makeConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: appearance.stackViewTopAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            descriptionStackView.topAnchor.constraint(equalTo: stackView.bottomAnchor),
            descriptionStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            descriptionStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: descriptionStackView.bottomAnchor, constant: appearance.tableViewTopAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: appearance.tableViewLeadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: appearance.tableViewTrailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            activityIndicator.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: appearance.activityIndicatorTopAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: appearance.activityIndicatorTrailingAnchor)
        ])
    }
    
    private func activityIndicatorStartAnimating() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func activityIndicatorStopAnimating() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }

}

extension WeatherScreenController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        days.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: appearance.cellReuseIdentifier, for: indexPath) as? DailyWeatherCell
        cell?.configure(day: days[indexPath.row])
        
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        appearance.tableViewSectionHeaderText
    }
}

extension WeatherScreenController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension WeatherScreenController: WeatherScreenViewInput {
    func displayDailyWeather(dailyWeather: [DailyWeatherDTO]) {
        days = dailyWeather
        tableView.reloadData()
        activityIndicatorStopAnimating()
    }
    
    func displayCurrentWeather(currWeather: CurrentWeather) {
        temperatureLabel.text = "\(Int(currWeather.main.temp))º"
        weatherDescriptionLabel.text = currWeather.weather.first?.description
        feelsLikeTempLabel.text = "Ощущается как \(Int(currWeather.main.feelsLike))º"
        minAndMaxTempLabel.text = "Макс.: \(Int(currWeather.main.tempMax))º, мин.: \(Int(currWeather.main.tempMin))º"
        activityIndicatorStopAnimating()
    }
    
    func fetchCurrentWeather(by location: UserLocation) {
        subLocalityLabel.text = location.subLocality
        localityLabel.text = location.locality?.uppercased()
        Task {
            await presenter?.getCurrentWeather(by: location)
            await presenter?.getDailyWeather(by: location)
        }
    }
    
    func showErrorAlert(with message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
