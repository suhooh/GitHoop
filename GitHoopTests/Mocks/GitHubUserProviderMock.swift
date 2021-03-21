import Foundation
import RxSwift
@testable import GitHoop


class GitHubUserProviderMock: UserProviderType {

  private lazy var decoder: DecoderType = GitHubDecoder(dateFormatter: DateFormatter.iso8601Full)
  var page: Int = 1

  // MARK: - sample responses

  var userList: UserList {
    defer { page += 1 }
    let usersResponse = try! decoder.decode(SearchUserResponse.self, from: GitHubTarget.searchUsers("", page: nil).sampleData)
    return UserList(users: usersResponse.items.map { $0.asUser }, page: page)
  }

  func user(_ username: String) -> UserEntity {
    return try! decoder.decode(UserEntity.self, from: GitHubTarget.user(username).sampleData)
  }

  var userNotFound: ErrorResponse {
    return try! decoder.decode(ErrorResponse.self, from: GitHubTarget.user(GitHubTarget.SampleResponse.invalidUsername).sampleData)
  }

  // MARK: - UserProviderType

  func searchUsers(query: String, page: Int) -> Single<Result<UserList, UserProviderError>> {
    return .just(.success(self.userList))
  }

  func fetchUser(_ username: String) -> Single<Result<User?, UserProviderError>> {
    return username != GitHubTarget.SampleResponse.invalidUsername
      ? .just(.success(self.user(username).asUser))
      : .just(.failure(.fetchFailure(userNotFound.message)))
  }
}
