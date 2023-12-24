//
//  CoinDataService - отримує та керує даними про криптовалюту з API CoinGecko
//

import Foundation
import Combine

final class CoinDataService: CoinDataServiceProtocol {
    // Масив для зберігання отриманих даних про монети
    @Published var allCoins: [CoinModel] = []
    
    // Публікатор для генерування змін у масиві `allCoins`
    var publisher: Published<[CoinModel]>.Publisher { $allCoins }
    
    // Підписка для керування мережевими запитами
    var coinSubscription: AnyCancellable?
    
    init() {
        getCoins() // Отримання монет при ініціалізації
    }
    
    func getCoins() {
        // URL кінцевої точки API CoinGecko
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=250&page=1&sparkline=true&price_change_percentage=24h&locale=en") else {
            return
        }
        // Виконання мережевого запиту
        coinSubscription = NetworkingManager.download(url: url)
            .decode(type: [CoinModel].self, decoder: JSONDecoder()) // Декодування JSON-відповіді в об'єкти CoinModel
            .receive(on: DispatchQueue.main) // Отримання результатів на головному потоці
            .sink(receiveCompletion:(NetworkingManager.handleCompletion(_:)),  // Обробка подій завершення мережі
                  receiveValue: { [weak self] returnValue in
                self?.allCoins = returnValue // Оновлення масиву allCoins отриманими даними
                self?.coinSubscription?.cancel() // Скасування підписки після завершення
            })
    }
}
