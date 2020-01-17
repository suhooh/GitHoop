import Foundation
import RxSwift
@testable import GitHoop


class GitHubServiceMock: GitHubServiceType {

  var userList: UserList {
    let users = try! GitHubService.decoder.decode([User].self, from: GitHubTarget.users(nil).sampleData)
    return UserList(users: users, since: 46)
  }

  func user(_ username: String) -> User {
    return try! GitHubService.decoder.decode(User.self, from: GitHubTarget.user(username).sampleData)
  }

  func fetchUsers(since: Int?) -> Single<UserList> {
    return Single<UserList>.create { single in
      single(.success(self.userList))
      return Disposables.create()
    }
  }

  func fetchUser(_ username: String) -> Single<User?> {
    return Single<User?>.create { single in
      single(.success(self.user(username)))
      return Disposables.create()
    }
  }
}
