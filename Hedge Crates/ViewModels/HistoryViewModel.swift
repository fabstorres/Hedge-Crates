import Combine
import ConvexMobile
import SwiftUI

@MainActor
class HistoryViewModel: ObservableObject {
    @Published var crates: [Crate] = []
    @Published var isLoading = false

    let token: String

    init(token: String) {
        self.token = token
    }

    func loadCrates() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let crates: [Crate] = try await convex.action(
                "crates:getCrates",
                with: ["guestToken": token]
            )
            self.crates = crates
        } catch {
            self.crates = []
        }
    }
}
