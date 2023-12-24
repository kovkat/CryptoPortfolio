//
//  StatisticBarSection - відображає ряд статистичних даних у вигляді барів
//

import SwiftUI

struct StatisticBarSection: View {
    
    // Отримати доступ до даних головного екрана з середовища
    @EnvironmentObject private var vm: HomeViewModel
    // Зв'язування для керування видимістю портфеля
    @Binding var showPortfolio: Bool
    
    var body: some View {
        VStack {
            GeometryReader { geo in // Виміряти доступний простір
                HStack {
                    // Відобразити кожну статистику в окремому StatisticBarView
                    ForEach(vm.statistic) { stat in
                        StatisticBarView(statistic: stat)
                            .frame(width: geo.size.width / 3)  // Поділити простір на 3 рівних частини
                    }
                }
                .frame(width: geo.size.width, alignment: showPortfolio ? .trailing : .leading) // Вирівняти залежно від видимості портфеля
            }
        }
        .frame(height: 50)  // Задати висоту в 50 пунктів
    }
}

// MARK: - Попередній перегляд
struct StatisticBarSection_Previews: PreviewProvider {
    static var previews: some View {
        StatisticBarSection(showPortfolio: .constant(false))
            .environmentObject(dev.homeVM) // Надати дані для попереднього перегляду
    }
}
