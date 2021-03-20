import Foundation
import RxSwift
import RxCocoa


protocol UserViewModelInputType {
  var username: PublishSubject<String> { get }
}

protocol UserViewModelOutputType {
  var user: BehaviorRelay<User?> { get }
}

typealias UserViewModelType = ViewModel<UserViewModelInputType, UserViewModelOutputType>
