import Foundation
import XCoordinator
import RxSwift
import RxCocoa


final class UserListViewModel: UserListViewModelType {

  struct UserListViewModelInput: UserListViewModelInputType {
    let searchUsersText = PublishSubject<String>()
    let requestNextPage = PublishSubject<Void>()
    let selectedUser = PublishSubject<String>()
    let viewType = PublishSubject<UserListType>()
  }
  struct UserListViewModelOutput: UserListViewModelOutputType {
    let users = BehaviorRelay<[User]>(value: [])
    let alertMessage = PublishSubject<String>()
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
    let searchByTextResult = input.searchUsersText
      .distinctUntilChanged()
      .filter { !$0.isEmpty }
      .flatMap { [unowned self] text in
        self.userProvider.searchUsers(query: text, page: 1)
      }
      .share()

    let searchUserByText = searchByTextResult
      .map { result -> UserList in
        switch result {
        case .success(let searchUser):
          return searchUser
        case .failure:
          return UserList(users: [], page: 0)
        }
      }
      .share()

    searchUserByText
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

    let searchByPageResult = input.requestNextPage
      .withLatestFrom(Observable.combineLatest(input.searchUsersText, output.currentPage)) { (text: $1.0, page: $1.1) }
      .filter { !$0.text.isEmpty }
      .flatMap { [unowned self] event in
        self.userProvider.searchUsers(query: event.text, page: event.page + 1)
      }
      .share()

    let searchUserByPage = searchByPageResult
      .map { result -> UserList in
        if case .success(let searched) = result {
          return searched
        } else {
          return UserList(users: [], page: 0)
        }
      }
      .share()

    searchUserByPage
      .map { $0.users }
      .withLatestFrom(output.users) { (fetched: $0, existing: $1) }
      .map { $0.existing + $0.fetched }
      .bind(to: output.users)
      .disposed(by: bag)

    Observable.merge(searchUserByText, searchUserByPage)
      .map { $0.page }
      .bind(to: output.currentPage)
      .disposed(by: bag)


    Observable.merge(searchByTextResult, searchByPageResult)
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

extension Result {
    var isSuccess: Bool {
      if case .success = self { return true } else { return false }
    }
    var isError: Bool {
      return !isSuccess
    }
}
