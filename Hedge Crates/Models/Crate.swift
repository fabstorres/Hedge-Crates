import Foundation

struct Crate: Decodable, Identifiable, Hashable {
    let id: String
    let createdAt: Double
    let risk: String
    let sprint: String
    let position: String
    let stance: String
    let observations: [String]

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case createdAt = "_creationTime"
        case risk
        case sprint
        case position
        case stance
        case observations
}
}
