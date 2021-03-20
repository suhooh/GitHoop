import UIKit
import RxSwift
import RxOptional
import Kingfisher


final class UserViewController: RxViewController<UserViewModelType> {

  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var loginLabel: UILabel!
  @IBOutlet weak var bioLabel: UILabel!
  @IBOutlet weak var companyLabel: UILabel!
  @IBOutlet weak var locationLabel: UILabel!
  @IBOutlet weak var emailLabel: UILabel!
  @IBOutlet weak var blogLabel: UILabel!
  @IBOutlet weak var repositoriesLabel: UILabel!
  @IBOutlet weak var followersLabel: UILabel!
  @IBOutlet weak var followingLabel: UILabel!
  @IBOutlet weak var memberSinceLabel: UILabel!

  override func bind() {
    super.bind()

    let user = viewModel.output.user.filterNil().share()

    [
      user.map { $0.name == nil ? $0.login : $0.name }.bind(to: navigationItem.rx.title),
      user.map { URL(string: $0.avatarUrl) }.bind { self.avatarImageView.kf.setImage(with: $0) },
      user.map { $0.name }.bind(to: nameLabel.rx.text),
      user.map { $0.login }.bind(to: loginLabel.rx.text),
      user.map { $0.bio }.bind(to: bioLabel.rx.text),
      user.map { $0.company }.bind(to: companyLabel.rx.text),
      user.map { $0.location }.bind(to: locationLabel.rx.text),
      user.map { $0.email }.bind(to: emailLabel.rx.text),
      user.map { $0.blog }.bind(to: blogLabel.rx.text),
      user.map { $0.publicRepos }.filterNil().map { "  \($0)  " }.bind(to: repositoriesLabel.rx.text),
      user.map { $0.followers }.filterNil().map { "  \($0)  " }.bind(to: followersLabel.rx.text),
      user.map { $0.following }.filterNil().map { "  \($0)  " }.bind(to: followingLabel.rx.text),
      user.map { $0.createdAt }.filterNil().map { DateFormatter.MMMdYYYY(from: $0) }.map { "  \($0)  " }.bind(to: memberSinceLabel.rx.text)
    ]
    .forEach { $0.disposed(by: bag) }
  }
}
