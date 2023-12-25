

import SwiftUI

final class LocalFileManager {
    
    static let instance = LocalFileManager()
    
    private init() {}
    
    func saveImage(image: UIImage, imageName: String, folderName: String) {
        
        /// create folder if this folder doesn't exist
        createFolderIfNeed(folderName: folderName)
        
        /// Get path for image
        guard let data = image.pngData(),
              let url = getUrlForImage(imageName: imageName, folderName: folderName) else {
            return
        }
        /// Save image to path
        do {
            try data.write(to: url)
        } catch let error {
            print("[🔥] Error saving image: \(imageName) - \(error.localizedDescription)")
        }
    }
    
    func getImage(imageName: String, folderName: String) -> UIImage? {
        
        guard
            /// Get image path
            let url = getUrlForImage(imageName: imageName, folderName: folderName),
            /// Check if image exist
            FileManager.default.fileExists(atPath: url.path()) else {
            return nil
        }
        /// If image image exist -> return image
        return UIImage(contentsOfFile: url.path())
    }
    
    private func createFolderIfNeed(folderName: String) {
        
        guard let url = getUrlForFolder(folderName: folderName) else { return }
        
        /// If directory doesn't exist -> create
        if !FileManager.default.fileExists(atPath: url.path()) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            } catch let error {
                print("[🔥] Error creating directory: \(error.localizedDescription)")
            }
        }
    }
    
    private func getUrlForFolder(folderName: String) -> URL? {
        
        guard let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return nil }
        
        return url.appendingPathComponent(folderName, conformingTo: .folder)
    }
    
    private func getUrlForImage(imageName: String, folderName: String) -> URL? {
        
        guard let folder = getUrlForFolder(folderName: folderName) else { return nil }
        
        return folder.appendingPathComponent(imageName, conformingTo: .png)
    }
}
