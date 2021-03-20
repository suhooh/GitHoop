import Foundation
import RxSwift
@testable import GitHoop


class GitHubUserProviderMock: UserProviderType {

  private lazy var decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    decoder.dateDecodingStrategy = .formatted(.iso8601Full)
    return decoder
  }()

  var userResponse: UsersResponse {
    let users = try! decoder.decode([UserEntity].self, from: GitHubTarget.users(nil).sampleData)
    return UsersResponse(users: users, since: 46)
  }

  func user(_ username: String) -> UserEntity {
    return try! decoder.decode(UserEntity.self, from: GitHubTarget.user(username).sampleData)
  }

  var searchedUsers: SearchUser {
    let usersResponse = try! decoder.decode(SearchUserResponse.self, from: GitHubTarget.searchUsers("", page: nil).sampleData)
    return SearchUser(users: usersResponse.items.map { $0.asUser }, page: 0)
  }

  // MARK: - UserProviderType
  func fetchUsers(since: Int?) -> Single<Result<UserList, UserProviderError>> {
    return Single<Result<UserList, UserProviderError>>.create { single in
      let userList = UserList(users: self.userResponse.users.map { $0.asUser },
                              since: self.userResponse.since)
      single(.success(.success(userList)))
      return Disposables.create()
    }
  }

  func fetchUser(_ username: String) -> Single<Result<User?, UserProviderError>> {
    return Single<Result<User?, UserProviderError>>.create { single in
      single(.success(.success(self.user(username).asUser)))
      return Disposables.create()
    }
  }

  func searchUsers(query: String, page: Int) -> Single<Result<SearchUser, UserProviderError>> {
    return Single<Result<SearchUser, UserProviderError>>.create { single in
      single(.success(.success(self.searchedUsers)))
      return Disposables.create()
    }
  }

}
