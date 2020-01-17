import Foundation


protocol RxViewModel: class {
  associatedtype Input
  associatedtype Output

  var input: Input { get }
  var output: Output { get }
}
