import UIKit
import RxSwift


final class UserCollectionViewController: RxViewController<UserListViewModelType> {

  @IBOutlet weak var collectionView: UICollectionView!
  private var avatarSize: CGSize!
  private lazy var viewTypeButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setImage(UIImage(named: "view_list"), for: .normal)
    return button
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()

    setNavigationBarLogo()
    setViewTypeBarButton()
    setCollectionViewFlowLayout()
  }

  // MARK: - Binding

  override func bind() {
    super.bind()

    viewModel.output.users
      .bind(to: collectionView.rx.items(cellIdentifier: UserCollectionCell.reuseId, cellType: UserCollectionCell.self)) { (row, user, cell) in
        cell.avatarImageView.layer.cornerRadius = self.avatarSize.width / 2
        cell.data.accept(user)
      }
      .disposed(by: bag)

    collectionView.rx.modelSelected(User.self)
      .map { $0.login }
      .bind(to: viewModel.input.selectedUser)
      .disposed(by: bag)

    collectionView.rx.prefetchItems.map { indexPaths in indexPaths.map { $0.item } }
      .withLatestFrom(viewModel.output.users.map { $0.count-1 }) { (items: $0, lastIndex: $1) }
      .filter { event in
        return event.items.contains(where: { $0 >= (event.lastIndex) })
      }
      .map { _ in }
      .bind(to: viewModel.input.requestNextPage)
      .disposed(by: bag)

    viewTypeButton.rx.tap
      .map { UserListType.list }
      .bind(to: viewModel.input.viewType)
      .disposed(by: bag)
  }


  // MARK: - UI
  
  private func setNavigationBarLogo() {
    let frame = CGRect(x: 0, y: 0, width: 200, height: 20)
    let logoContainer = UIView(frame: frame)
    let logo = UIImageView(frame: frame)
    logo.contentMode = .scaleAspectFit
    logo.image = UIImage(named: "github-logo")
    logoContainer.addSubview(logo)
    navigationItem.titleView = logoContainer
  }

  private func setViewTypeBarButton(){
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: viewTypeButton)
  }

  private func setCollectionViewFlowLayout() {
    let itemsInARow: Int = 3
    let itemSpacing: CGFloat = 26.0 / CGFloat(itemsInARow)
    let itemWidth = (UIScreen.main.bounds.width - (itemSpacing * CGFloat(itemsInARow + 1))) / CGFloat(itemsInARow)
    let itemSize = CGSize(width: itemWidth, height: itemWidth + 33)
    avatarSize = CGSize(width: itemWidth - 16, height: itemWidth - 16)

    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.sectionInset = UIEdgeInsets(top: itemSpacing, left: itemSpacing, bottom: itemSpacing, right: itemSpacing)
    flowLayout.minimumInteritemSpacing = itemSpacing
    flowLayout.minimumLineSpacing = itemSpacing
    flowLayout.itemSize = itemSize
    collectionView.collectionViewLayout = flowLayout
  }
}
