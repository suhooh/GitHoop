import UIKit
import RxSwift
import RxCocoa


protocol RxViewCell {
  associatedtype T
  // NOTE: A single PublishRelay is enough instead of a view model for now.
  var data: PublishRelay<T> { get set }
  var bag: DisposeBag { get }
  func bind()
}

class RxTableViewCell<T>: UITableViewCell, RxViewCell {
  internal var data = PublishRelay<T>()
  internal var bag = DisposeBag()

  override func awakeFromNib() {
    super.awakeFromNib()
    bind()
  }

  internal func bind() {}
}

class RxCollectionViewCell<T>: UICollectionViewCell, RxViewCell {
  internal var data = PublishRelay<T>()
  internal var bag = DisposeBag()

  override func awakeFromNib() {
    super.awakeFromNib()
    bind()
  }

  internal func bind() {}
}
