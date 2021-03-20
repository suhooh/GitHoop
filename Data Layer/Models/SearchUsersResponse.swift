import Foundation


struct SearchUserResponse: Decodable {
  let totalCount: Int
  let incompleteResults: Bool
  let items: [UserEntity]
}
