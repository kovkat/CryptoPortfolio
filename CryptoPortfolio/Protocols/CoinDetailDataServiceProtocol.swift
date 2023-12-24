//
//  CoinDetailDataServiceProtocol.swift
//  CryptoPortfolio
//



import Foundation
import Combine

protocol CoinDetailDataServiceProtocol {
    
    var publisher: Published<CoinDetailsModel?>.Publisher { get }
    
    var coinDetailSubscription: AnyCancellable? { get }
    var coin: CoinModel { get }
    
    func getCoinDetails()
    
}

