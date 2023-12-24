//
//  MarketDataService - клас, який забезпечує доступ 
// до даних про ринок криптовалют
//

import Foundation

import Foundation
import Combine

final class MarketDataService {
    
    // Публікована властивість для зберігання отриманих даних про ринок
    @Published var marketData: MarketDataModel? = nil
    
    // Підписка для керування мережевими запитами
    var marketDataSubscription: AnyCancellable?
    
    init() {
        getData() // Отримання даних про ринок при ініціалізації
    }
    
    func getData() {
        // URL кінцевої точки API CoinGecko для глобальних даних про ринок
        guard let url = URL(string: "https://api.coingecko.com/api/v3/global" ) else {
            return
        }
        // Виконання мережевого запиту
        marketDataSubscription = NetworkingManager.download(url: url)
            .decode(type: GlobalData.self, decoder: JSONDecoder()) // Декодування JSON-відповіді в GlobalData
            .receive(on: DispatchQueue.main) // Отримання результатів на головному потоці
            .sink(receiveCompletion:(NetworkingManager.handleCompletion(_:)),  // Обробка подій завершення мережі
                  receiveValue: { [weak self] returnGlobalData in
                
                // Вилучення MarketDataModel з GlobalData
                self?.marketData = returnGlobalData.data
                // Скасування підписки після завершення
                self?.marketDataSubscription?.cancel()
            })
    }
}
