//
//  HomeViewModel - керує даними та логікою для головного екрану додатку
//


import Foundation
import Combine

// Головний клас моделі подання для головного екрану
final class HomeViewModel: ObservableObject {
    
    // Властивості моделі, доступні для перегляду
    @Published var statistic: [StatisticModel] = []
    @Published var allCoins: [CoinModel] = []
    @Published var portfolioCoins: [CoinModel] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var sortOptions: SortOptions = .holdings
    
    // Службові властивості
    private var coinDataService: CoinDataServiceProtocol
    private let marketDataService = MarketDataService()
    private let portfolioCoreDataService = PortfolioCoreDataService()
    private var cancellable = Set<AnyCancellable>() // Для управління підписками Combine
    
    // Варіанти сортування
    enum SortOptions {
        case rank, rankReversed, holdings, holdingsReversed, price, priceReversed
    }
    
    // Ініціалізатор моделі
    init(coinDataService: CoinDataServiceProtocol) {
        self.coinDataService = coinDataService
        addSubscribers() // Додає підписки на зміни даних
    }
    
    // Додає підписки на зміни даних для оновлення моделі
    func addSubscribers() {
        // Підписка на зміни пошукового тексту, списку монет та варіанту сортування
        $searchText
            .combineLatest(coinDataService.publisher, $sortOptions)
            .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main) // Затримка 0.3 секунди перед обробкою
            .map(filterAndSort)
            .sink { [weak self] returnCoins in
                self?.allCoins = returnCoins
            }.store(in: &cancellable)
        
        // Підписка на зміни списку монет та даних портфеля з CoreData
        $allCoins
            .combineLatest(portfolioCoreDataService.$savedEntity)
            .map(mapAllCoinsToPortfolioCoins)
            .sink { [weak self] returnValue in
                guard let self = self else { return }
                self.portfolioCoins = self.sortPortfolioCoins(coins: returnValue)
            }.store(in: &cancellable)
        
        // Підписка на зміни ринкових даних та портфеля для оновлення статистики
        marketDataService.$marketData
            .combineLatest($portfolioCoins)
            .map(mapGlobalMarketData)
            .sink { [weak self] returnStats in
                self?.statistic = returnStats
                self?.isLoading = false  // Завершує анімацію завантаження
            }.store(in: &cancellable)
    }
    
    // Оновлення монети в портфелі в CoreData
    func updatePortfolio(coin: CoinModel, amount: Double) {
        portfolioCoreDataService.updatePortfolio(coin: coin, amount: amount)
    }
    
    // Перезавантаження даних
    func reloadData() {
        isLoading = true
        coinDataService.getCoins()
        marketDataService.getData()
        HapticManager.notification(type: .success) // Відтворює тактильний зворотний зв'язок
    }
    
    // Відображає монети портфеля з урахуванням даних про володіння
    private func mapAllCoinsToPortfolioCoins(allCoins: [CoinModel], portfolioCoins: [PortfolioEntity] ) -> [CoinModel] {
        allCoins
               .compactMap { (coin) -> CoinModel? in
                   // Знаходимо запис портфеля для цієї монети
                   guard let entity = portfolioCoins.first(where: { $0.coinID == coin.id }) else {
                       return nil
                   }
                   // Оновлюємо монету з даними про володіння
                   return coin.updateHoldings(amount: entity.amount)
               }
    }
    
    // Фільтрує та сортує монети відповідно до параметрів
    private func filterAndSort(text: String, coins: [CoinModel], sort: SortOptions) -> [CoinModel] {
        // Відфільтровує монети за пошуковим текстом
        var updateCoins = filterCoins(text: text, coins: coins)
        // Сортує відфільтровані монети
        sortCoins(sort: sort, coins: &updateCoins)
        return updateCoins
    }
    
    // Сортує монети за обраним варіантом сортування
    private func sortCoins(sort: SortOptions, coins: inout [CoinModel]) {
        switch sort {
        case .rank, .holdings:
            // Сортуємо за рангом за зростанням
            coins.sort(by: { $0.rank < $1.rank })
        case .rankReversed, .holdingsReversed:
            // Сортуємо за рангом за спаданням
            coins.sort(by: { $0.rank > $1.rank })
        case .price:
            // Сортуємо за ціною за спаданням
            coins.sort(by: { $0.currentPrice > $1.currentPrice })
        case .priceReversed:
            // Сортуємо за ціною за зростанням
            coins.sort(by: { $0.currentPrice < $1.currentPrice })
        }
    }
    
    // Сортує монети портфеля за вартістю володіння
    private func sortPortfolioCoins(coins: [CoinModel]) -> [CoinModel] {
        switch sortOptions {
        case .holdings:
            return coins.sorted(by: { $0.currentHoldingsValue > $1.currentHoldingsValue })
        case .holdingsReversed:
            return coins.sorted(by: { $0.currentHoldingsValue < $1.currentHoldingsValue })
        default :
            return coins // Без сортування
        }
    }
    
    // Фільтрує монети за пошуковим текстом
    private func filterCoins(text: String, coins: [CoinModel]) -> [CoinModel] {
        
        // Якщо пошуковий текст пустий, повертаємо всі монети без фільтрації
        guard !text.isEmpty else { return coins }
        
        // Переводимо пошуковий текст в нижній регістр для нечутливого до регістру пошуку
        let lowercasedText = text.lowercased()
        
        // Фільтруємо монети, порівнюючи пошуковий текст з назвою, символом або ідентифікатором монети
        return coins.filter { coin -> Bool in
            return coin.name.lowercased().contains(lowercasedText) ||
            coin.symbol.lowercased().contains(lowercasedText) ||
            coin.id.lowercased().contains(lowercasedText)
        }
    }
    
    // Перетворює ринкові дані в статистичні моделі
    private func mapGlobalMarketData(marketDataModel: MarketDataModel?, coins: [CoinModel]) -> [StatisticModel] {
        // Створюємо масив для збереження статистичних моделей
        var tempStats: [StatisticModel] = []
        
        // Перевіряємо наявність ринкових даних
        guard let data = marketDataModel else { return tempStats }
        
        // Додаємо статистику загального ринку:
        let marketCap = StatisticModel(title: "Market Cap", value: data.marketCap, percentageChange: data.marketCapChangePercentage24HUsd)
        let volume = StatisticModel(title: "24h Volume", value: data.volume)
        let dominance = StatisticModel(title: "BTC Dominance", value: data.BTCDominance)
        
        // Додаємо статистику портфеля:
        // Розраховуємо загальну вартість портфеля
        let portfolioValue =
            coins
            .map({ $0.currentHoldingsValue })
            .reduce(0, +)
        
        // Розраховуємо попередню вартість портфеля, щоб визначити зміну за 24 години
        let previousValue =
            coins
            .map { (coin) -> Double in
                let currentValue = coin.currentHoldingsValue
                let percentChange = (coin.priceChangePercentage24H ?? 0) / 100
                let previousValue = currentValue / (1 + percentChange)
                return previousValue
            }
            .reduce(0, +)
        
        // Розраховуємо зміну вартості портфеля за 24 години
        let percentageChange = ((portfolioValue - previousValue) / previousValue) * 100
        
        // Додаємо статистику портфеля до масиву
        let portfolio = StatisticModel(title: "Portfolio Value",
                                            value: portfolioValue.asCurrencyWith2(),
                                            percentageChange: percentageChange)
        
       
        tempStats.append(contentsOf: [marketCap, volume, dominance, portfolio])
        return tempStats
    }
}
