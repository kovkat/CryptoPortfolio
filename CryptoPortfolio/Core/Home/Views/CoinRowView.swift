//
//  CoinRowView
//

import SwiftUI

struct CoinRowView: View {
    
    let coin: CoinModel // Модель монети для відображення
    let showHoldingColumn: Bool // Чи відображати стовпець із даними про кількість монет у портфелі
    
    var body: some View {
        GeometryReader { geo in // Адаптує вигляд до розміру екрану
            HStack (spacing: 0){ // Горизонтальний контейнер для елементів рядка
                
                leftColumn // Лівий стовпець з рейтингом, зображенням та символом
                
                Spacer() // Розділювач між стовпцями
                
                if showHoldingColumn {
                    centerColumn // Центральний стовпець із даними про кількість монет у портфелі (якщо потрібно)
                }
                
                rightColumn // Правий стовпець із ціною та зміною ціни
                    .frame(width: geo.size.width / 3.5, alignment: .trailing) // Фіксує ширину правого стовпця
            }
            .font(.subheadline) // Розмір шрифта для елементів
        }
    }
}

// Попередній перегляд
struct CoinRowView_Previews: PreviewProvider {
    static var previews: some View {
        CoinRowView(coin: dev.coin, showHoldingColumn: true)
    }
}

//MARK: - Components
private extension CoinRowView { // Приватні компоненти для структури CoinRowView
    
    var leftColumn: some View {
        HStack (spacing: 0) { // Лівий стовпець
            Text("\(coin.rank)") // Рейтинг монети
                .font(.caption)
                .foregroundColor(Color.theme.secondaryText) // Колір вторинного тексту
                .frame(minWidth: 30) // Мінімальна ширина
            
            CoinImageView(coin: coin) // Зображення монети
                .frame(width: 30, height: 30) // Розмір зображення
            
            Text(coin.symbol.uppercased()) // Символ монети великими літерами
                .font(.headline)
                .foregroundColor(Color.theme.accent) // Колір акценту
                .padding(.leading, 6) // Відступ зліва
        }
    }
    
    var centerColumn: some View {
        VStack (alignment: .trailing){ // Центральний стовпець
            Text(coin.currentHoldingsValue.asCurrencyWith2())
                .bold() // Значення монет у портфелі
            Text((coin.currentHoldings ?? 0).asNumberString()) // Кількість монет у портфелі
        }
        .foregroundColor(Color.theme.accent)  // Колір акценту
    }
    
    var rightColumn: some View {
        VStack(alignment: .trailing) { // Правий стовпець
            Text(coin.currentPrice.asCurrencyWith6()) // Поточна ціна монети
                .bold()
                .foregroundColor(Color.theme.accent)
            Text(coin.priceChangePercentage24H?.asPercentString() ?? "") // Зміна ціни за 24 години
                .foregroundColor( ((coin.priceChangePercentage24H ?? 0 ) >= 0 ?
                                   Color.theme.green :
                                    Color.theme.red))
        }
    }
}
