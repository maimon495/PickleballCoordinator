import SwiftUI

enum PickleballTheme {
    // MARK: - Colors - Warm, elegant palette inspired by fountain pen aesthetic

    static let cream = Color(red: 1.0, green: 0.973, blue: 0.906)
    static let warmWhite = Color(red: 0.98, green: 0.96, blue: 0.92)
    static let parchment = Color(red: 0.96, green: 0.94, blue: 0.88)

    // Pickleball court colors - refined
    static let courtGreen = Color(red: 0.20, green: 0.45, blue: 0.35)
    static let courtBlue = Color(red: 0.22, green: 0.38, blue: 0.52)

    // Ink-inspired text colors
    static let inkNavy = Color(red: 0.15, green: 0.18, blue: 0.25)
    static let inkCharcoal = Color(red: 0.25, green: 0.25, blue: 0.28)
    static let inkMuted = Color(red: 0.45, green: 0.45, blue: 0.48)

    // Accent colors
    static let goldAccent = Color(red: 0.76, green: 0.60, blue: 0.33)
    static let copperAccent = Color(red: 0.72, green: 0.45, blue: 0.35)
    static let brassAccent = Color(red: 0.72, green: 0.58, blue: 0.38)

    // Status colors - muted, elegant
    static let successGreen = Color(red: 0.25, green: 0.50, blue: 0.38)
    static let warningAmber = Color(red: 0.72, green: 0.55, blue: 0.25)
    static let dangerRed = Color(red: 0.65, green: 0.25, blue: 0.25)

    // Skill level colors
    static let beginnerColor = Color(red: 0.45, green: 0.60, blue: 0.45)
    static let intermediateColor = Color(red: 0.50, green: 0.50, blue: 0.65)
    static let advancedColor = Color(red: 0.60, green: 0.45, blue: 0.50)

    // MARK: - Fonts

    static func serifFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }

    static var title: Font {
        .system(size: 28, weight: .medium, design: .serif)
    }

    static var headline: Font {
        .system(size: 20, weight: .medium, design: .serif)
    }

    static var body: Font {
        .system(size: 17, weight: .regular, design: .serif)
    }

    static var subheadline: Font {
        .system(size: 15, weight: .regular, design: .serif)
    }

    static var caption: Font {
        .system(size: 13, weight: .regular, design: .serif)
    }

    static var smallCaps: Font {
        .system(size: 12, weight: .medium, design: .serif).smallCaps()
    }

    // MARK: - Spacing

    static let pageMargin: CGFloat = 20
    static let cardPadding: CGFloat = 16
    static let itemSpacing: CGFloat = 12
    static let sectionSpacing: CGFloat = 24

    // MARK: - Shadows

    static let cardShadow = Shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    static let subtleShadow = Shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Modifiers

struct PickleballCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(PickleballTheme.cardPadding)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(PickleballTheme.cream)

                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.4),
                                    .clear,
                                    .black.opacity(0.02)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .shadow(
                color: PickleballTheme.cardShadow.color,
                radius: PickleballTheme.cardShadow.radius,
                x: PickleballTheme.cardShadow.x,
                y: PickleballTheme.cardShadow.y
            )
    }
}

struct PickleballBackgroundStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    PickleballTheme.warmWhite

                    // Subtle texture
                    GeometryReader { geo in
                        Canvas { context, size in
                            for _ in 0..<80 {
                                let x = CGFloat.random(in: 0...size.width)
                                let y = CGFloat.random(in: 0...size.height)
                                let rect = CGRect(x: x, y: y, width: 1, height: 1)
                                context.fill(
                                    Path(ellipseIn: rect),
                                    with: .color(.black.opacity(Double.random(in: 0.01...0.02)))
                                )
                            }
                        }
                    }
                }
                .ignoresSafeArea()
            )
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(PickleballTheme.serifFont(size: 16, weight: .medium))
            .foregroundStyle(PickleballTheme.cream)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(PickleballTheme.courtGreen)
            )
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(PickleballTheme.serifFont(size: 16, weight: .medium))
            .foregroundStyle(PickleballTheme.courtGreen)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(PickleballTheme.courtGreen, lineWidth: 1.5)
            )
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

// MARK: - View Extensions

extension View {
    func pickleballCard() -> some View {
        modifier(PickleballCardStyle())
    }

    func pickleballBackground() -> some View {
        modifier(PickleballBackgroundStyle())
    }
}

// MARK: - Pickleball Icon

struct PickleballIcon: View {
    var size: CGFloat = 24
    var color: Color = PickleballTheme.courtGreen

    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: size, height: size)

            // Wiffle ball holes pattern
            ForEach(0..<6) { i in
                Circle()
                    .fill(PickleballTheme.cream)
                    .frame(width: size * 0.15, height: size * 0.15)
                    .offset(
                        x: cos(Double(i) * .pi / 3) * size * 0.28,
                        y: sin(Double(i) * .pi / 3) * size * 0.28
                    )
            }

            Circle()
                .fill(PickleballTheme.cream)
                .frame(width: size * 0.12, height: size * 0.12)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        PickleballIcon(size: 48)

        Text("Pickleball Coordinator")
            .font(PickleballTheme.title)
            .foregroundStyle(PickleballTheme.inkNavy)

        VStack(alignment: .leading, spacing: 8) {
            Text("Sample Card")
                .font(PickleballTheme.headline)
                .foregroundStyle(PickleballTheme.inkNavy)
            Text("This is body text showing the elegant serif typography.")
                .font(PickleballTheme.body)
                .foregroundStyle(PickleballTheme.inkCharcoal)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .pickleballCard()
        .padding(.horizontal)

        HStack(spacing: 16) {
            Button("Primary") {}
                .buttonStyle(PrimaryButtonStyle())

            Button("Secondary") {}
                .buttonStyle(SecondaryButtonStyle())
        }
    }
    .pickleballBackground()
}
