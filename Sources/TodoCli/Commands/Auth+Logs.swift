import TodoAuth

protocol AuthLogs {
  func log(_ authLog: AuthLog)
}

extension AuthLogs {
  func log(_ authLog: AuthLog) {
    print(authLog.message)
  }
}

extension Auth.Status: AuthLogs {}
extension Auth.LogIn: AuthLogs {}
extension Auth.LogOut: AuthLogs {}

enum AuthLog {
  case checkingStatus
  case statusLoggedOut
  case statusLoggedIn(UserProfile)

  case loginSkipping(UserProfile)
  case loginInProgress
  case loginSuccess(UserProfile)

  case logoutSkipping
  case logoutInProgress
  case logoutSuccess

  var message: String {
    switch self {
    case .checkingStatus: "Checking authentication status..."
    case .statusLoggedOut: "Not logged in"
    case .statusLoggedIn(let profile): "Logged in as \(profile.displayName)"
    case .loginSkipping(let profile): "Already logged in as \(profile.displayName)"
    case .loginInProgress: "Logging in..."
    case .loginSuccess(let profile): "Successfully logged in as \(profile.displayName)"
    case .logoutSkipping: "Currently not logged in"
    case .logoutInProgress: "Logging out..."
    case .logoutSuccess: "Successfully logged out"
    }
  }
}
