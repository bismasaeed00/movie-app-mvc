//
//  MoviesView.swift
//  MovieAppMVC
//
//  Created by Bisma Saeed on 15.05.26.
//

import SwiftUI

enum MoviesTab {
    case all
    case favorites
}

struct MoviesView: View {
    @StateObject private var controller = MoviesViewController()
    @State private var selectedTab: MoviesTab = .all

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                tabsView
                content
            }
            .navigationTitle("Movies")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if controller.isLoading {
                        ProgressView()
                    }
                }
            }
            .task {
                await controller.loadNetworkData()
            }
            .refreshable {
                if selectedTab == .all {
                    await controller.refresh()
                }
            }
        }
    }

    private var filteredMovies: [Movie] {
        switch selectedTab {
        case .all:
            return controller.movies
        case .favorites:
            return controller.movies.filter { controller.isFavorite(movie: $0) }
        }
    }

    private var tabsView: some View {
        Picker("", selection: $selectedTab) {
            Text("All").tag(MoviesTab.all)
            Text("Favorites").tag(MoviesTab.favorites)
        }
        .pickerStyle(.segmented)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.gray)
        )
        .padding(.horizontal)
    }

    @ViewBuilder
    private var content: some View {
        if let error = controller.errorMessage, controller.movies.isEmpty {
            ErrorView(message: error) {
                Task {
                    await controller.loadNetworkData()
                }
            }
        } else if controller.movies.isEmpty && !controller.isLoading {
            EmptyStateView()
        } else {
            movieList
        }
    }

    // MARK: - Movie List
    private var movieList: some View {
        List {
            ForEach(filteredMovies) { movie in
                NavigationLink(destination: MovieDetailView(controller: MovieDetailController(movie: movie))) {
                    movieRow(movie: movie)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            if selectedTab == .all {
                footerView
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
    }

    @ViewBuilder
    private var footerView: some View {
        if controller.isLoading {
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }

        } else if controller.hasMorePages {
            Button(controller.loadMoreTitle) {
                Task {
                    await controller.loadNextPage()
                }
            }
            .frame(maxWidth: .infinity)

        }
    }

    private func movieRow(movie: Movie) -> some View {
        HStack(alignment: .top, spacing: 14) {
            posterImage(posterURL: movie.posterURL)
            infoView(movie: movie)
            Spacer(minLength: 0)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func posterImage(posterURL: URL?) -> some View {
        AsyncImage(url: posterURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure:
                posterPlaceholder
            case .empty:
                posterPlaceholder.redacted(reason: .placeholder)
            @unknown default:
                posterPlaceholder
            }
        }
        .frame(width: 70, height: 105)
        .clipped()
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
    }

    private func infoView(movie: Movie) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(movie.title)
                .font(.headline)
                .lineLimit(2)

            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
                Text(String(format: "%.1f", movie.voteAverage))
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("·")
                    .foregroundColor(.secondary)

                Text(movie.formattedYear)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Text(movie.overview)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(3)
        }
        .padding(.vertical, 4)
    }

    private var posterPlaceholder: some View {
        Rectangle()
            .fill(Color(.tertiarySystemBackground))
            .overlay(
                Image(systemName: "film")
                    .foregroundColor(.secondary)
                    .font(.title2)
            )
    }
}
