import Foundation
import UserNotifications

class NotificationManager {
    static func scheduleNotification(for medication: Medication) {
        if !medication.selectedDaysOfWeek.isEmpty {
            for selectedDay in medication.selectedDaysOfWeek {
                var dateComponents = DateComponents()
                dateComponents.hour = Calendar.current.component(.hour, from: medication.timeOfDay)
                dateComponents.minute = Calendar.current.component(.minute, from: medication.timeOfDay)
                dateComponents.weekday = selectedDay.calendarValue
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

                scheduleNotification(for: medication, with: trigger)
            }
        } else {
            let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.hour, .minute], from: medication.timeOfDay), repeats: true)
            scheduleNotification(for: medication, with: trigger)
        }
    }
    
    private static func scheduleNotification(for medication: Medication, with trigger: UNNotificationTrigger) {
        let content = UNMutableNotificationContent()
        content.title = "Medication Reminder"
        content.body = "It's time to take \(medication.name)."
        content.sound = UNNotificationSound.default
        
        let identifier = "\(medication.name)-\(medication.dosage)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                if let nextDate = (trigger as? UNCalendarNotificationTrigger)?.nextTriggerDate {
                    print("Notification scheduled successfully for \(medication.name) at \(nextDate)")
                }
            }
        }
    }
}

extension DayOfWeek {
    var calendarValue: Int {
        switch self {
        case .sunday: return 1
        case .monday: return 2
        case .tuesday: return 3
        case .wednesday: return 4
        case .thursday: return 5
        case .friday: return 6
        case .saturday: return 7
        }
    }
}

// Sources:
//https://developer.apple.com/documentation/usernotifications
//https://developer.apple.com/documentation/usernotifications/unusernotificationcenterdelegate
//https://developer.apple.com/documentation/usernotifications/unnotificationrequest
//https://developer.apple.com/documentation/usernotifications/unnotificationtrigger
