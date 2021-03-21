import Foundation
import RxSwift


protocol UserProviderType {
  func searchUsers(query: String, page: Int) -> Single<Result<UserList, UserProviderError>>
  func fetchUser(_ username: String) -> Single<Result<User?, UserProviderError>>
}

enum UserProviderError: Error {
  case fetchFailure(String)
  case decodeFailure(String)
  case unknown(String)
}
