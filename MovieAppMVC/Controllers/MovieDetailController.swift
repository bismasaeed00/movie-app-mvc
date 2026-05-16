//
//  MovieDetailController.swift
//  MovieAppMVC
//
//  Created by Bisma Saeed on 15.05.26.
//

import Foundation
import Combine

@MainActor
final class MovieDetailController: ObservableObject {
    private let service = MovieService()
    private let repository = MovieRepository()
    @Published private(set) var movie: Movie

    var rating: String {
        String(format: "%.1f", movie.voteAverage)
    }

    var isFavourite: Bool {
        movie.favourite ?? false
    }

    var overview: String {
        movie.overview.isEmpty ? "No overview available." : movie.overview
    }

    init(movie: Movie) {
        self.movie = movie
        loadCachedMovie()
    }

    func loadMovieDetails() async {
        do {
            let response = try await service.fetchMovieDetails(movie)
            repository.update(movie: movie, detailResponse: response)
            loadCachedMovie()
        } catch {
            print(error.localizedDescription)
        }
    }

    func toggleFavourite() {
        repository.updateMovie(movie: movie, isFavourite: !(movie.favourite ?? false))
        loadCachedMovie()
    }

    private func loadCachedMovie() {
        guard let updatedObj = repository.fetchCachedMovies(id: movie.id).first else { return }
        movie = updatedObj
    }
}
