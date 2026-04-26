import SwiftUI

struct AvatarView: View {
    let avatar: Avatar
    var size: CGFloat = 140
    var isHappy: Bool = true

    private var accent: Color { Theme.color(fromHex: avatar.accentColorHex) }

    var body: some View {
        ZStack {
            Circle()
                .fill(accent.opacity(0.25))
            Circle()
                .stroke(accent, lineWidth: 4)

            VStack(spacing: 2) {
                Image(systemName: hairSymbol)
                    .font(.system(size: size * 0.18))
                    .foregroundStyle(Theme.accent)
                Image(systemName: faceSymbol)
                    .font(.system(size: size * 0.4))
                    .foregroundStyle(accent)
                Image(systemName: outfitSymbol)
                    .font(.system(size: size * 0.18))
                    .foregroundStyle(Theme.accent.opacity(0.8))
            }
        }
        .frame(width: size, height: size)
        .accessibilityLabel("Avatar with \(avatar.hairStyle) hair and \(avatar.outfit)")
    }

    private var faceSymbol: String {
        isHappy ? "face.smiling" : "face.dashed"
    }

    private var hairSymbol: String {
        switch avatar.hairStyle {
        case "Pigtails": return "ellipsis"
        case "Long":     return "scribble.variable"
        case "Short":    return "minus"
        case "Braid":    return "wave.3.right"
        default:         return "circle.fill"
        }
    }

    private var outfitSymbol: String {
        switch avatar.outfit {
        case "Overalls":      return "rectangle.split.3x1"
        case "Hoodie":        return "hood.fill"
        case "Dress":         return "triangle.fill"
        case "Pajamas":       return "moon.stars.fill"
        default:              return "tshirt.fill"
        }
    }
}

#Preview {
    AvatarView(avatar: .default)
}
