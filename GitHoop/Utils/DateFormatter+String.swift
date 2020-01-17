import Foundation


extension DateFormatter {
  static func MMMdYYYY(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d, yyyy"
    return formatter.string(from: date)
  }
}
