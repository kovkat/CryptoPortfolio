//
//  StatistikBarView - відображає дані про одну статистику у вигляді бару
//

import SwiftUI

struct StatisticBarView: View {
    
    let statistic: StatisticModel // Дані статистики для відображення
    
    var body: some View {
        VStack (alignment: .leading, spacing: 4) {
            // Заголовок статистики
            Text(statistic.title)
                .font(.caption)
                .foregroundColor(Color.theme.secondaryText)
            
            // Значення статистики
            Text(statistic.value)
                .font(.headline)
                .foregroundColor(Color.theme.accent)
            
            // Відсоткова зміна (якщо є)
            HStack (spacing: 4) {
                // Іконка трикутника, що вказує на напрямок зміни
                Image(systemName: "triangle.fill")
                    .font(.caption2)
                    .rotationEffect(Angle(degrees: (statistic.percentageChange ?? 0) >= 0 ? 0 : 180))  // Повернути на 180 градусів для негативних змін
                
                // Текст із відсотковою зміною
                Text(statistic.percentageChange?.asPercentString() ?? "")
                    .font(.caption .bold())
            }
            .foregroundColor((statistic.percentageChange ?? 0) >= 0 ? Color.theme.green : Color.theme.red) // Колір залежно від знаку зміни
            .opacity(statistic.percentageChange == nil ? 0.0 : 1.0 ) // Приховати, якщо немає відсоткової зміни

        }
    }
}

// MARK: - Попередній перегляд
struct StatisticBarView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticBarView(statistic: dev.statThree)
    }
}
