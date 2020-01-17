import UIKit
import RxSwift
import RxCocoa
import Kingfisher


final class UserCollectionCell: RxCollectionViewCell<User> {

  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var usernameLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
    setAppearance()
  }

  private func setAppearance() {
    contentView.layer.borderColor = #colorLiteral(red: 0.9294795394, green: 0.9294357896, blue: 0.9334862828, alpha: 1)
    contentView.layer.borderWidth = 1.5
    contentView.layer.cornerRadius = 5.0
  }

  override func bind() {
    super.bind()

    data
      .map { $0.login }
      .bind(to: usernameLabel.rx.text)
      .disposed(by: bag)

    data
      .map { URL(string: $0.avatarUrl) }
      .bind { [unowned self] url in
        self.avatarImageView.kf.setImage(with: url)
      }
      .disposed(by: bag)
  }
}
