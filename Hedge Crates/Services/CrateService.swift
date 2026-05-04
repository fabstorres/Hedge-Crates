import Foundation
import UIKit

enum CrateServiceError: LocalizedError {
    case tooManyImages
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .tooManyImages:
            return "Maximum of 5 images allowed."
        case .invalidURL:
            return "Invalid service URL."
        case .networkError(let error):
            return error.localizedDescription
        case .invalidResponse:
            return "Invalid response from server."
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let message):
            return message
        }
    }
}

actor CrateService {
    private let deploymentUrl: String
    private let session: URLSession

    init(deploymentUrl: String, session: URLSession = .shared) {
        self.deploymentUrl = deploymentUrl
        self.session = session
    }

    func analyzeImages(_ images: [UIImage]) async throws -> Crate {
        guard images.count <= 5 else {
            throw CrateServiceError.tooManyImages
        }

        guard let url = URL(string: "\(deploymentUrl)/api/analyzeImages") else {
            throw CrateServiceError.invalidURL
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )

        var body = Data()

        for (index, image) in images.enumerated() {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                continue
            }

            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append(
                "Content-Disposition: form-data; name=\"image\"; filename=\"image\(index).jpg\"\r\n"
                    .data(using: .utf8)!
            )
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw CrateServiceError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw CrateServiceError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let message =
                (try? JSONSerialization.jsonObject(with: data) as? [String: Any])?["error"]
                as? String
                ?? "HTTP \(httpResponse.statusCode)"
            throw CrateServiceError.serverError(message)
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(Crate.self, from: data)
        } catch {
            throw CrateServiceError.decodingError(error)
        }
    }
}
