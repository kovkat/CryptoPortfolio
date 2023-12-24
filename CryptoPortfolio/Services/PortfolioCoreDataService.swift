//
//  PortfolioCoreDataService -  клас, який забезпечує зберігання даних портфеля криптовалют у Core Data
//

import Foundation
import CoreData

final class PortfolioCoreDataService {
    
    // Публікована властивість для доступу до збережених даних портфеля
    @Published var savedEntity: [PortfolioEntity] = []
    
    // Приватна властивість для керування Core Data
    private let container: NSPersistentContainer
    
    // Назви контейнера та сутності Core Data
    private let nameOfContainer = "PortfolioData"
    private let nameOfEntity = "PortfolioEntity"
    
    init() {
        // Створення контейнера Core Data
        container = NSPersistentContainer(name: nameOfContainer)
        
        // Завантаження сховищ даних Core Data
        container.loadPersistentStores { _ , error in
            if let error = error {
                print("[🔥] Error download CoreData: \(error.localizedDescription)")
            }
        }
        // Отримання даних портфеля з Core Data
        getPortfolio()
    }
    
    // MARK: - Публічні методи
    func updatePortfolio(coin: CoinModel, amount: Double) {
        
        // Перевірка наявності монети в портфелі
        if let entity = savedEntity.first(where: { $0.coinID == coin.id }) {
            
            if amount > 0 {   // Якщо кількість монет більша за 0, оновити її
                updateCoin(entity: entity, amount: amount)
            } else {  // Якщо кількість монет менша або дорівнює 0, видалити її з портфеля
                deleteCoin(entity: entity)
            }
        } else {  // Якщо монети немає в портфелі, додати її
            addCoin(coin: coin, amount: amount)
        }
    }
    
    //MARK: - Приватні методи
    // Додавання нової монети до портфеля
    private func addCoin(coin: CoinModel, amount: Double) {
        let entity = PortfolioEntity(context: container.viewContext)
        entity.coinID = coin.id
        entity.amount = amount
        applyChanges()
    }
    
    // Оновлення кількості монети в портфелі
    private func updateCoin(entity: PortfolioEntity, amount: Double) {
        entity.amount = amount
        applyChanges()
    }
    
    // Видалення монети з портфеля
    private func deleteCoin(entity: PortfolioEntity) {
        container.viewContext.delete(entity)
        applyChanges()
    }
    
    // Отримання всіх даних портфеля з Core Data
    private func getPortfolio() {
        let request = NSFetchRequest<PortfolioEntity>(entityName: nameOfEntity)
        do {
            savedEntity = try container.viewContext.fetch(request)
        } catch let error {
            print("[🔥] Error fetching CoreData: \(error.localizedDescription)")
        }
    }
    
    // Збереження змін у Core Data
    private func saveData() {
        do {
            try container.viewContext.save()
        } catch let error {
            print("[🔥] Error saving CoreData: \(error.localizedDescription)")
        }
    }
    
    // Перезавантаження даних з Core Data після змін
    private func applyChanges() {
        saveData()
        getPortfolio()
    }
}
