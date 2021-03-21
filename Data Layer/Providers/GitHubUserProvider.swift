import Foundation
import RxSwift


final class GitHubUserProvider: UserProviderType {

  private let endpoint: EndpointType
  private let decoder: DecoderType
  private lazy var networkNotReachableError: UserProviderError = {
    .fetchFailure("Internet Connection not Available.")
  }()

  init(endpoint: EndpointType, decoder: DecoderType) {
    self.endpoint = endpoint
    self.decoder = decoder
  }

  // MARK: - UserProviderType

  func searchUsers(query: String, page: Int) -> Single<Result<UserList, UserProviderError>> {
    return Reachability.isConnectedToNetwork ?
      endpoint.rx.request(.searchUsers(query, page: page)).map { response in
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
        return .failure(self.generateFetchError(data: response.data))
      }
    } : .just(.failure(networkNotReachableError))
  }

  func fetchUser(_ username: String) -> Single<Result<User?, UserProviderError>> {
    return Reachability.isConnectedToNetwork ?
      endpoint.rx.request(.user(username)).map { response in
      switch response.statusCode {
      case 200:
        do {
          let userEntity = try self.decoder.decode(UserEntity.self, from: response.data)
          return .success(userEntity.asUser)
        } catch {
          return .failure(self.generateDecodeError(error))
        }
      default:
        return .failure(self.generateFetchError(data: response.data))
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

  private func generateFetchError(data: Data) -> UserProviderError {
    do {
      let error = try decoder.decode(ErrorResponse.self, from: data)
      return .fetchFailure(error.message)
    } catch {
      return .fetchFailure(error.localizedDescription)
    }
  }
}
