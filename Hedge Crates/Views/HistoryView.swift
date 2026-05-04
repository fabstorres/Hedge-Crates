import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel: HistoryViewModel
    @Binding var path: NavigationPath

    init(token: String, path: Binding<NavigationPath>) {
        _viewModel = StateObject(wrappedValue: HistoryViewModel(token: token))
        _path = path
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if viewModel.isLoading && viewModel.crates.isEmpty {
                loadingView
            } else if viewModel.crates.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        headerBar

                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.crates) { crate in
                                Button(action: {
                                    path.append(Route.result(crate))
                                }) {
                                    crateRow(crate)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    }
                }
            }
        }
        .task {
            await viewModel.loadCrates()
        }
        .refreshable {
            await viewModel.loadCrates()
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)
            Text("Loading...")
                .font(.system(size: 16, weight: .medium, design: .default))
                .foregroundStyle(.white)
        }
    }

    private var headerBar: some View {
        HStack {
            Text("History")
                .font(.system(size: 28, weight: .bold, design: .default))
                .foregroundStyle(.white)

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }

    private func crateRow(_ crate: Crate) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(crate.position.capitalized)
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .foregroundStyle(.white)

                Spacer()

                Text("\(crate.sprint.capitalized) Term")
                    .font(.system(size: 14, weight: .medium, design: .default))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(6)
            }

            Text(formattedDate(crate.createdAt))
                .font(.system(size: 14, weight: .regular, design: .default))
                .foregroundStyle(Color.gray)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }

    private func formattedDate(_ timestamp: Double) -> String {
        let date = Date(timeIntervalSince1970: timestamp / 1000.0)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock")
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(.white.opacity(0.4))

            Text("No History Yet")
                .font(.system(size: 24, weight: .bold, design: .default))
                .foregroundStyle(.white)

            Text("Your past crate analyses will appear here.")
                .font(.system(size: 16, weight: .regular, design: .default))
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 32)
    }
}

#Preview {
    HistoryView(token: "preview", path: .constant(NavigationPath()))
}
