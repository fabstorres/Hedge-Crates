import SwiftUI

struct ContentView: View {
    @State private var analyzerPath = NavigationPath()
    @State private var historyPath = NavigationPath()

    var body: some View {
        TabView {
            NavigationStack(path: $analyzerPath) {
                UploadView(path: $analyzerPath)
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
                HistoryView(path: $historyPath)
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
}

#Preview {
    ContentView()
}
