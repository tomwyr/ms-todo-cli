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
    if let session = try authStorage.loadSession() {
      return session.profile
    }

    let authorization = try await authClient.authorizeDevice()
    onVerificationStatus(.pending(authorization.message))

    let pollTask = Task.detached {
      try await self.pollToken(authorization)
    }
    let credentials = try await pollTask.value
    onVerificationStatus(.complete)

    let session = try UserSession(credentials: credentials)
    try authStorage.saveSession(session)
    return session.profile
  }

  public func invalidateSession() async throws {
    try authStorage.clearSession()
  }

  public func getCurrentStatus() async throws -> AuthStatus {
    if let session = try authStorage.loadSession() {
      .authenticated(session.profile)
    } else {
      .unauthenticated
    }
  }

  public func getAccessToken() async throws -> String {
    guard let session = try authStorage.loadSession() else {
      throw TodoAuthError.sessionMissing
    }

    if session.isValid(refreshWindow: 30) {
      return session.credentials.accessToken
    }

    do {
      let refreshedSession = try await refreshSession(session)
      return refreshedSession.credentials.accessToken
    } catch {
      throw TodoAuthError.sessionRefreshFailed(cause: error)
    }
  }

  private func refreshSession(_ currentSession: UserSession) async throws -> UserSession {
    let refreshToken = currentSession.credentials.refreshToken
    let credentials = try await authClient.refreshCredentials(refreshToken: refreshToken)
    let refreshedSession = try UserSession(credentials: credentials)
    try authStorage.saveSession(refreshedSession)
    return refreshedSession
  }

  private func pollToken(_ authorization: DeviceAuthorization) async throws -> AuthCredentials {
    while true {
      try await Task.sleep(for: .seconds(authorization.interval))
      try Task.checkCancellation()
      do {
        return try await authClient.authenticate(deviceCode: authorization.deviceCode)
      } catch let error as OAuthError where error.isAuthorizationPending {
        continue
      }
    }
  }
}

public enum TodoAuthError: Error, CustomStringConvertible {
  case sessionMissing
  case sessionRefreshFailed(cause: any Error)

  public var description: String {
    switch self {
    case .sessionMissing:
      ""
    case .sessionRefreshFailed:
      ""
    }
  }

}
