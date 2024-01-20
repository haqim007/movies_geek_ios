//
//  NetworkServiceAsyncAwait.swift
//  Movies Geek
//
//  Created by ADW User KHQ on 14/09/23.
//

import Foundation

struct NetworkServiceAsyncAwait{
    let apiKey = "9e7a7f77b46d7a67e582a72634fa4c78"
    let language = "en-US"
    let page = "1"
    
    func getMovies() async throws -> [Movie]{
        var components = URLComponents(string: "https://api.themoviedb.org/3/movie/popular")!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "language", value: language),
            URLQueryItem(name: "page", value: page)
        ]
        let request = URLRequest(url: components.url!)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            fatalError("Error: Can't fetching data.")
        }
        
        let decoder = JSONDecoder()
        let result = try decoder.decode(MoviesResponse.self, from: data)
        return movieMapper(input: result.movies)
    }
}

func movieMapper(input movieResponses: [MovieResponse]) -> [Movie]{
    return movieResponses.map{ item in
        return Movie(
            title: item.title,
            poster: item.posterPath,
            popularity: item.popularity,
            genres: item.genres,
            voteAverage: item.voteAverage,
            overview: item.overview,
            releaseDate: item.releaseDate)
    }
}
