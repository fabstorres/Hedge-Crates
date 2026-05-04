import SwiftUI

struct AnalysisErrorView: View {
    let message: String
    @Binding var path: NavigationPath

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar

                Spacer()

                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.15))
                            .frame(width: 80, height: 80)

                        Circle()
                            .stroke(Color.red.opacity(0.6), lineWidth: 3)
                            .frame(width: 80, height: 80)

                        Image(systemName: "xmark")
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundStyle(.red)
                    }

                    Text("Unable to Analyze Trade")
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text("The request could not be completed.")
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)

                    Text(message)
                        .font(.system(size: 14, weight: .medium, design: .default))
                        .foregroundStyle(.red)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.15))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )

                    Button(action: {
                        path.removeLast(path.count)
                    }) {
                        Text("Go Back")
                            .font(.system(size: 16, weight: .semibold, design: .default))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.12))
                            )
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 24)

                Spacer()
            }
        }
        .navigationBarHidden(true)
    }

    private var headerBar: some View {
        HStack {
            Text("HEDGE")
                .font(.system(size: 28, weight: .bold, design: .default))
                .foregroundStyle(.white)

            Spacer()

            Button(action: {}) {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }
}
