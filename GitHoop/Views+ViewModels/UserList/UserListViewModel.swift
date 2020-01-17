import Foundation
import XCoordinator
import RxSwift
import RxCocoa


final class UserListViewModel: RxViewModel {

  struct Input {
    let requestNextUserList = PublishSubject<Void>()
    let selectedUser = PublishSubject<String>()
    let viewType = PublishSubject<UserListType>()
  }
  struct Output {
    let users = BehaviorRelay<[User]>(value: [])
    fileprivate let nextIndex = BehaviorRelay<Int?>(value: nil)
  }

  let input = Input()
  let output = Output()

  private let service: GitHubServiceType
  private let router: AnyRouter<UserListRoute>
  private let bag = DisposeBag()

  init(service: GitHubServiceType = GitHubService(), router: AnyRouter<UserListRoute>) {
    self.service = service
    self.router = router
    bind()
  }

  private func bind() {
    let userList = Observable.zip(input.requestNextUserList, output.nextIndex) { $1 }
      .flatMap { [unowned self] next in
        self.service.fetchUsers(since: next)
      }
      .share()

    userList
      .map { $0.users }
      .withLatestFrom(output.users) { (fetched: $0, existing: $1) }
      .map { $0.existing + $0.fetched }
      .bind(to: output.users)
      .disposed(by: bag)

    userList
      .map { $0.since }
      .bind(to: output.nextIndex)
      .disposed(by: bag)

    input.selectedUser
      .bind { [unowned self] username in
        self.router.trigger(.user(username: username))
      }
      .disposed(by: bag)

    input.viewType
      .bind { type in
        self.router.trigger(.userList(type: type))
      }
      .disposed(by: bag)
  }
}
