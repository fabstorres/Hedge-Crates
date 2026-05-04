import SwiftUI

struct ContentView: View {
    @StateObject private var guestAuth = GuestAuthManager()
    @State private var analyzerPath = NavigationPath()
    @State private var historyPath = NavigationPath()

    var body: some View {
        Group {
            if guestAuth.isLoading {
                loadingView
            } else if let token = guestAuth.token {
                mainView(token: token)
            } else {
                errorView
            }
        }
        .task {
            await guestAuth.ensureToken()
        }
    }

    private func mainView(token: String) -> some View {
        TabView {
            NavigationStack(path: $analyzerPath) {
                UploadView(path: $analyzerPath, token: token)
                    .navigationDestination(for: Route.self) { route in
                        switch route {
                        case .result(let crate):
                            AnalysisResultView(crate: crate, path: $analyzerPath)
                        case .error(let message):
                            AnalysisErrorView(message: message, path: $analyzerPath)
                        }
                    }
            }
            .tabItem {
                Label("Analyzer", systemImage: "chart.bar")
            }

            NavigationStack(path: $historyPath) {
                HistoryView(token: token, path: $historyPath)
                    .navigationDestination(for: Route.self) { route in
                        switch route {
                        case .result(let crate):
                            AnalysisResultView(crate: crate, path: $historyPath)
                        case .error(let message):
                            AnalysisErrorView(message: message, path: $historyPath)
                        }
                    }
            }
            .tabItem {
                Label("History", systemImage: "clock")
            }
        }
    }

    private var loadingView: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                Text("Initializing...")
                    .font(.system(size: 16, weight: .medium, design: .default))
                    .foregroundStyle(.white)
            }
        }
    }

    private var errorView: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 64, weight: .light))
                    .foregroundStyle(.white.opacity(0.4))
                Text("Something went wrong")
                    .font(.system(size: 24, weight: .bold, design: .default))
                    .foregroundStyle(.white)
                Text(guestAuth.errorMessage ?? "Unable to initialize guest session.")
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)
        }
    }
}

#Preview {
    ContentView()
}
