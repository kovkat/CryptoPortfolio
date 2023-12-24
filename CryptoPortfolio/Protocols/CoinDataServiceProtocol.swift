//
//  CoinDataServiceProtocol.swift
//  CryptoPortfolio
//



import Foundation
import Combine

protocol CoinDataServiceProtocol {
    
    var publisher: Published<[CoinModel]>.Publisher { get }
    
    var coinSubscription: AnyCancellable?           { get }
    
    func getCoins()
}

