import Foundation
import RxSwift
import RxCocoa


final class UserViewModel: UserViewModelType {

  struct UserViewModelInput: UserViewModelInputType {
    let username = PublishSubject<String>()
  }
  struct UserViewModelOutput: UserViewModelOutputType {
    let user = PublishSubject<User>()
    let alertMessage = PublishSubject<String>()
  }

  private let userProvider: UserProviderType
  private let bag = DisposeBag()

  init(provider: UserProviderType) {
    self.userProvider = provider
    super.init(
      input: UserViewModelInput(),
      output: UserViewModelOutput()
    )
    bind()
  }

  private func bind() {
    let fetchUserResult = input.username
      .flatMap { [unowned self] username in
        self.userProvider.fetchUser(username)
      }
      .share()

    fetchUserResult
      .map { result -> User? in
        if case .success(let user) = result {
          return user
        } else {
          return nil
        }
      }
      .filterNil()
      .bind(to: output.user)
      .disposed(by: bag)

    fetchUserResult
      .flatMap { result -> Observable<String?> in
        let errorMessage: String? = {
          if case .failure(let error) = result {
            switch error {
            case .fetchFailure(let msg): return msg
            case .decodeFailure(let msg): return msg
            case .unknown(let msg): return msg
            }
          }
          return nil
        }()
        return .just(errorMessage)
      }
      .filterNil()
      .bind(to: output.alertMessage)
      .disposed(by: bag)
  }
}
