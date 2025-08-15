import Foundation

public enum AuthVerificationStatus {
  case pending(String)
  case complete
}

public enum AuthStatus {
  case authenticated(UserProfile)
  case unauthenticated
}

public struct UserSession: Codable {
  init(credentials: AuthCredentials) throws {
    self.credentials = credentials
    profile = try credentials.decodeUser()
    expiresAt = Date.now.advanced(by: .init(credentials.expiresIn))
  }

  let credentials: AuthCredentials
  let profile: UserProfile
  let expiresAt: Date

  func isValid(refreshWindow: TimeInterval = 0) -> Bool {
    expiresAt >= Date.now + refreshWindow
  }
}

public struct UserProfile: Codable {
  public let name: String
  public let preferredUsername: String?

  public var displayName: String {
    preferredUsername ?? name
  }
}

extension AuthCredentials {
  func decodeUser() throws -> UserProfile {
    try parseJwtPayload(token: idToken, keyStrategy: .convertFromSnakeCase)
  }
}
