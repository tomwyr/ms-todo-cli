public class TodoAuth {
  init(authClient: AuthApiClient, authStorage: AuthStorage) {
    self.authClient = authClient
    self.authStorage = authStorage
  }

  let authClient: AuthApiClient
  let authStorage: AuthStorage

  public func authenticate(
    onVerificationStatus: sending @MainActor (AuthVerificationStatus) -> Void,
  ) async throws -> UserProfile {
    if let credentials = try authStorage.loadSession() {
      return try credentials.decodeUser()
    }

    let authorization = try await authClient.authorizeDevice()
    onVerificationStatus(.pending(authorization.message))

    let pollTask = Task.detached {
      try await self.pollToken(authorization)
    }
    let credentials = try await pollTask.value
    onVerificationStatus(.complete)

    try authStorage.saveSession(credentials)
    return try credentials.decodeUser()
  }

  public func invalidateSession() async throws {
    try authStorage.clearSession()
  }

  public func getCurrentStatus() async throws -> AuthStatus {
    let credentials = try authStorage.loadSession()
    return if let credentials {
      .authenticated(try credentials.decodeUser())
    } else {
      .unauthenticated
    }
  }

  private func pollToken(_ authorization: DeviceAuthorization) async throws -> AuthCredentials {
    while true {
      try await Task.sleep(for: .seconds(authorization.interval))
      try Task.checkCancellation()
      do {
        return try await authClient.authenticate(deviceCode: authorization.deviceCode)
      } catch let error as AuthApiError where error.isAuthorizationPending {
        continue
      }
    }
  }

  private func failUninitialized() -> Never {
    fatalError("TodoAuth state not initialized.")
  }
}

extension AuthCredentials {
  func decodeUser() throws -> UserProfile {
    try parseJwtPayload(token: idToken, keyStrategy: .convertFromSnakeCase)
  }
}

public enum AuthVerificationStatus {
  case pending(String)
  case complete
}

public enum AuthStatus {
  case authenticated(UserProfile)
  case unauthenticated
}

public struct UserProfile: Codable {
  public let name: String
  public let preferredUsername: String?

  public var displayName: String {
    preferredUsername ?? name
  }
}
