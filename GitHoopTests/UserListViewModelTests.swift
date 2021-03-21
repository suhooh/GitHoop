import XCTest
import RxSwift
import RxTest
@testable import GitHoop


class UserListViewModelTests: XCTestCase {

  var viewModel: UserListViewModel!
  var providerMock: GitHubUserProviderMock!
  var coordinatorMock: AppCoordinatorMock!
  var bag: DisposeBag!
  let scheduler = TestScheduler(initialClock: 0)

  override func setUp() {
    providerMock = GitHubUserProviderMock()
    coordinatorMock = AppCoordinatorMock()
    viewModel = UserListViewModel(provider: providerMock, router: coordinatorMock.anyRouter)
    bag = DisposeBag()
  }

  func test_searchText_emitsUsers() {
    // Precondition: none
    // Input: search text
    // Output: users

    let output = scheduler.createObserver([Int].self)

    viewModel.output.users
      .map { users in users.map { $0.id } }
      .bind(to: output)
      .disposed(by: bag)

    scheduler.createColdObservable([
        .next(1, "abc")
      ])
      .bind(to: viewModel.input.searchUsersText)
      .disposed(by: bag)

    scheduler.start()

    XCTAssertEqual(output.events, Recorded.events(
      .next(0, []),
      .next(1, providerMock.userList.users.map { $0.id })
    ))
  }

  func test_searchText_emitsCurrentPage() {
    // Precondition: none
    // Input: search text
    // Output: page

    let output = scheduler.createObserver(Int.self)

    viewModel.output.currentPage
      .bind(to: output)
      .disposed(by: bag)

    scheduler.createColdObservable([
        .next(1, "abc")
      ])
      .bind(to: viewModel.input.searchUsersText)
      .disposed(by: bag)

    scheduler.start()

    XCTAssertEqual(output.events, Recorded.events(
      .next(0, 0),
      .next(1, 1)
    ))
  }

  func test_emptySearchText_clearsUsers() {
    // Precondition: users
    // Input: empty search text
    // Output: empty users

    let output = scheduler.createObserver([Int].self)

    viewModel.output.users
      .map { users in users.map { $0.id } }
      .bind(to: output)
      .disposed(by: bag)

    scheduler.createColdObservable([
        .next(1, "abc"),
        .next(2, "")
      ])
      .bind(to: viewModel.input.searchUsersText)
      .disposed(by: bag)

    scheduler.start()

    XCTAssertEqual(output.events, Recorded.events(
      .next(0, []),
      .next(1, providerMock.userList.users.map { $0.id }),
      .next(2, [])
    ))
  }

  func test_emptySearchText_clearsPage() {
    // Precondition: users
    // Input: empty search text
    // Output: page 0

    let output = scheduler.createObserver(Int.self)

    viewModel.output.currentPage
      .bind(to: output)
      .disposed(by: bag)

    scheduler.createColdObservable([
        .next(1, "abc"),
        .next(2, "")
      ])
      .bind(to: viewModel.input.searchUsersText)
      .disposed(by: bag)

    scheduler.start()

    XCTAssertEqual(output.events, Recorded.events(
      .next(0, 0),
      .next(1, 1),
      .next(2, 0)
    ))
  }

  func test_requestNextPage_emitsAdditionalUsers() {
    // Precondition: searched users
    // Input: request next page
    // Output: additional users

    // Precondition
    viewModel.input.searchUsersText.onNext("abc")

    let output = scheduler.createObserver([Int].self)

    viewModel.output.users
      .map { users in users.map { $0.id } }
      .bind(to: output)
      .disposed(by: bag)

    // Input
    scheduler.createColdObservable([
        .next(1, ())
      ])
      .bind(to: viewModel.input.requestNextPage)
      .disposed(by: bag)

    scheduler.start()

    // Output
    let userIds = providerMock.userList.users.map { $0.id }
    XCTAssertEqual(output.events, Recorded.events(
      .next(0, userIds),
      .next(1, userIds + userIds)
    ))
  }

  func test_requestNextPage_increaseCurrentPage() {
    // Precondition: searched users
    // Input: request next page
    // Output: increased current page

    // Precondition
    viewModel.input.searchUsersText.onNext("abc")

    let output = scheduler.createObserver(Int.self)

    viewModel.output.currentPage
      .bind(to: output)
      .disposed(by: bag)

    // Input
    scheduler.createColdObservable([
        .next(1, ()),
        .next(2, ())
      ])
      .bind(to: viewModel.input.requestNextPage)
      .disposed(by: bag)

    scheduler.start()

    // Output
    XCTAssertEqual(output.events, Recorded.events(
      .next(0, 1),
      .next(1, 2),
      .next(2, 3)
    ))
  }

  func test_selectedUser_triggersUserRoute() {
    // Precondition: none
    // Input: selectedUser event
    // Output: .user(username:) route trigger

    let routeObserver = scheduler.createObserver(UserListRoute.self)

    coordinatorMock.triggeredRoute
      .bind(to: routeObserver)
      .disposed(by: bag)

    // Input
    let username = "testuser"
    scheduler.createColdObservable([
        .next(1, username)
      ])
      .bind(to: viewModel.input.selectedUser)
      .disposed(by: bag)

    scheduler.start()

    // Output
    XCTAssertEqual(routeObserver.events, Recorded.events(
      .next(1, .user(username: username))
    ))
  }

  func test_viewType_triggersUserListRoute() {
    // Precondition: none
    // Input: viewType event
    // Output: .userList(type:) route trigger

    let routeObserver = scheduler.createObserver(UserListRoute.self)

    coordinatorMock.triggeredRoute
      .bind(to: routeObserver)
      .disposed(by: bag)

    // Input
    scheduler.createColdObservable([
        .next(1, .list),
        .next(2, .grid)
      ])
      .bind(to: viewModel.input.viewType)
      .disposed(by: bag)

    scheduler.start()

    // Output
    XCTAssertEqual(routeObserver.events, Recorded.events(
      .next(1, .userList(type: .list)),
      .next(2, .userList(type: .grid))
    ))
  }
}
