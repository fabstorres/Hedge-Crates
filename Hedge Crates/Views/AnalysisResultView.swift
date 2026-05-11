import SwiftUI

struct AnalysisResultView: View {
    let crate: Crate
    @Binding var path: NavigationPath

    private var riskConfig: RiskConfig {
        RiskConfig(risk: crate.risk)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    headerBar

                    Text("Trade Analysis")
                        .font(.system(size: 16, weight: .medium, design: .default))
                        .foregroundStyle(.white)
                        .padding(.top, 8)
                        .padding(.bottom, 24)

                    VStack(spacing: 16) {
                        riskCard
                        observationsCard
                        seePremiumButton
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 40)
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

    private var riskCard: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(stanceBackgroundColor)
                    .frame(width: 80, height: 80)

                Circle()
                    .stroke(stanceStrokeColor, lineWidth: 3)
                    .frame(width: 80, height: 80)

                Image(systemName: riskConfig.iconName)
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(stanceColor)
            }

            Text(stanceTitle)
                .font(.system(size: 24, weight: .bold, design: .default))
                .foregroundStyle(stanceColor)

            Text(riskConfig.title)
                .font(.system(size: 14, weight: .semibold, design: .default))
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.08))
                .cornerRadius(8)
                .padding(.top, 4)

            Text("\(crate.sprint.capitalized) Term \(crate.position.capitalized)")
                .font(.system(size: 14, weight: .semibold, design: .default))
                .foregroundStyle(.white.opacity(0.7))
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }

    private var stanceColor: Color {
        switch crate.stance.lowercased() {
        case "good": return .green
        case "neutral": return .blue
        case "bad": return .red
        default: return .gray
        }
    }

    private var stanceBackgroundColor: Color {
        switch crate.stance.lowercased() {
        case "good": return Color.green.opacity(0.15)
        case "neutral": return Color.blue.opacity(0.15)
        case "bad": return Color.red.opacity(0.15)
        default: return Color.gray.opacity(0.15)
        }
    }

    private var stanceStrokeColor: Color {
        switch crate.stance.lowercased() {
        case "good": return Color.green.opacity(0.6)
        case "neutral": return Color.blue.opacity(0.6)
        case "bad": return Color.red.opacity(0.6)
        default: return Color.gray.opacity(0.6)
        }
    }

    private var stanceTitle: String {
        switch crate.stance.lowercased() {
        case "good": return "GOOD TRADE"
        case "neutral": return "NEUTRAL TRADE"
        case "bad": return "BAD TRADE"
        default: return "UNKNOWN TRADE"
        }
    }

    private var observationsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Key Observations")
                .font(.system(size: 20, weight: .bold, design: .default))
                .foregroundStyle(.white)

            ForEach(crate.observations, id: \.self) { observation in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(stanceColor)
                        .frame(width: 20, height: 20)

                    Text(observation)
                        .font(.system(size: 15, weight: .regular, design: .default))
                        .foregroundStyle(Color.white.opacity(0.85))
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }

    private var seePremiumButton: some View {
        Button(action: {
            path.append(Route.auth)
        }) {
            Text("See Premium Features")
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
}

private struct RiskConfig {
    let risk: String

    var circleBackground: Color {
        switch risk.lowercased() {
        case "high": return Color.red.opacity(0.15)
        case "medium": return Color.orange.opacity(0.15)
        case "low": return Color.green.opacity(0.15)
        default: return Color.gray.opacity(0.15)
        }
    }

    var circleStroke: Color {
        switch risk.lowercased() {
        case "high": return Color.red.opacity(0.6)
        case "medium": return Color.orange.opacity(0.6)
        case "low": return Color.green.opacity(0.6)
        default: return Color.gray.opacity(0.6)
        }
    }

    var iconName: String {
        switch risk.lowercased() {
        case "high": return "xmark"
        case "medium": return "exclamationmark"
        case "low": return "checkmark"
        default: return "questionmark"
        }
    }

    var iconColor: Color {
        switch risk.lowercased() {
        case "high": return .red
        case "medium": return .orange
        case "low": return .green
        default: return .gray
        }
    }

    var title: String {
        switch risk.lowercased() {
        case "high": return "High Risk Setup"
        case "medium": return "Medium Risk Setup"
        case "low": return "Low Risk Setup"
        default: return "Unknown Risk Setup"
        }
    }

    var checkmarkColor: Color {
        switch risk.lowercased() {
        case "high": return .red.opacity(0.8)
        case "medium": return .orange.opacity(0.8)
        case "low": return .green.opacity(0.8)
        default: return .gray
        }
    }
}
