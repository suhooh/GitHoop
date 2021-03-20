import Foundation
import XCoordinator
import RxSwift
import RxCocoa


final class UserListViewModel: UserListViewModelType {

  struct UserListViewModelInput: UserListViewModelInputType {
    let requestNextPage = PublishSubject<Void>()
    let searchUsersText = PublishSubject<String>()
    let selectedUser = PublishSubject<String>()
    let viewType = PublishSubject<UserListType>()
  }
  struct UserListViewModelOutput: UserListViewModelOutputType {
    let users = BehaviorRelay<[User]>(value: [])
    internal let currentPage = BehaviorRelay<Int>(value: 0)
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
    let searchByText = input.searchUsersText
      .distinctUntilChanged()
      .filter { !$0.isEmpty }
      .flatMap { [unowned self] text in
        self.userProvider.searchUsers(query: text, page: 1)
      }
      .map { result -> SearchUser in
        if case .success(let searchUser) = result {
          return searchUser
        } else {
          return SearchUser(users: [], page: 0)
        }
      }
      .share()

    searchByText
      .map { $0.users }
      .bind(to: output.users)
      .disposed(by: bag)

    input.searchUsersText
      .filter { $0.isEmpty }
      .map { _ in [] }
      .bind(to: output.users)
      .disposed(by: bag)

    input.searchUsersText
      .filter { $0.isEmpty }
      .map { _ in 0 }
      .bind(to: output.currentPage)
      .disposed(by: bag)

    let searchByPage = input.requestNextPage
      .withLatestFrom(Observable.combineLatest(input.searchUsersText, output.currentPage)) { (text: $1.0, page: $1.1) }
      .filter { !$0.text.isEmpty }
      .flatMap { [unowned self] event in
        self.userProvider.searchUsers(query: event.text, page: event.page + 1)
      }
      .map { result -> SearchUser in
        if case .success(let searched) = result {
          return searched
        } else {
          return SearchUser(users: [], page: 0)
        }
      }
      .share()

    searchByPage
      .map { $0.users }
      .withLatestFrom(output.users) { (fetched: $0, existing: $1) }
      .map { $0.existing + $0.fetched }
      .bind(to: output.users)
      .disposed(by: bag)

    Observable.merge(searchByText, searchByPage)
      .map { $0.page }
      .bind(to: output.currentPage)
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
