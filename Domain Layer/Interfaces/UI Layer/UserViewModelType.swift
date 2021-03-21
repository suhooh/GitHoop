import Foundation
import RxSwift
import RxCocoa


protocol UserViewModelInputType {
  var username: PublishSubject<String> { get }
}

protocol UserViewModelOutputType {
  var user: PublishSubject<User> { get }
  var alertMessage: PublishSubject<String> { get }
}

typealias UserViewModelType = ViewModel<UserViewModelInputType, UserViewModelOutputType>
