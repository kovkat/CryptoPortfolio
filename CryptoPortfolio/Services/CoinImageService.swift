//
//  CoinImageService - це клас, який забезпечує доступ до зображень монет криптовалют
//

import SwiftUI
import Combine

final class CoinImageService {
    
    // Публікована властивість для доступу до зображення монети
    @Published var image: UIImage? = nil
    
    // Приватні властивості для керування завантаженням та зберіганням зображень
    private var imageSubscriber: AnyCancellable?
    private var coin: CoinModel
    private let fileManager = LocalFileManager.instance
    
    // Назва папки для зберігання зображень
    private let folderName = "Crypto_Images"
    // Ім'я файлу зображення на основі ідентифікатора монети
    private let coinName: String
    
    // Ініціалізація сервісу з інформацією про монету
    init(coin: CoinModel) {
        self.coin = coin
        self.coinName = coin.id
        getCoinImage() // Отримання зображення монети під час ініціалізації
    }
    
    // Отримання зображення монети, спочатку перевіряючи локальне сховище, а потім завантажуючи його, якщо потрібно
    func getCoinImage() {
        // Якщо зображення можна отримати з fileManager, просто повернути його, інакше -> завантажити зображення та зберегти в fileManager
        if let savedImage = fileManager.getImage(imageName: coinName, folderName: folderName) {
            image = savedImage
            //print("Get Saved Image")
        } else {
            downloadCoinImage()
            //print("download Coin Image")
        }
    }
    
    // Завантаження зображення монети з API CoinGecko та збереження його локально
    private func downloadCoinImage() {
        // URL зображення монети CoinGecko
        guard let url = URL(string: coin.image) else { return }
        
        imageSubscriber = NetworkingManager.download(url: url)
            .tryMap({ data -> UIImage? in // Спроба перетворити отримані дані на UIImage
                return UIImage(data: data)
            })
            .receive(on: DispatchQueue.main) // Отримати результати на головному потоці
            .sink(receiveCompletion:(NetworkingManager.handleCompletion(_:)), receiveValue: { [weak self] returnImage in
                
                guard let self = self, let downloadImage = returnImage else { return }
                
                self.image = downloadImage // Оновити властивість image завантаженим зображенням
                self.imageSubscriber?.cancel() // Скасувати підписку після завершення
                
                // Зберегти в FileManager
                self.fileManager.saveImage(image: downloadImage, imageName: self.coinName, folderName: self.folderName)
            })
    }
}
