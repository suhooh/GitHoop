import Foundation


struct UserEntity: Decodable {
  // Basic info from 'GET /users', 'Get /search/users'
  let login: String
  let id: Int
  let nodeId: String
  let avatarUrl: String
  let gravatarId: String
  let url: String
  let htmlUrl: String
  let followersUrl: String
  let followingUrl: String
  let gistsUrl: String
  let starredUrl: String
  let subscriptionsUrl: String
  let organizationsUrl: String
  let reposUrl: String
  let eventsUrl: String
  let receivedEventsUrl: String
  let type: String
  let siteAdmin: Bool
  let score: Double?

  // Additional info from 'GET /users/:username'
  let name: String?
  let company: String?
  let blog: String?
  let location: String?
  let email: String?
  let hireable: String?
  let bio: String?
  let publicRepos: Int?
  let publicGists: Int?
  let followers: Int?
  let following: Int?
  let createdAt: Date?
  let updatedAt: Date?
}

extension UserEntity {
  var asUser: User {
    User(
      login: login,
      id: id,
      avatarUrl: avatarUrl,
      name: name,
      company: company,
      blog: blog,
      location: location,
      email: email,
      bio: bio,
      publicRepos: publicRepos,
      followers: followers,
      following: following,
      createdAt: createdAt
    )
  }
}
