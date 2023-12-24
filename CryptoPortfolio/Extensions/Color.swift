//
//  Color.swift
//  CryptoPortfolio
//


import Foundation
import SwiftUI

extension Color {
    
    /// Color setUp for app
    static let theme = ColorTheme()
}

struct ColorTheme {
    
    let accent = Color("AccentColor")
    let background = Color("BackgroundColor")
    let green = Color("GreenColor")
    let red = Color("RedColor")
    let secondaryText = Color("SecondaryTextColor")
    let LaunchBackground = Color("LaunchBackground")
}

struct ColorTheme2 {
    
    let accent = Color.white
    let background = Color.black
    let green = Color.green
    let red = Color.red
    let secondaryText = Color.secondary
    let LaunchBackground = Color.black
}

