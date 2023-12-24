//
//  SavaPortfolioButton.swift
//  CryptoPortfolio
//


import SwiftUI

//MARK: Save Portfolio Button Style
struct ButtonStyles: ButtonStyle {
    
    let scale  : CGFloat
    let opacity: CGFloat
    
    init(scale: CGFloat, opacity: CGFloat) {
        self.scale = scale
        self.opacity = opacity
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.theme.red)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .padding(.horizontal)
            .shadow(color: .red.opacity(0.5), radius: 10, x: 0, y: 10)
        
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .opacity(configuration.isPressed ? opacity : 1.0)
            .brightness(configuration.isPressed ? 0.3 : 0.0)
    }
}

//MARK: Extension for ButtonStyles
extension View {
    
    func buttonMode(scale: CGFloat = 0.9, opacity: CGFloat = 0.9) -> some View {
        buttonStyle(ButtonStyles(scale: scale, opacity: opacity))
    }
}

