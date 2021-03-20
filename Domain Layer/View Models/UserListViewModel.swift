import Foundation
import XCoordinator
import RxSwift
import RxCocoa


final class UserListViewModel: UserListViewModelType {

  struct UserListViewModelInput: UserListViewModelInputType {
    let requestNextUserList = PublishSubject<Void>()
    let selectedUser = PublishSubject<String>()
    let viewType = PublishSubject<UserListType>()
  }
  struct UserListViewModelOutput: UserListViewModelOutputType {
    let users = BehaviorRelay<[User]>(value: [])
    internal let nextIndex = BehaviorRelay<Int?>(value: nil)
  }

  private let userProvider: UserProviderType
  private let router: AnyRouter<UserListRoute>
  private let bag = DisposeBag()

  init(provider: UserProviderType, router: AnyRouter<UserListRoute>) {
    self.userProvider = provider
    self.router = router
    super.init(
      input: UserListViewModelInput(),
      output: UserListViewModelOutput()
    )
    bind()
  }

  private func bind() {
    let userList = Observable.zip(input.requestNextUserList, output.nextIndex) { $1 }
      .flatMap { [unowned self] next in
        self.userProvider.fetchUsers(since: next)
      }
      .map { result -> UserList in
        if case .success(let list) = result {
          return list
        } else {
          return UserList(users: [], since: 0)
        }
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
