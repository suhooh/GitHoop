import XCTest
import RxSwift
import RxTest
@testable import GitHoop


class UserListViewModelTests: XCTestCase {

  var viewModel: UserListViewModel!
  var serviceMock: GitHubServiceMock!
  var coordinatorMock: AppCoordinatorMock!
  var bag: DisposeBag!
  let scheduler = TestScheduler(initialClock: 0)

  override func setUp() {
    serviceMock = GitHubServiceMock()
    coordinatorMock = AppCoordinatorMock()
    viewModel = UserListViewModel(service: serviceMock, router: coordinatorMock.anyRouter)
    bag = DisposeBag()
  }

  func test_requestNextUserList_fetchUsers() {
    // Precondition: none
    // In: requestNextUserList event
    // Out: users output event

    let usersObserver = scheduler.createObserver([Int].self)

    viewModel.output.users
      .map { users in users.map { $0.id } }
      .bind(to: usersObserver)
      .disposed(by: bag)

    scheduler.createColdObservable([
        .next(1, ()),
        .next(2, ())
      ])
      .bind(to: viewModel.input.requestNextUserList)
      .disposed(by: bag)

    scheduler.start()

    XCTAssertEqual(usersObserver.events, Recorded.events(
      .next(0, []),
      .next(1, serviceMock.userList.users.map { $0.id }),
      .next(2, (serviceMock.userList.users + serviceMock.userList.users).map { $0.id })
    ))
  }

  func test_selectedUser_triggersUserRoute() {
    // Precondition: none
    // In: selectedUser event
    // Out: .user(username:) route trigger

    let routeObserver = scheduler.createObserver(UserListRoute.self)

    coordinatorMock.triggeredRoute
      .bind(to: routeObserver)
      .disposed(by: bag)

    let username = "testuser"
    scheduler.createColdObservable([
        .next(1, username)
      ])
      .bind(to: viewModel.input.selectedUser)
      .disposed(by: bag)

    scheduler.start()


    XCTAssertEqual(routeObserver.events, Recorded.events(
      .next(1, .user(username: username))
    ))
  }

  func test_viewType_triggersUserListRoute() {
    // Precondition: none
    // In: viewType event
    // Out: .userList(type:) route trigger

    let routeObserver = scheduler.createObserver(UserListRoute.self)

    coordinatorMock.triggeredRoute
      .bind(to: routeObserver)
      .disposed(by: bag)

    scheduler.createColdObservable([
        .next(1, .list),
        .next(2, .grid)
      ])
      .bind(to: viewModel.input.viewType)
      .disposed(by: bag)

    scheduler.start()


    XCTAssertEqual(routeObserver.events, Recorded.events(
      .next(1, .userList(type: .list)),
      .next(2, .userList(type: .grid))
    ))
  }
}
