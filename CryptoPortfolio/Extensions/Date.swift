//
//  Date.swift
//  CryptoPortfolio
//



import Foundation

//MARK: Date Formator
extension Date {
    
    func asShortDateString() -> String {
        return shortFormatter.string(from: self)
    }
    
    init(coinGecoString: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = formatter.date(from: coinGecoString) ?? Date()
        self.init(timeInterval: 0, since: date)
    }
    
    private var shortFormatter: DateFormatter {
        let formatter = DateFormatter()
        /// Type of date
        formatter.dateStyle = .medium
        /// Local in this case - "en" - English
        formatter.locale = Locale(identifier: "en")
        return formatter
    }
}

