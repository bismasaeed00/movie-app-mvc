//
//  Genre.swift
//  MovieAppMVC
//
//  Created by Bisma Saeed on 16.05.26.
//

struct GenreResponse: Decodable {
    let genres: [Genre]
}

struct Genre: Codable, Identifiable {
    let id: Int
    let name: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
}
