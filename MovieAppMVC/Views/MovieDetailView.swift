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
                // Details
                VStack(alignment: .leading, spacing: 12) {

                    Text(controller.title)
                        .font(.title.bold())

                    HStack(spacing: 12) {
                        Label(controller.year,   systemImage: "calendar")
                        Label(controller.rating, systemImage: "star.fill")
                            .foregroundColor(.yellow)
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                    Divider()

                    Text("Overview")
                        .font(.headline)

                    Text(controller.overview)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle(controller.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var posterView: some View {
        AsyncImage(url: controller.posterURL) { phase in
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
}
