import Foundation
import Moya


enum GitHubTarget {
  case users(_ since: Int?)
  case user(_ username: String)
  case searchUsers(_ users: String, page: Int?)
}

extension GitHubTarget: TargetType {
  var baseURL: URL { return URL(string: "https://api.github.com")! }
  
  var path: String {
    switch self {
    case .users:
      return "/users"
    case .user(let username):
      return "/users/\(username)"
    case .searchUsers:
      return "/search/users"
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .users, .user, .searchUsers:
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
    case .searchUsers(let users, let page):
      let params = [
        "q": String(users),
        "page": String(page ?? 1)
      ]
      return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
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
    case .searchUsers:
      return SampleResponse.searchUsers.utf8Encoded
    }
  }
}
