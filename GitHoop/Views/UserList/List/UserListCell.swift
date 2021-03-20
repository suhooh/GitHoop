import UIKit
import RxSwift
import RxCocoa
import Kingfisher


final class UserListCell: RxTableViewCell<User> {

  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var usernameLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
    setAppearance()
  }

  private func setAppearance() {
    let margin: CGFloat = 9.0
    let outline = CALayer()
    outline.frame = CGRect(x: margin, y: margin/2, width: UIScreen.main.bounds.width-(margin*2), height: frame.height-margin)
    outline.borderColor = #colorLiteral(red: 0.9294795394, green: 0.9294357896, blue: 0.9334862828, alpha: 1)
    outline.borderWidth = 1.5
    outline.cornerRadius = 5.0
    contentView.layer.addSublayer(outline)
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
