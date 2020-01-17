import Foundation


extension String {
  func getQueryString(parameter: String) -> String? {
    return URLComponents(string: self)?.queryItems?.first(where: { $0.name == parameter })?.value
  }
}
