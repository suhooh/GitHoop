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

  func test_validUsername_fetchesUser() {
    // Precondition: none
    // Input: username
    // Output: user

    let output = scheduler.createObserver(String?.self)

    viewModel.output.user
      .map { $0.login }
      .bind(to: output)
      .disposed(by: bag)

    scheduler.createColdObservable([
      .next(1, "user1"),
      .next(2, "user2")
      ])
      .bind(to: viewModel.input.username)
      .disposed(by: bag)

    scheduler.start()

    XCTAssertEqual(output.events, Recorded.events(
      .next(1, "user1"),
      .next(2, "user2")
    ))
  }

  func test_invalidUserName_emitsNoUser() {
    // Precondition: none
    // Input: invalid username
    // Output: no user

    let output = scheduler.createObserver(String?.self)

    viewModel.output.user
      .map { $0.login }
      .bind(to: output)
      .disposed(by: bag)

    // Input
    scheduler.createColdObservable([
      .next(1, GitHubTarget.SampleResponse.invalidUsername),
      .next(2, "user2")
      ])
      .bind(to: viewModel.input.username)
      .disposed(by: bag)

    scheduler.start()

    // Output
    XCTAssertEqual(output.events, Recorded.events(
      .next(2, "user2")
    ))
  }

  func test_invalidUserName_alertMessage() {
    // Precondition: none
    // Input: invalid username
    // Output: alert message

    let output = scheduler.createObserver(String.self)

    viewModel.output.alertMessage
      .bind(to: output)
      .disposed(by: bag)

    // Input
    scheduler.createColdObservable([
      .next(1, GitHubTarget.SampleResponse.invalidUsername),
      .next(2, "user2")
      ])
      .bind(to: viewModel.input.username)
      .disposed(by: bag)

    scheduler.start()

    // Output
    XCTAssertEqual(output.events, Recorded.events(
      .next(1, providerMock.userNotFound.message)
    ))
  }
}
