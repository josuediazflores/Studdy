import SwiftUI

struct AvatarSprite: View {
    let avatar: Avatar
    var isHappy: Bool = true

    private var accent: Color { Theme.color(fromHex: avatar.accentColorHex) }

    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height)
            ZStack {
                Circle()
                    .fill(accent.opacity(0.18))
                Circle()
                    .stroke(accent, lineWidth: max(2, s * 0.025))

                ZStack {
                    body(size: s)
                    head(size: s)
                    hair(size: s)
                    face(size: s)
                }
                .frame(width: s, height: s)
            }
            .frame(width: s, height: s)
        }
    }

    @ViewBuilder
    private func body(size s: CGFloat) -> some View {
        let bodyW = s * 0.55
        let bodyH = s * 0.40
        let bodyY = s * 0.72
        ZStack {
            RoundedRectangle(cornerRadius: bodyW * 0.5)
                .fill(outfitColor)
                .frame(width: bodyW, height: bodyH)
            outfitDetail(size: s, bodyW: bodyW, bodyH: bodyH)
        }
        .position(x: s / 2, y: bodyY)
    }

    @ViewBuilder
    private func outfitDetail(size s: CGFloat, bodyW: CGFloat, bodyH: CGFloat) -> some View {
        switch avatar.outfit {
        case "Overalls":
            HStack(spacing: bodyW * 0.4) {
                Capsule().fill(Theme.accent).frame(width: bodyW * 0.08, height: bodyH * 0.7)
                Capsule().fill(Theme.accent).frame(width: bodyW * 0.08, height: bodyH * 0.7)
            }
        case "Hoodie":
            Capsule()
                .fill(outfitColor.opacity(0.7))
                .frame(width: bodyW * 0.85, height: bodyH * 0.4)
                .offset(y: -bodyH * 0.25)
        case "Dress":
            Path { path in
                path.move(to: CGPoint(x: -bodyW * 0.45, y: bodyH * 0.4))
                path.addLine(to: CGPoint(x: -bodyW * 0.6, y: bodyH * 0.55))
                path.addLine(to: CGPoint(x: bodyW * 0.6, y: bodyH * 0.55))
                path.addLine(to: CGPoint(x: bodyW * 0.45, y: bodyH * 0.4))
                path.closeSubpath()
            }
            .fill(outfitColor)
        case "Pajamas":
            HStack(spacing: bodyW * 0.15) {
                Image(systemName: "moon.stars.fill").foregroundStyle(.white.opacity(0.85))
                Image(systemName: "moon.stars.fill").foregroundStyle(.white.opacity(0.85))
            }
            .font(.system(size: s * 0.05))
        default:
            Rectangle()
                .fill(outfitColor.opacity(0.5))
                .frame(width: bodyW * 0.7, height: 1.5)
        }
    }

    @ViewBuilder
    private func head(size s: CGFloat) -> some View {
        Circle()
            .fill(Color(red: 0.99, green: 0.87, blue: 0.76))
            .overlay(Circle().stroke(Theme.accent.opacity(0.6), lineWidth: max(1, s * 0.012)))
            .frame(width: s * 0.42, height: s * 0.42)
            .position(x: s / 2, y: s * 0.42)
    }

    @ViewBuilder
    private func hair(size s: CGFloat) -> some View {
        let headW = s * 0.42
        let cy = s * 0.42
        switch avatar.hairStyle {
        case "Bun":
            ZStack {
                Circle()
                    .fill(hairColor)
                    .frame(width: headW * 0.45, height: headW * 0.45)
                    .position(x: s / 2, y: cy - headW * 0.55)
                Path { p in
                    p.addArc(
                        center: CGPoint(x: s / 2, y: cy),
                        radius: headW * 0.5,
                        startAngle: .degrees(180),
                        endAngle: .degrees(360),
                        clockwise: false
                    )
                }
                .stroke(hairColor, lineWidth: headW * 0.18)
            }
        case "Pigtails":
            HStack(spacing: headW * 0.85) {
                Capsule().fill(hairColor).frame(width: headW * 0.22, height: headW * 0.55)
                Capsule().fill(hairColor).frame(width: headW * 0.22, height: headW * 0.55)
            }
            .position(x: s / 2, y: cy + headW * 0.05)
        case "Long":
            RoundedRectangle(cornerRadius: headW * 0.3)
                .fill(hairColor)
                .frame(width: headW * 1.05, height: headW * 1.1)
                .position(x: s / 2, y: cy + headW * 0.18)
                .mask(
                    Rectangle()
                        .frame(width: headW * 1.05, height: headW * 0.85)
                        .position(x: s / 2, y: cy + headW * 0.35)
                )
        case "Short":
            Path { p in
                p.addArc(
                    center: CGPoint(x: s / 2, y: cy),
                    radius: headW * 0.5,
                    startAngle: .degrees(180),
                    endAngle: .degrees(360),
                    clockwise: false
                )
            }
            .stroke(hairColor, lineWidth: headW * 0.15)
        case "Braid":
            VStack(spacing: -headW * 0.05) {
                ForEach(0..<3, id: \.self) { _ in
                    Circle()
                        .fill(hairColor)
                        .frame(width: headW * 0.22, height: headW * 0.22)
                }
            }
            .position(x: s / 2 + headW * 0.45, y: cy + headW * 0.25)
        default:
            Circle().fill(hairColor)
                .frame(width: headW * 0.5, height: headW * 0.5)
                .position(x: s / 2, y: cy - headW * 0.4)
        }
    }

    @ViewBuilder
    private func face(size s: CGFloat) -> some View {
        let cy = s * 0.42
        let eyeY = cy - s * 0.02
        let eyeOffset = s * 0.07
        ZStack {
            Circle().fill(Theme.accent).frame(width: s * 0.04, height: s * 0.04)
                .position(x: s / 2 - eyeOffset, y: eyeY)
            Circle().fill(Theme.accent).frame(width: s * 0.04, height: s * 0.04)
                .position(x: s / 2 + eyeOffset, y: eyeY)

            Path { p in
                let mouthY = cy + s * 0.06
                if isHappy {
                    p.move(to: CGPoint(x: s / 2 - s * 0.05, y: mouthY))
                    p.addQuadCurve(
                        to: CGPoint(x: s / 2 + s * 0.05, y: mouthY),
                        control: CGPoint(x: s / 2, y: mouthY + s * 0.04)
                    )
                } else {
                    p.move(to: CGPoint(x: s / 2 - s * 0.05, y: mouthY + s * 0.02))
                    p.addQuadCurve(
                        to: CGPoint(x: s / 2 + s * 0.05, y: mouthY + s * 0.02),
                        control: CGPoint(x: s / 2, y: mouthY - s * 0.02)
                    )
                }
            }
            .stroke(Theme.accent, style: StrokeStyle(lineWidth: max(1.5, s * 0.012), lineCap: .round))

            if isHappy {
                Circle().fill(accent.opacity(0.4)).frame(width: s * 0.05, height: s * 0.04)
                    .position(x: s / 2 - eyeOffset - s * 0.02, y: eyeY + s * 0.06)
                Circle().fill(accent.opacity(0.4)).frame(width: s * 0.05, height: s * 0.04)
                    .position(x: s / 2 + eyeOffset + s * 0.02, y: eyeY + s * 0.06)
            }
        }
    }

    private var hairColor: Color {
        Color(red: 0.36, green: 0.24, blue: 0.16)
    }

    private var outfitColor: Color {
        switch avatar.outfit {
        case "Overalls":     return Theme.sky
        case "Hoodie":       return accent
        case "Dress":        return accent
        case "Pajamas":      return Color(red: 0.49, green: 0.35, blue: 0.62)
        default:             return accent.opacity(0.85)
        }
    }
}

#Preview {
    HStack(spacing: 16) {
        AvatarSprite(avatar: Avatar(hairStyle: "Bun", outfit: "Cozy Sweater", accentColorHex: "#D58E60"))
            .frame(width: 140, height: 140)
        AvatarSprite(avatar: Avatar(hairStyle: "Pigtails", outfit: "Overalls", accentColorHex: "#7BB661"), isHappy: false)
            .frame(width: 140, height: 140)
    }
    .padding()
    .background(Theme.background)
}
