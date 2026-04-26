import Foundation
import UserNotifications

@MainActor
final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    private let petMissIds = ["pet.miss.6h", "pet.miss.12h", "pet.miss.24h"]
    private let petMissOffsets: [TimeInterval] = [
        6 * 60 * 60,
        12 * 60 * 60,
        24 * 60 * 60
    ]
    private let petMissBodies = [
        "Your buddy misses you — let's study!",
        "Hours have flown by. Your buddy needs you.",
        "A whole day already? Your buddy is sad."
    ]

    private var didRequestAuthorization = false

    func requestAuthorizationOnce() async {
        guard !didRequestAuthorization else { return }
        didRequestAuthorization = true
        let center = UNUserNotificationCenter.current()
        _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    func schedulePetMiss() {
        let center = UNUserNotificationCenter.current()
        cancelPetMiss()
        for (index, offset) in petMissOffsets.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = "Study Buddy"
            content.body = petMissBodies[index]
            content.sound = .default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: offset, repeats: false)
            let request = UNNotificationRequest(
                identifier: petMissIds[index],
                content: content,
                trigger: trigger
            )
            center.add(request)
        }
    }

    func cancelPetMiss() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: petMissIds)
    }
}
