import SwiftUI

struct AvatarView: View {
    let avatar: Avatar
    var size: CGFloat = 140
    var isHappy: Bool = true

    var body: some View {
        AvatarSprite(avatar: avatar, isHappy: isHappy)
            .frame(width: size, height: size)
            .accessibilityLabel("Avatar with \(avatar.hairStyle) hair and \(avatar.outfit)")
    }
}

#Preview {
    AvatarView(avatar: .default)
}
