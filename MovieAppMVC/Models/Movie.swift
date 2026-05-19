//
//  Movie.swift
//  MovieAppMVC
//
//  Created by Bisma Saeed on 15.05.26.
//

struct MovieResponse: Codable {
    let results: [Movie]
    let page: Int
    let totalPages: Int

    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
    }
}

struct Movie: Codable, Identifiable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let releaseDate: String?
    let voteAverage: Double
    let favourite: Bool?
    let genres: [Genre]?
    let runtime: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case favourite
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case genres
        case runtime
    }

    var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }

    var formattedYear: String {
        guard let date = releaseDate, date.count >= 4 else { return "N/A" }
        return String(date.prefix(4))
    }
}

struct MovieDetailsResponse: Codable {
    let id: Int
    let runtime: Int
    private(set) var genres: [Genre] = []

    enum CodingKeys: String, CodingKey {
        case id
        case genres
        case runtime
    }
}
