import XCTest
import RxSwift
import RxTest
@testable import GitHoop


class UserViewModelTests: XCTestCase {

  var viewModel: UserViewModel!
  var providerMock: GitHubUserProviderMock!
  var bag: DisposeBag!
  let scheduler = TestScheduler(initialClock: 0)

  override func setUp() {
    providerMock = GitHubUserProviderMock()
    viewModel = UserViewModel(provider: providerMock)
    bag = DisposeBag()
  }

  func test_username_fetchUser() {
    // Precondition: none
    // In: username event
    // Out: user output event

    let userObserver = scheduler.createObserver(String?.self)

    viewModel.output.user
      .map { $0?.login }
      .bind(to: userObserver)
      .disposed(by: bag)

    scheduler.createColdObservable([
      .next(1, "user1"),
      .next(2, "user2")
      ])
      .bind(to: viewModel.input.username)
      .disposed(by: bag)

    scheduler.start()

    XCTAssertEqual(userObserver.events, Recorded.events(
      .next(0, nil),
      .next(1, "user1"),
      .next(2, "user2")
    ))
  }
}
