import Combine
import ConvexMobile
import SwiftUI

@MainActor
class HistoryViewModel: ObservableObject {
    @Published var crates: [Crate] = []

    init() {
        convex.subscribe(to: "crates:getCrates", yielding: [Crate].self)
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .assign(to: &$crates)
    }
}
