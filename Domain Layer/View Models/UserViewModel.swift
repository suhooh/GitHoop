import Foundation
import RxSwift
import RxCocoa


final class UserViewModel: UserViewModelType {

  struct UserViewModelInput: UserViewModelInputType {
    let username = PublishSubject<String>()
  }
  struct UserViewModelOutput: UserViewModelOutputType {
    let user = BehaviorRelay<User?>(value: nil)
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
    input.username
      .flatMap { [unowned self] username in
        self.userProvider.fetchUser(username)
      }
      .map { result -> User? in
        if case .success(let user) = result {
          return user
        } else {
          return nil
        }
      }
      .bind(to: output.user)
      .disposed(by: bag)
  }
}
