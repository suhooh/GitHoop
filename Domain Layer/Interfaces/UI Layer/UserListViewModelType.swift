import Foundation
import RxSwift
import RxCocoa


protocol UserListViewModelInputType {
  var requestNextUserList: PublishSubject<Void> { get }
  var selectedUser: PublishSubject<String> { get }
  var viewType: PublishSubject<UserListType> { get }
}

protocol UserListViewModelOutputType {
  var users: BehaviorRelay<[User]> { get }
  var nextIndex: BehaviorRelay<Int?> { get }
}

typealias UserListViewModelType = ViewModel<UserListViewModelInputType, UserListViewModelOutputType>
