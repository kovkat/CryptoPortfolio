//
//  CoinDetailDataService отримує та керує детальними даними про криптовалюту з API CoinGecko
//

import Foundation
import Combine

final class CoinDetailDataService: CoinDetailDataServiceProtocol {
    
    // Масив для зберігання отриманих даних про монети
    @Published var coinDetails: CoinDetailsModel? = nil
    
    // Публікатор для генерування змін у масиві `coinDetails`
    var publisher: Published<CoinDetailsModel?>.Publisher { $coinDetails }
    
    // Підписка для керування мережевими запитами
    var coinDetailSubscription: AnyCancellable?
    let coin: CoinModel  // Монета, для якої потрібно отримати деталі
    
    init(coin: CoinModel) {
        self.coin = coin
        getCoinDetails() // Отримання деталей при ініціалізації
    }
    
    func getCoinDetails() {
        // URL кінцевої точки API CoinGecko, включаючи ідентифікатор монети
        guard let url = URL(string:"https://api.coingecko.com/api/v3/coins/\(coin.id)?localization=false&tickers=false&market_data=false&community_data=false&developer_data=false&sparkline=false") else {
            return
        }
        // Виконання мережевого запиту
        coinDetailSubscription = NetworkingManager.download(url: url)
            .decode(type: CoinDetailsModel.self, decoder: JSONDecoder()) // Декодування JSON-відповіді в об'єкти CoinDetailsModel
            .receive(on: DispatchQueue.main) // Отримання результатів на головному потоці
            .sink(receiveCompletion:(NetworkingManager.handleCompletion(_:)), // Обробка подій завершення мережі
                  receiveValue: { [weak self] returnCoinDetails in
                self?.coinDetails = returnCoinDetails // Оновлення властивості coinDetails
                self?.coinDetailSubscription?.cancel() // Скасування підписки після завершення
            })
    }
}
