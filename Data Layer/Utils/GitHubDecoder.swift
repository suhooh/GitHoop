import Foundation


protocol DecoderType {
  func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable
}

extension JSONDecoder: DecoderType {}

class GitHubDecoder: JSONDecoder {
  init(dateFormatter: DateFormatter) {
    super.init()
    keyDecodingStrategy = .convertFromSnakeCase
    dateDecodingStrategy = .formatted(dateFormatter)
  }
}
