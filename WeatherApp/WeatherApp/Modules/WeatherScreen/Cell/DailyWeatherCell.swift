//
//  DailyWeatherCell.swift
//  WeatherApp
//
//  Created by Олег Романов on 25.03.2024.
//

import UIKit

final class DailyWeatherCell: UITableViewCell {
    
    private struct Appearance {
        let dateStackViewTopAnchor: CGFloat = 8
        let dateStackViewLeadingAnchor: CGFloat = 16
        let dateStackViewBottomAnchor: CGFloat = -8
        
        let weatherInfStackViewTopAnchor: CGFloat = 8
        let weatherInfStackViewTrailingAnchor: CGFloat = -16
        let weatherInfStackViewBottomAnchor: CGFloat = -8
        
        let dateLabelMinHeight: CGFloat = 20
        let weekDayLabelMinHeight: CGFloat = 24
    }
    
    private let appearance = Appearance()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private let weekDayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    private let maxTempLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    private let minTempLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    private lazy var dateStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [dateLabel, weekDayLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        return stackView
    }()
    
    private lazy var weatherInfStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [maxTempLabel, minTempLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 24
        stackView.alignment = .center
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        setupStyle()
        addSubviews()
        makeConstraints()
    }
    
    private func setupStyle() {
        backgroundColor = .white
    }
    
    private func addSubviews() {
        self.contentView.addSubview(dateStackView)
        self.contentView.addSubview(weatherInfStackView)
    }
    
    private func makeConstraints() {
        NSLayoutConstraint.activate([
            dateStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: appearance.dateStackViewTopAnchor),
            dateStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: appearance.dateStackViewLeadingAnchor),
            dateStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: appearance.dateStackViewBottomAnchor),
            
            weatherInfStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: appearance.weatherInfStackViewTopAnchor),
            weatherInfStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: appearance.weatherInfStackViewTrailingAnchor),
            weatherInfStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: appearance.weatherInfStackViewBottomAnchor),
            
            dateLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: appearance.dateLabelMinHeight),
            weekDayLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: appearance.weekDayLabelMinHeight)
        ])
    }
    
    func configure(day: DailyWeatherDTO) {
        dateLabel.text = day.date
        weekDayLabel.text = day.weekday
        maxTempLabel.text = day.dayTemp
        minTempLabel.text = day.eveningTemp
    }
}

struct DailyWeatherDTO {
    let date: String
    let weekday: String
    var dayTemp: String
    var eveningTemp: String
}
