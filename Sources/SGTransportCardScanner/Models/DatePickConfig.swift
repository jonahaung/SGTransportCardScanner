//
//  File.swift
//  
//
//  Created by Aung Ko Min on 12/7/23.
//

import Foundation

public struct DatePickConfig {
    lazy var dateFormatterForDatePicker: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMyyyy"
        return formatter
    }()
    
    lazy var dateFormatterForDisplay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()
    
    var maximumDate: Date
    var minimumDate: Date
    var currentDate: Date
    
    init(currentDate: Date, maximumDate: Date, minimumDate: Date) {
        self.currentDate = currentDate
        self.maximumDate = maximumDate
        self.minimumDate = minimumDate
    }
    
    mutating func birthdayFormatter(_ birthday: String) -> String {
        if birthday.trimString.isEmpty {
            return ""
        }
        let birthdayDate = dateFormatterForDatePicker.date(from: birthday) ?? Date()
        return dateFormatterForDisplay.string(from: birthdayDate)
    }
    
    static var `default`: DatePickConfig {
        var configuration = DatePickConfig(currentDate: Date(), maximumDate: Date(), minimumDate: Date())
        let today = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: today)
        let month = calendar.component(.month, from: today)
        let day = calendar.component(.day, from: today)
        if let current = configuration.dateFormatterForDisplay.date(from: "\(day)/\(month)/\(year - 10)") {
            configuration.currentDate = current
        }
        configuration.maximumDate = today
        configuration.minimumDate = configuration.dateFormatterForDisplay.date(from: "01/01/1900")!
        return configuration
    }
}
