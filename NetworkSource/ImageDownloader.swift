//
//  ImageDownloader.swift
//  Movies Geek
//
//  Created by ADW User KHQ on 04/09/23.
//

import Foundation
import UIKit

// MARK: - GCD
class ImageDownloaderOld: Operation {
    private var movie: Movie
    
    init(movie: Movie) {
        self.movie = movie
    }
    
    override func main() {
        if isCancelled{
            return
        }
        guard let imageData = try? Data(contentsOf: self.movie.poster) else { return }
        if isCancelled{
            return
        }
        if !imageData.isEmpty{
            self.movie.image = UIImage(data: imageData)
            self.movie.state = .downloaded
        }else{
            self.movie.image = nil
            self.movie.state = .failed
        }
    }
}

// MARK: - Async Await
class ImageDownloader {
 
    func downloadImage(url: URL) async throws -> UIImage {
        async let imageData: Data = try Data(contentsOf: url)
        return UIImage(data: try await imageData)!
    }
}

class PendingOperations{
    lazy var downloadInProgress: [IndexPath: Operation] = [:]
    lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "dev.haqim.imageDownload"
        queue.maxConcurrentOperationCount = 2
        return queue
    }()
    
    
}
