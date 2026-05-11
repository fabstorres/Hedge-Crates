import SwiftUI

struct AuthView: View {
    @Binding var path: NavigationPath

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar

                Spacer()

                titleSection

                Spacer()

                buttonsSection
                    .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
    }

    private var headerBar: some View {
        HStack {
            Button(action: { path.removeLast() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }

    private var titleSection: some View {
        HStack(spacing: 6) {
            Text("Let's start trading")
                .font(.system(size: 32, weight: .bold, design: .default))
                .foregroundStyle(.white)

            Circle()
                .fill(Color.black)
                .frame(width: 12, height: 12)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 1.5)
                )
        }
    }

    private var buttonsSection: some View {
        VStack(spacing: 12) {
            Button(action: {}) {
                HStack(spacing: 8) {
                    Text("\u{F8FF}")
                        .font(.system(size: 18, weight: .medium))
                    Text("Continue with Apple")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.white)
                .cornerRadius(12)
            }

            Button(action: {}) {
                HStack(spacing: 8) {
                    Image(systemName: "globe")
                        .font(.system(size: 18, weight: .medium))
                    Text("Continue with Google")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.white.opacity(0.15))
                .cornerRadius(12)
            }
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    AuthView(path: .constant(NavigationPath()))
}
