import SwiftUI

enum PetSpriteState {
    case idle
    case dance
}

struct PetSprite: View {
    let species: String
    var state: PetSpriteState = .idle

    var body: some View {
        TimelineView(.animation) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            let bobAmount: CGFloat = state == .dance ? 8 : 2.5
            let bobPeriod: Double = state == .dance ? 0.4 : 1.2
            let rotation: Double = state == .dance ? sin(t * .pi * 2 / 0.6) * 12 : 0
            let bob = CGFloat(sin(t * .pi * 2 / bobPeriod)) * bobAmount

            sprite
                .offset(y: bob)
                .rotationEffect(.degrees(rotation))
        }
    }

    @ViewBuilder
    private var sprite: some View {
        switch species {
        case "Cat":      catSprite
        case "Dog":      dogSprite
        case "Mouse":    mouseSprite
        case "Dinosaur": dinoSprite
        default:         capybaraSprite
        }
    }

    private var capybaraSprite: some View {
        let body = Color(red: 0.65, green: 0.50, blue: 0.36)
        return ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(body)
                .frame(width: 140, height: 80)
                .offset(y: 14)
            HStack(spacing: 50) {
                Circle().fill(body).frame(width: 22, height: 22)
                Circle().fill(body).frame(width: 22, height: 22)
            }
            .offset(y: -22)
            faceFeatures(eyeOffset: 18, mouthY: -2)
        }
    }

    private var catSprite: some View {
        let body = Color(red: 0.95, green: 0.78, blue: 0.55)
        return ZStack {
            Capsule()
                .fill(body)
                .frame(width: 110, height: 90)
                .offset(y: 14)
            HStack(spacing: 36) {
                Triangle().fill(body).frame(width: 24, height: 28)
                Triangle().fill(body).frame(width: 24, height: 28)
            }
            .offset(y: -32)
            faceFeatures(eyeOffset: 16, mouthY: 2)
            Capsule()
                .fill(body)
                .frame(width: 12, height: 50)
                .rotationEffect(.degrees(35))
                .offset(x: 60, y: 10)
        }
    }

    private var dogSprite: some View {
        let body = Color(red: 0.78, green: 0.62, blue: 0.40)
        return ZStack {
            Capsule()
                .fill(body)
                .frame(width: 130, height: 90)
                .offset(y: 14)
            HStack(spacing: 60) {
                Capsule().fill(body).frame(width: 22, height: 38)
                Capsule().fill(body).frame(width: 22, height: 38)
            }
            .offset(y: -16)
            faceFeatures(eyeOffset: 16, mouthY: 0)
            Circle().fill(Theme.accent).frame(width: 10, height: 10).offset(y: 6)
        }
    }

    private var mouseSprite: some View {
        let body = Color(red: 0.75, green: 0.71, blue: 0.66)
        return ZStack {
            Capsule()
                .fill(body)
                .frame(width: 90, height: 70)
                .offset(y: 18)
            HStack(spacing: 28) {
                Circle().fill(body).frame(width: 26, height: 26)
                Circle().fill(body).frame(width: 26, height: 26)
            }
            .offset(y: -22)
            faceFeatures(eyeOffset: 12, mouthY: 4)
            Path { p in
                p.move(to: CGPoint(x: 40, y: 30))
                p.addQuadCurve(
                    to: CGPoint(x: 80, y: 50),
                    control: CGPoint(x: 70, y: 10)
                )
            }
            .stroke(body, style: StrokeStyle(lineWidth: 4, lineCap: .round))
        }
    }

    private var dinoSprite: some View {
        let body = Color(red: 0.50, green: 0.69, blue: 0.45)
        return ZStack {
            RoundedRectangle(cornerRadius: 22)
                .fill(body)
                .frame(width: 130, height: 90)
                .offset(y: 16)
            Path { p in
                let baseY: CGFloat = -28
                for i in 0..<5 {
                    let x = CGFloat(i - 2) * 16
                    p.move(to: CGPoint(x: x - 6, y: baseY))
                    p.addLine(to: CGPoint(x: x, y: baseY - 12))
                    p.addLine(to: CGPoint(x: x + 6, y: baseY))
                }
            }
            .fill(body.opacity(0.85))
            .offset(x: 0, y: 10)
            faceFeatures(eyeOffset: 14, mouthY: 4)
        }
    }

    private func faceFeatures(eyeOffset: CGFloat, mouthY: CGFloat) -> some View {
        ZStack {
            Circle().fill(Theme.accent).frame(width: 8, height: 8)
                .offset(x: -eyeOffset, y: -2)
            Circle().fill(Theme.accent).frame(width: 8, height: 8)
                .offset(x: eyeOffset, y: -2)
            Path { p in
                p.move(to: CGPoint(x: -8, y: mouthY))
                p.addQuadCurve(
                    to: CGPoint(x: 8, y: mouthY),
                    control: CGPoint(x: 0, y: mouthY + 6)
                )
            }
            .stroke(Theme.accent, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
            .offset(y: 12)
        }
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    HStack {
        ForEach(["Capybara", "Cat", "Dog", "Mouse", "Dinosaur"], id: \.self) { sp in
            VStack {
                PetSprite(species: sp, state: .idle)
                    .frame(width: 150, height: 150)
                Text(sp).font(.caption)
            }
        }
    }
    .padding()
    .background(Theme.background)
}
