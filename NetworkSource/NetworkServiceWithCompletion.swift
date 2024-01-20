//
//  NetworkServiceWithCompletion.swift
//  Movies Geek
//
//  Created by ADW User KHQ on 14/09/23.
//

import Foundation

struct NetworkWithServiceCompletion{
    // MARK: Gunakan API Key dalam akun Anda.
      let apiKey = "9e7a7f77b46d7a67e582a72634fa4c78"
      let language = "en-US"
      let page = "1"
    
    func getMovies(
        completion: @escaping([Movie]) -> Void
    ){
        var components = URLComponents(string: "https://api.themoviedb.org/3/movie/popular")!
        components.queryItems = [
          URLQueryItem(name: "api_key", value: apiKey),
          URLQueryItem(name: "language", value: language),
          URLQueryItem(name: "page", value: page)
        ]
        let request = URLRequest(url: components.url!)
        let task = URLSession.shared.dataTask(with: request){data, response, error in
            guard let response = response as? HTTPURLResponse, let data = data else {return}
            if response.statusCode == 200{
                let decoder = JSONDecoder()
                do{
                    let result = try decoder.decode(MoviesResponse.self, from: data)
                    completion(movieMapper(input: result.movies))
                }catch{
                    print("Error: Can't decode JSON.")
                }
            }else{
                print("ERROR: \(data), HTTP Status: \(response.statusCode)")
            }
        }
        task.resume()
    }
}
