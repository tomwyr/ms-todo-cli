import Combine
import Observation

public class TodoAuth {
  init(authClient: AuthClient, authStorage: AuthStorage) {
    self.authClient = authClient
    self.authStorage = authStorage
  }

  let authClient: AuthClient
  let authStorage: AuthStorage

  private var state: AuthState = .unknown

  public func authenticate() async throws {
    try initialize()

    guard case .unauthenticated = state else { return }

    let authorization = try await authClient.authorizeDevice()

    let pollTask = Task.detached {
      try await self.pollToken(authorization)
    }
    state = .pending(authorization, pollTask)

    let session = try await pollTask.value
    try authStorage.saveSession(session)
    state = .authenticated(session)
  }

  public func invalidateSession() async throws {
    try initialize()

    switch state {
    case .authenticated: break
    case .pending(_, let pollTask):
      pollTask.cancel()
    default: return
    }

    try authStorage.clearSession()
    state = .unauthenticated
  }

  public func isAuthenticated() async throws -> Bool {
    try initialize()

    return switch state {
    case .unknown: failUninitialized()
    case .pending, .unauthenticated: false
    case .authenticated: true
    }
  }

  private func pollToken(
    _ authorization: DeviceAuthorization,
  ) async throws -> UserSession {
    while authorization.expiresIn > 0 {
      try await Task.sleep(for: .seconds(authorization.interval))
      try Task.checkCancellation()
      let session = try await authClient.authenticate(deviceCode: authorization.deviceCode)
      return session
    }
    fatalError("TODO")
  }

  private func initialize() throws {
    guard case .unknown = state else { return }

    let cachedSession = try authStorage.loadSession()
    state =
      if let cachedSession {
        .authenticated(cachedSession)
      } else {
        .unauthenticated
      }
  }

  private func failUninitialized() -> Never {
    fatalError("TodoAuth state not initialized.")
  }
}

enum AuthState {
  case unknown
  case unauthenticated
  case pending(DeviceAuthorization, Task<UserSession, Error>)
  case authenticated(UserSession)
}
