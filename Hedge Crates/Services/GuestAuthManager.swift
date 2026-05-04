import Foundation
import Combine
import ConvexMobile

@MainActor
class GuestAuthManager: ObservableObject {
    @Published private(set) var token: String?
    @Published private(set) var isLoading = true
    @Published private(set) var errorMessage: String?

    private let keychain = KeychainHelper()

    func ensureToken() async {
        isLoading = true
        defer { isLoading = false }

        if let existing = keychain.getGuestToken() {
            token = existing
            return
        }

        do {
            let newToken: String = try await convex.action("guests:createGuest")
            try keychain.saveGuestToken(newToken)
            token = newToken
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
