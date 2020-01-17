import UIKit


protocol StoryboardInstantiable: class {
  static var storyboardName: String { get }
  static var storyboardIdentifier: String { get }
  static func initFromStoryboard() -> Self
}

//extension StoryboardInstantiable where Self: UIViewController {
extension UIViewController: StoryboardInstantiable {
  static var storyboardName: String {
    return "\(self)"
  }

  static var storyboardIdentifier: String {
    return "\(self)"
  }

  static func initFromStoryboard() -> Self {
    return UIStoryboard(name: storyboardName, bundle: nil).instantiateViewController(withIdentifier: storyboardIdentifier) as! Self
  }
}
