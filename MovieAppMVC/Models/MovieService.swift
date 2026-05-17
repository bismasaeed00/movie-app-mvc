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
        case .networkError(let error):
            "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            "Decoding error: \(error.localizedDescription)"
        case .httpError(let code):
            "HTTP error \(code)."
        }
    }
}

final class MovieService {

    // MARK: - Configuration
    private let apiKey = "3db0f53e603350e7a4fda7a09419f20a"
    private let moviesBaseURL = "https://api.themoviedb.org/3/discover/movie"
    private let movieDetailURL = "https://api.themoviedb.org/3/movie/%lld"

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

    // MARK: Fetch movie details
    func fetchMovieDetails(_ movie: Movie) async throws -> MovieDetailsResponse {
        let urlString = String(format: movieDetailURL, movie.id)
        var components = URLComponents(string: urlString)
        components?.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "language", value: "en-US")
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
            return try JSONDecoder().decode(MovieDetailsResponse.self, from: data)
        } catch {
            throw MovieServiceError.decodingError(error)
        }
    }

}
