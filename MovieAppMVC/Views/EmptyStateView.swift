//
//  EmptyStateView.swift
//  MovieAppMVC
//
//  Created by Bisma Saeed on 15.05.26.
//

import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "film.stack")
                .font(.system(size: 52))
                .foregroundColor(.secondary)

            Text("No Movies Yet")
                .font(.title3.bold())

            Text("Pull down to load movies from the network.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
