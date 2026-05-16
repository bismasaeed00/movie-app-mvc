//
//  MovieService.swift
//  MovieAppMVC
//
//  Created by Bisma Saeed on 15.05.26.
//

import Foundation

enum MovieServiceError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case httpError(Int)

    var errorDescription: String? {
        switch self {
            case .invalidURL:              
                "Invalid URL."
            case .networkError(let e):     
                "Network error: \(e.localizedDescription)"
            case .decodingError(let e):    
                "Decoding error: \(e.localizedDescription)"
            case .httpError(let code):     
                "HTTP error \(code)."
        }
    }
}

final class MovieService {

    // MARK: - Configuration
    private let apiKey = "3db0f53e603350e7a4fda7a09419f20a"
    private let moviesBaseURL = "https://api.themoviedb.org/3/discover/movie"
    private let movieDetailURL = "https://api.themoviedb.org/3/movie/%@" // fetch on detail page
    private let genreBaseURL = "https://api.themoviedb.org/3/genre/movie/list"

    // MARK: - Fetch Movies
    func fetchMovies(page: Int = 1) async throws -> MovieResponse {
        var components = URLComponents(string: moviesBaseURL)
        components?.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "sort_by", value: "popularity.desc"),
            URLQueryItem(name: "include_adult", value: "false"),
            URLQueryItem(name: "page", value: "\(page)")
        ]

        guard let url = components?.url else {
            throw MovieServiceError.invalidURL
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(from: url)
        } catch {
            throw MovieServiceError.networkError(error)
        }

        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw MovieServiceError.httpError(http.statusCode)
        }

        do {
            return try JSONDecoder().decode(MovieResponse.self, from: data)
        } catch {
            throw MovieServiceError.decodingError(error)
        }
    }

    // MARK: - Fetch Genre tags
    func fetchAllTags() async throws -> [Genre] {
        var components = URLComponents(string: genreBaseURL)
        components?.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "language", value: "en"),
        ]

        guard let url = components?.url else {
            throw MovieServiceError.invalidURL
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(from: url)
        } catch {
            throw MovieServiceError.networkError(error)
        }

        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw MovieServiceError.httpError(http.statusCode)
        }

        do {
            let response = try JSONDecoder().decode(GenreResponse.self, from: data)
            return response.genres
        } catch {
            throw MovieServiceError.decodingError(error)
        }
    }
}
