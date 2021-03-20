import Foundation


protocol ViewModelType: class {
  associatedtype Input
  associatedtype Output

  var input: Input { get }
  var output: Output { get }
}


class ViewModel<T, K>: ViewModelType {
  let input: T
  let output: K

  init(input: T, output: K) {
    self.input = input
    self.output = output
  }
}
