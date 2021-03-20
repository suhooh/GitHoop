import Foundation
import RxSwift
import RxCocoa


protocol UserListViewModelInputType {
  var requestNextPage: PublishSubject<Void> { get }
  var searchUsersText: PublishSubject<String> { get }
  var selectedUser: PublishSubject<String> { get }
  var viewType: PublishSubject<UserListType> { get }
}

protocol UserListViewModelOutputType {
  var users: BehaviorRelay<[User]> { get }
  var currentPage: BehaviorRelay<Int> { get }
}

typealias UserListViewModelType = ViewModel<UserListViewModelInputType, UserListViewModelOutputType>
