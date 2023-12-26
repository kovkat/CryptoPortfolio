//
//  DetailViewModel.swift
//

import Foundation
import Combine

final class DetailViewModel: ObservableObject {
    
    @Published var coin: CoinModel
    @Published var overviewStatistic: [StatisticModel] = []
    @Published var detailsStatistic: [StatisticModel] = []
    @Published var coinDescription: String? = nil
    @Published var websiteURL: String? = nil
    @Published var redditURL: String? = nil
    
    private let coinDetailDataService: CoinDetailDataService
    private var cancellable = Set<AnyCancellable>()
    
    /// inject CoinModel
    init(coin: CoinModel) {
        self.coin = coin
        self.coinDetailDataService = CoinDetailDataService(coin: coin)
        addSubscriber()
    }

    private func addSubscriber() {
        /// Return - overviewStatistic and detailsStatistic
        coinDetailDataService.$coinDetails
            .combineLatest($coin)
            .map(mapDataToStatistic)
            .sink { [weak self] returnArrays in
                self?.overviewStatistic = returnArrays.overview
                self?.detailsStatistic = returnArrays.details
            }.store(in: &cancellable)
        
        /// Return - coinDescription, websiteURL, redditURL
        coinDetailDataService.$coinDetails
            .sink { [weak self] returnDescriptions in
                self?.coinDescription = returnDescriptions?.readableDescription
                self?.websiteURL = returnDescriptions?.links?.homepage?.first
                self?.redditURL = returnDescriptions?.links?.subredditURL
            }.store(in: &cancellable)
    }
    
    /// Convert coinDetails into two array -> overviewStatistic and detailsStatistic
    private func mapDataToStatistic(coinDetail: CoinDetailsModel?, coinModel: CoinModel) -> (overview: [StatisticModel], details: [StatisticModel]) {
        /// Overview
        let price = coinModel.currentPrice.asCurrencyWith6()
        let pricePercentChange = coinModel.priceChangePercentage24H ?? 0
        let priceStat = StatisticModel(title: "Current Price", value: price, percentageChange: pricePercentChange)
        
        let marketCap = "$" + (coinModel.marketCap?.formattedWithAbbreviations() ?? "" )
        let marketCapPercentChange = coinModel.marketCapChangePercentage24H ?? 0
        let marketCapStat = StatisticModel(title: "Market Capitalisation", value: marketCap, percentageChange: marketCapPercentChange)
        
        let rank = "\(coinModel.rank)"
        let rankStat = StatisticModel(title: "Rank", value: rank)
        
        let volume = "$" + (coinModel.totalVolume?.formattedWithAbbreviations() ?? "" )
        let volumeStat = StatisticModel(title: "Volume", value: volume)
        
        let overviewArray: [StatisticModel] = [priceStat, marketCapStat, rankStat, volumeStat]
        
        /// Details
        let high = coinModel.high24H?.asCurrencyWith6() ?? "n/a"
        let highStat = StatisticModel(title: "24h High", value: high)
        
        let low = coinModel.low24H?.asCurrencyWith6() ?? "n/a"
        let lowStat = StatisticModel(title: "24h Low", value: low)
        
        let priceChange = coinModel.priceChange24H?.asCurrencyWith6() ?? "n/a"
        let pricePercentChange2 = coinModel.priceChangePercentage24H ?? 0
        let priceChangeStat = StatisticModel(title: "24h Price Change", value: priceChange, percentageChange: pricePercentChange2)
        
        let marketCapChange = "$" + (coinModel.marketCapChange24H?.formattedWithAbbreviations() ?? "")
        let marketCapPercentChange2 = coinModel.marketCapChangePercentage24H ?? 0
        let marketCapChangeStat = StatisticModel(title: "24h Market Cap Change", value: marketCapChange, percentageChange: marketCapPercentChange2)
        
        let blockTime = coinDetail?.blockTimeInMinutes ?? 0
        let blockTimeString = blockTime == 0 ? "n/a" : "\(blockTime)"
        let blockStat = StatisticModel(title: "Block Time", value: blockTimeString)
        
        let hashing = coinDetail?.hashingAlgorithm ?? "n/a"
        let hashingStat = StatisticModel(title: "Hashing Algorithm", value: hashing)
        
        let detailsArray: [StatisticModel] = [highStat, lowStat, priceChangeStat, marketCapChangeStat, blockStat, hashingStat]
    
        return ( overviewArray, detailsArray )
    }
}
