//
//  XMarkButton.swift
//  CryptoPortfolio
//



import SwiftUI

struct DismissButton: View {
    
    @Environment(\.dismiss) var goBack
    
    var body: some View {
        Button {
            hideKeyboard()
            goBack()
        } label: {
            Image(systemName: "arrowshape.turn.up.backward.2")
                .accessibilityIdentifier("dismiss_Button_ID")
                .font(.headline)
                .foregroundColor(Color.theme.red)
        }
        .padding(10)
    }
}

//                🔱
struct XMarkButton_Previews: PreviewProvider {
    static var previews: some View {
        DismissButton()
    }
}

