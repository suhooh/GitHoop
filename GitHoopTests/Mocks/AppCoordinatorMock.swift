import Foundation
import XCoordinator
import RxSwift
@testable import GitHoop


class AppCoordinatorMock: NavigationCoordinator<UserListRoute> {

  let triggeredRoute = PublishSubject<UserListRoute>()

  init() {
    super.init()
  }

  override func prepareTransition(for route: UserListRoute) -> NavigationTransition {
    triggeredRoute.onNext(route)
    return NavigationTransition.none()
  }
}
