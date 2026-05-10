import SwiftUI
import Combine
import ConvexMobile

struct UploadView: View {
    @Binding var path: NavigationPath
    let token: String

    @State private var showPhotoPicker = false
    @State private var selectedImages: [UIImage] = []
    @State private var isLoading = false
    @State private var credits: Int = 0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Text("HEDGE")
                    .font(.system(size: 28, weight: .bold, design: .default))
                    .foregroundStyle(.white)
                    .padding(.top, 60)

                Spacer().frame(height: 40)

                Text("Analyze Your Trade")
                    .font(.system(size: 32, weight: .bold, design: .default))
                    .foregroundStyle(.white)

                Text("Upload screenshots to validate your trade idea.")
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .foregroundStyle(Color.gray)
                    .padding(.top, 8)

                Button(action: {
                    showPhotoPicker = true
                }) {
                    Text(credits < 1 ? "No Credits Remaining" : "Upload Screenshot (Beta)")
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(credits < 1 ? Color.gray : Color(red: 0.35, green: 0.55, blue: 0.35))
                        )
                }
                .padding(.top, 32)
                .disabled(isLoading || credits < 1)

                Spacer()
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .task {
            let creditsStream = convex.subscribe(
                to: "guests:getCredits",
                with: ["guestToken": token],
                yielding: Int.self
            )
            .replaceError(with: 0)
            .values

            for await newCredits in creditsStream {
                self.credits = newCredits
            }
        }
        .sheet(isPresented: $showPhotoPicker) {
            PhotoPicker(selectedImages: $selectedImages, isPresented: $showPhotoPicker) {
                submitImages()
            }
        }
        .overlay {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.7).ignoresSafeArea()
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        Text("Analyzing...")
                            .foregroundStyle(.white)
                            .font(.system(size: 16, weight: .medium))
                    }
                }
            }
        }
    }

    private func submitImages() {
        guard !selectedImages.isEmpty else { return }
        isLoading = true
        Task {
            do {
                let crate = try await crateService.analyzeImages(selectedImages, guestToken: token)
                await MainActor.run {
                    isLoading = false
                    path.append(Route.result(crate))
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    let message = (error as? CrateServiceError)?.localizedDescription ?? error.localizedDescription
                    path.append(Route.error(message))
                }
            }
        }
    }
}
