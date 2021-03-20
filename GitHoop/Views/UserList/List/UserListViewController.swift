import UIKit
import RxSwift


final class UserListViewController: RxViewController<UserListViewModelType> {

  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var tableView: UITableView!

  private lazy var viewTypeButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setImage(UIImage(named: "view_grid"), for: .normal)
    return button
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    setNavigationBarLogo()
    setViewTypeBarButton()
    tableView.keyboardDismissMode = .onDrag
  }

  // MARK: - Binding

  override func bind() {
    super.bind()

    searchBar.rx.text.orEmpty
      .distinctUntilChanged()
      .debounce(0.5, scheduler: MainScheduler.instance)
      .bind(to: viewModel.input.searchUsersText)
      .disposed(by: bag)

    viewModel.output.users
      .bind(to: tableView.rx.items(cellIdentifier: UserListCell.reuseId, cellType: UserListCell.self)) { (row, user, cell) in
          cell.data.accept(user)
      }
      .disposed(by: bag)

    tableView.rx.modelSelected(User.self)
      .do(onNext: { [unowned self] indexPath in
        guard let indexPath = self.tableView.indexPathForSelectedRow else { return }
        self.tableView.deselectRow(at: indexPath, animated: true)
      })
      .map { $0.login }
      .bind(to: viewModel.input.selectedUser)
      .disposed(by: bag)

    tableView.rx.prefetchRows.map { indexPaths in indexPaths.map { $0.row } }
      .withLatestFrom(viewModel.output.users.map { $0.count-1 }) { (rows: $0, lastIndex: $1) }
      .filter { event in
        return event.rows.contains(where: { $0 >= (event.lastIndex) })
      }
      .map { _ in }
      .bind(to: viewModel.input.requestNextPage)
      .disposed(by: bag)

    viewTypeButton.rx.tap
      .map { UserListType.grid }
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
}
