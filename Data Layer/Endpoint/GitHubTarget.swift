import Foundation
import Moya


enum GitHubTarget {
  case searchUsers(_ users: String, page: Int?)
  case user(_ username: String)
}

extension GitHubTarget: TargetType {
  var baseURL: URL { return URL(string: "https://api.github.com")! }
  
  var path: String {
    switch self {
    case .searchUsers:
      return "/search/users"
    case .user(let username):
      return "/users/\(username)"
    }
  }
  
  var method: Moya.Method { .get }
  
  var task: Task {
    switch self {
    case .searchUsers(let users, let page):
      let params = [
        "q": String(users),
        "page": String(page ?? 1)
      ]
      return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
    case .user:
      return .requestPlain
    }
  }
  
  var headers: [String: String]? {
    return ["Content-type": "application/json"]
  }
  
  var sampleData: Data {
    switch self {
    case .searchUsers:
      return SampleResponse.searchUsers.utf8Encoded
    case .user(let username):
      return username != SampleResponse.invalidUsername
        ? SampleResponse.user(username: username).utf8Encoded
        : SampleResponse.userNotFound.utf8Encoded
    }
  }
}
