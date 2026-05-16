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
    let title: String
    let year: String
    let rating: String
    let overview: String
    let posterURL: URL?

    init(movie: Movie) {
        self.title = movie.title
        self.year = movie.formattedYear
        self.rating = String(format: "%.1f", movie.voteAverage)
        self.overview = movie.overview.isEmpty ? "No overview available." : movie.overview
        self.posterURL = movie.posterURL
    }
}
