import Foundation


struct ErrorResponse: Decodable {
  let message: String
  let documentationUrl: String?
}
