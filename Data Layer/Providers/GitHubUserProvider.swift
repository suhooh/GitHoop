import Foundation
import Moya
import RxSwift


final class GitHubUserProvider: UserProviderType {
  private lazy var decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    decoder.dateDecodingStrategy = .formatted(.iso8601Full)
    return decoder
  }()

  let provider = MoyaProvider<GitHubTarget>()

  func fetchUsers(since: Int?) -> Single<Result<UserList, UserProviderError>> {
    return provider.rx.request(.users(since)).map { [unowned self] response in
      do {
        let users = try self.decoder.decode([UserEntity].self, from: response.data)
        let since = self.extractSinceValue(response: response.response)
        return .success(UserList(users: users.map { $0.asUser }, since: since))
      } catch {
        return .failure(.fetchFailure)
      }
    }
  }

  func fetchUser(_ username: String) -> Single<Result<User?, UserProviderError>> {
    return provider.rx.request(.user(username)).map { response in
      do {
        let userEntity = try self.decoder.decode(UserEntity.self, from: response.data)
        return .success(userEntity.asUser)
      } catch {
        return .failure(.fetchFailure)
      }
    }
  }

  func searchUsers(query: String, page: Int) -> Single<Result<SearchUser, UserProviderError>> {
    return provider.rx.request(.searchUsers(query, page: page)).map { response in
      do {
        let searchResponse = try self.decoder.decode(SearchUserResponse.self, from: response.data)
        let searchUser = SearchUser(users: searchResponse.items.map { $0.asUser }, page: page)
        return .success(searchUser)
      } catch {
        return .failure(.fetchFailure)
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
