//
//  SearchBarView -  забезпечує функціональність пошуку в додатку
//

import SwiftUI

struct SearchBarView: View {
    
    // Зв'язування для тексту пошуку
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            // Іконка пошуку
            Image(systemName: "magnifyingglass")
                .foregroundColor(searchText.isEmpty ? Color.theme.secondaryText : Color.theme.accent)
            
            // Поле введення тексту
            TextField("Search by name or symbol ...", text: $searchText)
                .accessibilityIdentifier("home_TextField_ID") // Ідентифікатор доступності
                .keyboardType(.asciiCapable)  // Тип клавіатури для символів ASCII
                .autocorrectionDisabled(true)  // Вимкнути автокорекцію
                .textContentType(.init(rawValue: ""))  // Вимкнути автозаповнення
                .foregroundColor(Color.theme.accent)
                .overlay (
                    // Іконка очищення, якщо поле не порожнє
                    Image(systemName: "xmark")
                        .foregroundColor(searchText.isEmpty ? Color.theme.secondaryText : Color.theme.accent)
                        .padding(.all, 12)
                        .background(Color.theme.background) // Додаткова область натискання
                        .opacity(searchText.isEmpty ? 0.0 : 1.0)
                        .offset(x: 5)
                        .onTapGesture {
                            hideKeyboard()
                            searchText = ""
                        }
                    ,alignment: .trailing
                )
        }
        .padding(.all, 14)
        .font(.headline)
        .background(  // Фонова область із заокругленням та тінню
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.theme.background)
                .shadow(color: Color.theme.accent.opacity(0.2),
                        radius: 10)
        )
        .padding()
    }
}

// MARK: - Попередній перегляд
struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarView(searchText: .constant(""))
    }
}
