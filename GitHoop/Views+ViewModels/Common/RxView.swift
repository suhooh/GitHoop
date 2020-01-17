import UIKit
import RxSwift
import RxCocoa


protocol RxView: class {
  associatedtype T
  var bag: DisposeBag { get }
  var viewModel: T! { get set }
  func bind()
}

class RxViewController<T>: UIViewController, RxView {
  internal var bag = DisposeBag()
  internal var viewModel: T! {
    didSet { isBindReady.onNext(true) }
  }
  private let isBindReady = BehaviorSubject<Bool>(value: false)
  private var binder: Disposable?

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    // Bind once both view and view model are ready.
    guard binder == nil else { return }
    binder = isBindReady
      .filter { $0 }
      .map { _ in }
      .bind(onNext: bind)
    binder?.disposed(by: bag)
  }

  internal func bind() {
    binder?.dispose()
  }
}
