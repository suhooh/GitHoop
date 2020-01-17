import Foundation
import Moya
import RxSwift


protocol GitHubServiceType {
  func fetchUsers(since: Int?) -> Single<UserList>
  func fetchUser(_ username: String) -> Single<User?>
}

final class GitHubService {
  static var decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    decoder.dateDecodingStrategy = .formatted(.iso8601Full)
    return decoder
  }()

  let provider = MoyaProvider<GitHubTarget>()
}

extension GitHubService: GitHubServiceType {
  func fetchUsers(since: Int?) -> Single<UserList> {
    return provider.rx.request(.users(since)).map { [unowned self] response in
      do {
        let users = try GitHubService.decoder.decode([User].self, from: response.data)
        let since = self.extractSinceValue(response: response.response)
        return UserList(users: users, since: since)
      } catch {
        return UserList(users: [], since: nil)
      }
    }
  }

  func fetchUser(_ username: String) -> Single<User?> {
    return provider.rx.request(.user(username)).map { response in
      do {
        return try GitHubService.decoder.decode(User.self, from: response.data)
      } catch {
        return nil
      }
    }
  }

  private func extractSinceValue(response: HTTPURLResponse?) -> Int? {
    guard
      let nextUrlString = response?.linksFromHeader["next"],
      let since = nextUrlString.getQueryString(parameter: "since")
      else {
        return nil
    }
    return Int(since)
  }
}

// MARK:- HTTPURLResponse extension: extracting Link header into dictionary

extension HTTPURLResponse {
  var linksFromHeader: [String:String] {
    // e.g. Link: `<https://api.github.com/users?since=46>; rel="next"`
    guard let linkHeader = allHeaderFields["Link"] as? String else { return [:] }

    var links: [String:String] = [:]
    linkHeader.components(separatedBy: ", ").forEach { entry in
      let parts = entry.components(separatedBy: "; ")
      guard parts.count == 2 else { return }
      let targets = parts[1].components(separatedBy: "=")
      guard targets.count == 2 else { return }
      let key = targets[1].trimmingCharacters(in: CharacterSet(charactersIn: "\""))
      let url = parts[0].trimmingCharacters(in: CharacterSet(charactersIn: "<>"))
      links[key] = url
    }
    return links
  }
}
