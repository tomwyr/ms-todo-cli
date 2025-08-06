import Combine
import Observation

public class AuthService {
  public init(authClient: AuthClient, authStorage: AuthStorage) {
    self.authClient = authClient
    self.authStorage = authStorage
  }

  let authClient: AuthClient
  let authStorage: AuthStorage

  @Published private(set) var state: AuthState = .unknown

  func initialize() async throws {
    guard case .unknown = state else { return }

    let cachedSession = try await authStorage.loadSession()
    state =
      if let cachedSession {
        .authenticated(cachedSession)
      } else {
        .unauthenticated
      }
  }

  func authenticate() async throws {
    guard case .unauthenticated = state else { return }

    let authorization = try await authClient.authorizeDevice()
    let pollTask = Task.detached {
      try await self.pollToken(authorization)
    }
    state = .pending(authorization, pollTask)

    let session = try await pollTask.value
    state = .authenticated(session)
  }

  func invalidateSession() async throws {
    switch state {
    case .authenticated: break
    case .pending(_, let pollTask):
      pollTask.cancel()
    default: return
    }

    try await authStorage.clearSession()
    state = .unauthenticated
  }

  private nonisolated func pollToken(
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
}

enum AuthState {
  case unknown
  case unauthenticated
  case pending(DeviceAuthorization, Task<UserSession, Error>)
  case authenticated(UserSession)
}
