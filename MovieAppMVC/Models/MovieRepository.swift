//
//  MovieRepository.swift
//  MovieAppMVC
//
//  Created by Bisma Saeed on 15.05.26.
//


import CoreData
import Foundation

final class MovieRepository {
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

    func update(movie: Movie, detailResponse: MovieDetailsResponse) {
        let request: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", NSNumber(value: movie.id))

        do {
            let entity = try stack.context.fetch(request).first

            for genre in detailResponse.genres {
                let genreEntity = GenreEntity(context: stack.context)
                genreEntity.id = Int64(genre.id)
                genreEntity.name = genre.name
                entity?.addToGenres(genreEntity)
            }

            entity?.runtime = Int64(detailResponse.runtime)
            stack.saveContext()
        } catch {
            print("Failed to update genres: \(error)")
        }
    }
    // MARK: - Fetch all cached data
    func fetchCachedMovies(id: Int? = nil) -> [Movie] {
        let request: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        if let id {
            request.predicate = NSPredicate(format: "id == %@", NSNumber(value: id))
        }

        do {
            let entities = try stack.context.fetch(request)
            return entities.map { entity in

                let genreSet = entity.genres as? Set<GenreEntity> ?? []
                let genreArray = genreSet.map { genreEntity in
                    Genre(id: Int(genreEntity.id), name: genreEntity.name ?? "Unknown")
                }

                return Movie(id: Int(entity.id),
                             title: entity.title ?? "",
                             overview: entity.overview ?? "",
                             posterPath: entity.posterPath,
                             releaseDate: entity.releaseDate,
                             voteAverage: entity.voteAverage,
                             favourite: entity.favourite,
                             genres: genreArray,
                             runtime: Int(entity.runtime))
            }
        } catch {
            print("Fetch movies error: \(error.localizedDescription)")
            return []
        }
    }

    func fetchFavouriteMovieIDs() -> [Int] {
        let request: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        request.predicate = NSPredicate(format: "favourite == %@", NSNumber(value: true))
        request.propertiesToFetch = ["id"]

        do {
            let results = try stack.context.fetch(request)
            return results.map { Int($0.id) }
        } catch {
            print("Fetch favourite movie IDs error: \(error.localizedDescription)")
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
