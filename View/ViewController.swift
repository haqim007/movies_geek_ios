//
//  ViewController.swift
//  Movies Geek
//
//  Created by ADW User KHQ on 04/09/23.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var movieTableView: UITableView!
    private let pendingOperations = PendingOperations()
    
    private var movies: [Movie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        movieTableView.dataSource = self
        movieTableView.register(
            UINib(nibName: "MovieTableViewCell", bundle: nil),
            forCellReuseIdentifier: "movieTableViewCell")
    }

    fileprivate func startOperations(movie: Movie, indexPath: IndexPath){
        if movie.state == .new{
            startDownload(movie: movie, indexPath: indexPath)
        }
    }
    
    fileprivate func startDownload(movie: Movie, indexPath: IndexPath){
        // MARK: - GCD
        //        guard pendingOperations.downloadInProgress[indexPath] == nil else { return }
        //        let downloader = ImageDownloaderOld(movie: movie)
        //        downloader.completionBlock = {
        //            if downloader.isCancelled { return }
        //            DispatchQueue.main.async {
        //                self.pendingOperations.downloadInProgress.removeValue(forKey: indexPath)
        //                self.movieTableView.reloadRows(at: [indexPath], with: .automatic)
        //            }
        //        }
        //
        //        pendingOperations.downloadInProgress[indexPath] = downloader
        //        pendingOperations.downloadQueue.addOperation(downloader)
        
        // MARK: - Async/Await
        let imageDownloader = ImageDownloader()
        Task{
            do{
                let image = try await imageDownloader.downloadImage(url: movie.poster)
                movie.state = .downloaded
                movie.image = image
                self.movieTableView.reloadRows(at: [indexPath], with: .automatic)
            }catch{
                movie.state = .failed
                movie.image = nil
            }
        }
    } 
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // pilih salah satu untuk mencoba async/await atau completion handler
        Task{
            await getMoviesAsyncAwait()
        }
//        getMoviesWithCompletion()
        
    }
    
    func getMoviesAsyncAwait() async{
        let networkService = NetworkServiceAsyncAwait()
        do{
            movies = try await networkService.getMovies()
            movieTableView.reloadData()
        }catch{
            fatalError("Error: connection failed.")
        }
    }
    
    func getMoviesWithCompletion(){
        let networkService = NetworkWithServiceCompletion()
        networkService.getMovies{moviesData in
            self.movies = moviesData
            self.movieTableView.reloadData()
        }
    }
}


extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = movieTableView.dequeueReusableCell(withIdentifier: "movieTableViewCell", for: indexPath) as? MovieTableViewCell{
            let movie = movies[indexPath.row]
            cell.movieTitleLabel.text = movie.title
            cell.movieImage.image = movie.image
            
            if movie.state == .new{
                cell.indicatorLoading.isHidden = false
                cell.indicatorLoading.startAnimating()
                startOperations(movie: movie, indexPath: indexPath)
            }else{
                cell.indicatorLoading.stopAnimating()
                cell.indicatorLoading.isHidden = true
            }
            
            cell.indicatorLoading.startAnimating()
            return cell
        }else{
            return UITableViewCell()
        }
    }
    
    
}

extension ViewController: UIScrollViewDelegate{
    
    // untuk menghentikan sementara dan mengaktifkan proses pengunduhan.
    fileprivate func toggleSuspendOperation(isSuspended: Bool){
        pendingOperations.downloadQueue.isSuspended = isSuspended
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        toggleSuspendOperation(isSuspended: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        toggleSuspendOperation(isSuspended: false)
    }
}
