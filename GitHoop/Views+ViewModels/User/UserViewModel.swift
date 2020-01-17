import Foundation
import RxSwift
import RxCocoa


final class UserViewModel: RxViewModel {

  struct Input {
    let username = PublishSubject<String>()
  }
  struct Output {
    let user = BehaviorRelay<User?>(value: nil)
  }

  let input = Input()
  let output = Output()

  private let service: GitHubServiceType
  private let bag = DisposeBag()

  init(service: GitHubServiceType = GitHubService()) {
    self.service = service
    bind()
  }

  private func bind() {
    input.username
      .flatMap { [unowned self] username in
        self.service.fetchUser(username)
      }
      .bind(to: output.user)
      .disposed(by: bag)
  }
}
