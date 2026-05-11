import SwiftUI

enum Route: Hashable {
    case result(Crate)
    case error(String)
    case auth
}
