//
//  CryptoPortfolioApp
//

import SwiftUI

@main
struct CryptoPortfolioApp: App {
    
    var body: some Scene {
        WindowGroup {
            
            // Створення сервісу для доступу до даних про криптовалюти
            let coinDataService = CoinDataService()  // Реальний сервіс
            
            // Можливість використання тестового сервісу
            //let coinDataService = MockCoinDataService()
            
            // Запуск головного екрану з передачею сервісу
            Main(vm: coinDataService )
    
        }
    }
}

