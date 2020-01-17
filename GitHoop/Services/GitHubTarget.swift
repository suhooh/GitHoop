import Foundation
import Moya


enum GitHubTarget {
  case users(_ since: Int?)
  case user(_ username: String)
}

extension GitHubTarget: TargetType {
  var baseURL: URL { return URL(string: "https://api.github.com")! }

  var path: String {
    switch self {
    case .users:
      return "/users"
    case .user(let username):
      return "/users/\(username)"
    }
  }

  var method: Moya.Method {
    switch self {
    case .users, .user:
      return .get
    }
  }

  var task: Task {
    switch self {
    case .users(let since):
      guard let since = since else { return .requestPlain }
      return .requestParameters(parameters: ["since": String(since)], encoding: URLEncoding.queryString)
    case .user:
      return .requestPlain
    }
  }

  var headers: [String: String]? {
    return ["Content-type": "application/json"]
  }

  var sampleData: Data {
    switch self {
    case .users:
      return SampleResponse.users.utf8Encoded
    case .user(let username):
      return SampleResponse.user(username: username).utf8Encoded
    }
  }
}
