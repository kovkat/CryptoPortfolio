//
//  MockCoinDataService - клас, який імітує роботу реального сервісу даних про криптовалюти та генерує фейкові дані про монети
//

import Foundation
import Combine

class MockCoinDataService: CoinDataServiceProtocol {
    
    // Публікована властивість для доступу до всіх монет
    @Published var allCoins: [CoinModel] = []
    
    // Отримувач для сповіщення про зміни в масиві монет
    var publisher: Published<[CoinModel]>.Publisher { $allCoins }
    
    // Приватна властивість для керування підпискою на дані
    var coinSubscription: AnyCancellable?
    
    init() {
        getCoins() // Отримати дані про монети при створенні сервісу
    }
    
    func getCoins() {
         
        // Тимчасовий масив для зберігання згенерованих даних
        var tempArray: [CoinModel] = []
        
        // Згенерувати 100 фейкових монет та додати їх до масиву з затримкою в 1 секунду
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            for item in 1...100 {
                let mockData = CoinModel(id: "bitcoin\(item)",  // дані монети
                                         symbol: "btc",
                                         name: "Bitcoin",
                                         image: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png?1547033579",
                                         currentPrice: 30400,
                                         marketCap: 588020969684,
                                         marketCapRank: 1,
                                         fullyDilutedValuation: 638168888742,
                                         totalVolume: 16513136866,
                                         high24H: 30443,
                                         low24H: 29277,
                                         priceChange24H: 1010.16,
                                         priceChangePercentage24H: 3.4371,
                                         marketCapChange24H: 18704493983,
                                         marketCapChangePercentage24H: 3.28543,
                                         circulatingSupply: 19349800,
                                         totalSupply: 21000000,
                                         maxSupply: 21000000,
                                         ath: 69045,
                                         athChangePercentage: 55.97128,
                                         athDate: "2021-11-10T14:24:11.849Z",
                                         atl: 67.81,
                                         atlChangePercentage: 44731.1159,
                                         atlDate: "2013-07-06T00:00:00.000Z",
                                         lastUpdated: "2023-04-18T13:56:01.620Z",
                                         sparklineIn7D: SparklineIn7D(price: [30023, 30000, 29990, 29987, 29800, 29770, 29766, 29500, 29456,29300,29200,28000,27650]),
                                         priceChangePercentage24HInCurrency: 3.43710112008458,
                                         currentHoldings: 1.77)
                tempArray.append(mockData)
            }
            self?.allCoins = tempArray // Оновити масив монет
        }
    }
}
