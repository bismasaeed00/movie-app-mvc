//
//  DataRepository.swift
//  MovieAppMVC
//
//  Created by Bisma Saeed on 15.05.26.
//


import CoreData
import Foundation

final class DataRepository {

    private let stack: CoreDataStack

    init(stack: CoreDataStack = .shared) {
        self.stack = stack
    }

    // MARK: - Save movies from network to Core Data
    func save(response: MovieResponse, for page: Int) {
        let request: NSFetchRequest<ResponseEntity> = ResponseEntity.fetchRequest()
        request.predicate = NSPredicate(format: "page == %d", page)

        do {
            // Fetch cached entities for this page
            let cachedResponses = try stack.context.fetch(request)

            // Build lookup dictionary using movie id
            var existingMovies: [Int: MovieEntity] = [:]
            for responseEntity in cachedResponses {
                if let movies = responseEntity.movies as? Set<MovieEntity> {
                    for movie in movies {
                        existingMovies[Int(movie.id)] = movie
                    }
                }
            }

            // If page exists → update existing movies
            if !cachedResponses.isEmpty {
                for movie in response.results {
                    if let existingMovie = existingMovies[movie.id] {
                        // Update existing object
                        existingMovie.title = movie.title
                        existingMovie.overview = movie.overview
                        existingMovie.posterPath = movie.posterPath
                        existingMovie.voteAverage = movie.voteAverage
                    } else {
                        // Insert new movie if missing
                        let newMovie = MovieEntity(context: stack.context)
                        newMovie.id = Int64(movie.id)
                        newMovie.title = movie.title
                        newMovie.overview = movie.overview
                        newMovie.posterPath = movie.posterPath
                        newMovie.releaseDate = movie.releaseDate
                        newMovie.voteAverage = movie.voteAverage

                        cachedResponses.first?.addToMovies(newMovie)
                    }
                }

            } else {
                // No cached page → create new response entity
                let responseEntity = ResponseEntity(context: stack.context)
                responseEntity.page = Int64(response.page)
                responseEntity.total_pages = Int64(response.totalPages)

                for movie in response.results {
                    let movieEntity = MovieEntity(context: stack.context)
                    movieEntity.id = Int64(movie.id)
                    movieEntity.title = movie.title
                    movieEntity.overview = movie.overview
                    movieEntity.posterPath = movie.posterPath
                    movieEntity.releaseDate = movie.releaseDate
                    movieEntity.voteAverage = movie.voteAverage
                    responseEntity.addToMovies(movieEntity)
                }
            }

            stack.saveContext()

        } catch {
            print("Failed to save/update movies response: \(error)")
        }
    }

    func save(genres: [Genre]) {
        let request: NSFetchRequest<GenreEntity> = GenreEntity.fetchRequest()

        do {
            // Fetch existing genres
            let existingGenres = try stack.context.fetch(request)

            // Create lookup dictionary by id
            let existingGenreMap = Dictionary(uniqueKeysWithValues: existingGenres.map {
                    (Int($0.id), $0)
                }
            )

            // Insert only missing genres
            for genre in genres {
                guard existingGenreMap[genre.id] == nil else { return }
                let genreEntity = GenreEntity(context: stack.context)
                genreEntity.id = Int64(genre.id)
                genreEntity.name = genre.name
            }
            stack.saveContext()
        } catch {
            print("Failed to update genres: \(error)")
        }
    }
    // MARK: - Fetch all cached data
    func fetchCachedMovies() -> [Movie] {
        let request: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()

        do {
            let entities = try stack.context.fetch(request)
            return entities.map { entity in
                Movie(id: Int(entity.id),
                      title: entity.title ?? "",
                      overview: entity.overview ?? "",
                      posterPath: entity.posterPath,
                      releaseDate: entity.releaseDate,
                      voteAverage: entity.voteAverage,
                      favourite: entity.favourite)
            }
        } catch {
            print("Fetch movies error: \(error.localizedDescription)")
            return []
        }
    }

    func fetchFavouriteMovieIDs() -> [Int] {
        let request: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        request.predicate = NSPredicate(format: "favourite == %@", NSNumber(value: true))
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = ["id"]


        do {
            let results = try stack.context.fetch(request)
            return results.map { Int($0.id) }
        } catch {
            print("Fetch favourite movie IDs error: \(error.localizedDescription)")
            return []
        }
    }


    func fetchCachedGenre() -> [Genre] {
        let request: NSFetchRequest<GenreEntity> = GenreEntity.fetchRequest()

        do {
            let entities = try stack.context.fetch(request)
            return entities.map { entity in
                Genre(id: Int(entity.id),
                      name: entity.name ?? "")
            }
        } catch {
            print("Fetch genre error: \(error.localizedDescription)")
            return []
        }
    }

    func fetchPaginationInfo() -> (highestPage: Int, totalPages: Int) {
        let request: NSFetchRequest<ResponseEntity> = ResponseEntity.fetchRequest()

        do {
            let entities = try stack.context.fetch(request)
            guard !entities.isEmpty else {
                return (0, 0)
            }

            // Highest page available
            let highestPage = entities
                .map { Int($0.page) }
                .max() ?? 0

            // Total pages (usually same across all rows, so take first valid)
            let totalPages = Int(entities.first?.total_pages ?? 0)
            return (highestPage, totalPages)

        } catch {
            return (0, 0)
        }
    }

    func updateMovie(movie: Movie, isFavourite: Bool) {
        let request: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", movie.id)
        request.fetchLimit = 1

        do {
            guard let matchedMovie = try stack.context.fetch(request).first else {
                return
            }

            matchedMovie.favourite = isFavourite
            stack.saveContext()
        } catch {
            print("Failed to update movie: \(error)")
        }
    }
}
