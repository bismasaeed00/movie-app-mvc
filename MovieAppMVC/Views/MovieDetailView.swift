//
//  MovieDetailView.swift
//  MovieAppMVC
//
//  Created by Bisma Saeed on 15.05.26.
//

import SwiftUI

struct MovieDetailView: View {

    @StateObject private var controller: MovieDetailController

    init(controller: MovieDetailController) {
        _controller = StateObject(wrappedValue: controller)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                posterView
                VStack(alignment: .leading, spacing: 12) {
                    Text(controller.movie.title)
                        .font(.title.bold())
                    HStack(spacing: 12) {
                        Label(controller.movie.formattedYear,   systemImage: "calendar")
                        Label(controller.rating, systemImage: "star.fill")
                            .foregroundColor(.yellow)
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                    Divider()
                    HStack {
                        Text("Runtime: ")
                            .font(.headline)
                        Text("\(controller.movie.runtime ?? 0) min")
                            .font(.subheadline)
                    }
                    Divider()
                    Text("Overview")
                        .font(.headline)

                    Text(controller.overview)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    genreChips
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .task {
            await controller.loadMovieDetails()
        }
        .navigationTitle(controller.movie.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                favouriteButton
            }
        }
    }

    private var favouriteButton: some View {
        Button(action: {
            controller.toggleFavourite()
        }) {
            Image(systemName: controller.isFavourite ? "heart.fill" : "heart")
                .foregroundColor(controller.isFavourite ? .red : .primary)
                .font(.body.bold())
        }
    }

    private var posterView: some View {
        AsyncImage(url: controller.movie.posterURL) { phase in
            switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                case .failure, .empty:
                    Rectangle()
                        .fill(Color(.tertiarySystemBackground))
                        .overlay(Image(systemName: "film").font(.largeTitle))
                @unknown default:
                    EmptyView()
            }
        }
        .frame(maxWidth: .infinity)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }

    @ViewBuilder
    private var genreChips: some View {
        if let genres = controller.movie.genres, !genres.isEmpty {
            FlowLayout(spacing: 8) {
                ForEach(Array(genres.enumerated()), id: \.offset) { index, genre in
                    Text(genre.name)
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .foregroundColor(.white)
                        .background(
                            Capsule()
                                .fill(.blue)
                        )
                        .fixedSize(horizontal: true, vertical: false)
                }
            }
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        var totalHeight: CGFloat = 0
        var totalWidth: CGFloat = 0
        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0

        let maxWidth = proposal.width ?? .infinity

        for size in sizes {
            if lineWidth + size.width > maxWidth {
                totalHeight += lineHeight + spacing
                totalWidth = max(totalWidth, lineWidth)
                lineWidth = 0
                lineHeight = 0
            }
            lineWidth += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        totalHeight += lineHeight
        totalWidth = max(totalWidth, lineWidth - spacing)
        return CGSize(width: totalWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        var x = bounds.minX
        var y = bounds.minY
        var lineHeight: CGFloat = 0

        for index in subviews.indices {
            let size = sizes[index]
            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += lineHeight + spacing
                lineHeight = 0
            }
            subviews[index].place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}
