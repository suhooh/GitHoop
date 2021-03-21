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

  let gitHubEndopint = MoyaProvider<GitHubTarget>()
  private lazy var networkNotReachableError: UserProviderError = {
    .fetchFailure("Internet Connection not Available.")
  }()

  // MARK: - UserProviderType

  func searchUsers(query: String, page: Int) -> Single<Result<UserList, UserProviderError>> {
    return Reachability.isConnectedToNetwork ?
      gitHubEndopint.rx.request(.searchUsers(query, page: page)).map { response in
      switch response.statusCode {
      case 200:
        do {
          let searchResponse = try self.decoder.decode(SearchUserResponse.self, from: response.data)
          let searchUser = UserList(users: searchResponse.items.map { $0.asUser }, page: page)
          return .success(searchUser)
        } catch {
          return .failure(self.generateDecodeError(error))
        }
      default:
        return .failure(self.generateFetchError(response: response))
      }
    } : .just(.failure(networkNotReachableError))
  }

  func fetchUser(_ username: String) -> Single<Result<User?, UserProviderError>> {
    return Reachability.isConnectedToNetwork ?
      gitHubEndopint.rx.request(.user(username)).map { response in
      switch response.statusCode {
      case 200:
        do {
          let userEntity = try self.decoder.decode(UserEntity.self, from: response.data)
          return .success(userEntity.asUser)
        } catch {
          return .failure(self.generateDecodeError(error))
        }
      default:
        return .failure(self.generateFetchError(response: response))
      }
    } : .just(.failure(networkNotReachableError))
  }

  private func generateDecodeError(_ error: Error) -> UserProviderError {
    switch error {
    case let DecodingError.dataCorrupted(context):
      return .decodeFailure(context.debugDescription)
    case let DecodingError.keyNotFound(key, context):
      let msg = "Key '\(key)' not found:" + context.debugDescription
      return .decodeFailure(msg)
    case let DecodingError.valueNotFound(value, context):
      let msg = "Value '\(value)' not found:" + context.debugDescription
      return .decodeFailure(msg)
    case let DecodingError.typeMismatch(type, context):
      let msg = "Type '\(type)' mismatch:" + context.debugDescription
      return .decodeFailure(msg)
    default:
      return .unknown(error.localizedDescription)
    }
  }

  private func generateFetchError(response: Response) -> UserProviderError {
    do {
      let error = try decoder.decode(ErrorResponse.self, from: response.data)
      return .fetchFailure(error.message)
    } catch {
      return .fetchFailure(error.localizedDescription)
    }
  }
}
