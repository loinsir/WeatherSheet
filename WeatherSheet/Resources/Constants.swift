//
//  Constants.swift
//  WeatherSheet
//
//  Created by 김인환 on 10/15/24.
//

import Foundation

enum Constants {
    static let API_KEY: String = {
        Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String ?? ""
    }()
}
