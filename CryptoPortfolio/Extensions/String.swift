//
//  String.swift
//  CryptoPortfolio
//



import Foundation

extension String {
    
    var removingHTMLOccurrences: String {
        /// Replace HTML code to ---> Void
        return self.replacingOccurrences(of: "<[^>]+>", with: "" ,options: .regularExpression)
    }
}

