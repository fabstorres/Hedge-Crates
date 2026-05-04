import SwiftUI

struct ContentView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            UploadView(path: $path)
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .result(let crate):
                        AnalysisResultView(crate: crate, path: $path)
                    case .error(let message):
                        AnalysisErrorView(message: message, path: $path)
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}
