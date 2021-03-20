import Foundation
import RxSwift


protocol UserProviderType {
  func fetchUsers(since: Int?) -> Single<Result<UserList, UserProviderError>>
  func fetchUser(_ username: String) -> Single<Result<User?, UserProviderError>>
  func searchUsers(query: String, page: Int?) -> Single<Result<[User], UserProviderError>>
}

enum UserProviderError: Error {
  case fetchFailure
  case unknown
}
