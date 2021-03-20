import Foundation
import XCoordinator


enum UserListType {
  case list
  case grid
}

enum UserListRoute: Route, Equatable {
  case userList(type: UserListType)
  case user(username: String)
}

final class AppCoordinator: NavigationCoordinator<UserListRoute> {

  private let githubUserProvider: UserProviderType = GitHubUserProvider()

  private lazy var userListViewModel: UserListViewModelType = {
    UserListViewModel(provider: githubUserProvider, router: anyRouter)
  }()

  private lazy var userListViewController: UserListViewController = {
    let view = UserListViewController.initFromStoryboard()
    view.viewModel = userListViewModel
    return view
  }()

  private lazy var userCollectionViewController: UserCollectionViewController = {
    let view = UserCollectionViewController.initFromStoryboard()
    view.viewModel = userListViewModel
    return view
  }()

  private var userViewModel: UserViewModelType {
    UserViewModel(provider: githubUserProvider)
  }

  private var userViewController: UserViewController {
    let view = UserViewController.initFromStoryboard()
    view.viewModel = userViewModel
    return view
  }

  init() {
    super.init()
    anyRouter.trigger(.userList(type: .list))
  }

  override func prepareTransition(for route: UserListRoute) -> NavigationTransition {
    switch route {
    case .userList(let type):
      switch type {
      case .list:
        rootViewController.viewControllers = [userListViewController]
      case .grid:
        rootViewController.viewControllers = [userCollectionViewController]
      }
      return NavigationTransition.none()
    case .user(let username):
      let viewController = userViewController
      viewController.viewModel.input.username.onNext(username)
      return .push(viewController)
    }
  }
}
