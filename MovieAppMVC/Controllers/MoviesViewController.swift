//
//  MoviesViewController.swift
//  MovieAppMVC
//
//  Created by Bisma Saeed on 15.05.26.
//

import Foundation
import Combine

@MainActor
final class MoviesViewController: ObservableObject {
    @Published private(set) var movies: [Movie] = []
    @Published private(set) var favoriteMovieIDs: [Int] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String? = nil

    private let service = MovieService()
    private let repository = DataRepository()
    private var currentPage = 1
    private var totalPages = 0

    var hasMorePages: Bool {
        (currentPage + 1) < totalPages
    }

    var loadMoreTitle: String {
        "Next Page: \(currentPage + 1) out of \(totalPages)"
    }

    init() {
        loadCachedData()
    }

    func loadNetworkData() async {
        await fetchMoviesResponse()
        await loadGenres()
    }

    /// Pull-to-refresh: clear cache, fetch fresh data.
    func refresh() async {
        currentPage = 1
        await fetchMoviesResponse()
    }

    func loadNextPage() async {
        currentPage += 1
        await fetchMoviesResponse()
    }

    func isFavorite(movie: Movie) -> Bool {
        favoriteMovieIDs.contains(movie.id)
    }

    private func loadCachedData() {
        let moviesData = repository.fetchCachedMovies()
        let paginationInfo = repository.fetchPaginationInfo()
        currentPage = paginationInfo.highestPage > 0 ? paginationInfo.highestPage : 1
        totalPages = paginationInfo.totalPages

        guard !moviesData.isEmpty else { return }
        movies = moviesData
        favoriteMovieIDs = repository.fetchFavouriteMovieIDs()
    }

    private func fetchMoviesResponse() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetched = try await service.fetchMovies(page: currentPage)
            repository.save(response: fetched, for: currentPage)
            loadCachedData()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func loadGenres() async {
        do {
            let fetched = try await service.fetchAllTags()
            repository.save(genres: fetched)
        } catch {
            print(error.localizedDescription)
        }
    }
}
