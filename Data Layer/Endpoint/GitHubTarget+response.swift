import Foundation


extension GitHubTarget {
  internal struct SampleResponse {
    static let invalidUsername = "INVALID_USERNAME"
    static var searchUsers: String { """
      {"total_count":3,"incomplete_results":false,"items":[{"login":"suho","id":19943832,"node_id":"MDQ6VXNlcjE5OTQzODMy","avatar_url":"https://avatars.githubusercontent.com/u/19943832?v=4","gravatar_id":"","url":"https://api.github.com/users/suho","html_url":"https://github.com/suho","followers_url":"https://api.github.com/users/suho/followers","following_url":"https://api.github.com/users/suho/following{/other_user}","gists_url":"https://api.github.com/users/suho/gists{/gist_id}","starred_url":"https://api.github.com/users/suho/starred{/owner}{/repo}","subscriptions_url":"https://api.github.com/users/suho/subscriptions","organizations_url":"https://api.github.com/users/suho/orgs","repos_url":"https://api.github.com/users/suho/repos","events_url":"https://api.github.com/users/suho/events{/privacy}","received_events_url":"https://api.github.com/users/suho/received_events","type":"User","site_admin":false,"score":1.0},{"login":"suhothayan","id":3785208,"node_id":"MDQ6VXNlcjM3ODUyMDg=","avatar_url":"https://avatars.githubusercontent.com/u/3785208?v=4","gravatar_id":"","url":"https://api.github.com/users/suhothayan","html_url":"https://github.com/suhothayan","followers_url":"https://api.github.com/users/suhothayan/followers","following_url":"https://api.github.com/users/suhothayan/following{/other_user}","gists_url":"https://api.github.com/users/suhothayan/gists{/gist_id}","starred_url":"https://api.github.com/users/suhothayan/starred{/owner}{/repo}","subscriptions_url":"https://api.github.com/users/suhothayan/subscriptions","organizations_url":"https://api.github.com/users/suhothayan/orgs","repos_url":"https://api.github.com/users/suhothayan/repos","events_url":"https://api.github.com/users/suhothayan/events{/privacy}","received_events_url":"https://api.github.com/users/suhothayan/received_events","type":"User","site_admin":false,"score":1.0}]}
      """
    }
    static func user(username: String) -> String { """
      {"login":"\(username)","id":1,"node_id":"MDQ6VXNlcjE=","avatar_url":"https://avatars0.githubusercontent.com/u/1?v=4","gravatar_id":"","url":"https://api.github.com/users/mojombo","html_url":"https://github.com/mojombo","followers_url":"https://api.github.com/users/mojombo/followers","following_url":"https://api.github.com/users/mojombo/following{/other_user}","gists_url":"https://api.github.com/users/mojombo/gists{/gist_id}","starred_url":"https://api.github.com/users/mojombo/starred{/owner}{/repo}","subscriptions_url":"https://api.github.com/users/mojombo/subscriptions","organizations_url":"https://api.github.com/users/mojombo/orgs","repos_url":"https://api.github.com/users/mojombo/repos","events_url":"https://api.github.com/users/mojombo/events{/privacy}","received_events_url":"https://api.github.com/users/mojombo/received_events","type":"User","site_admin":false,"name":"Tom Preston-Werner","company":null,"blog":"http://tom.preston-werner.com","location":"San Francisco","email":null,"hireable":null,"bio":null,"public_repos":61,"public_gists":62,"followers":21751,"following":11,"created_at":"2007-10-20T05:24:19Z","updated_at":"2020-01-13T14:15:49Z"}
      """
    }
    static var userNotFound: String { """
      {"message":"Not Found","documentation_url":"https://docs.github.com/rest/reference/users#get-a-user"}
      """
    }
    static var rateLimitExceeded: String { """
      {"message":"API rate limit exceeded for 95.90.247.234. (But here's the good news: Authenticated requests get a higher rate limit. Check out the documentation for more details.)","documentation_url":"https://docs.github.com/rest/overview/resources-in-the-rest-api#rate-limiting"}
      """
    }
  }
}
