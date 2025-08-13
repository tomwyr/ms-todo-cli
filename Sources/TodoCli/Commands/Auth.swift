import ArgumentParser
import TodoAuth

struct Auth: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "auth",
    subcommands: [Status.self, LogIn.self, LogOut.self],
  )

  struct Status: AsyncParsableCommand {
    static let _commandName = "status"

    @MainActor
    func run() async throws {
      try configure()
      let auth = TodoAuth()

      log(.checkingStatus)
      let status = try await auth.getCurrentStatus()

      switch status {
      case .unauthenticated:
        log(.statusLoggedOut)
      case .authenticated(let profile):
        log(.statusLoggedIn(profile))
      }
    }
  }

  struct LogIn: AsyncParsableCommand {
    static let _commandName = "login"

    @MainActor
    func run() async throws {
      try configure()
      let auth = TodoAuth()

      log(.checkingStatus)
      let status = try await auth.getCurrentStatus()

      switch status {
      case .authenticated(let profile):
        log(.loginSkipping(profile))
      case .unauthenticated:
        log(.loginInProgress)
        let profile = try await auth.authenticate()
        log(.loginSuccess(profile))
      }
    }
  }

  struct LogOut: AsyncParsableCommand {
    static let _commandName = "logout"

    @MainActor
    func run() async throws {
      try configure()
      let auth = TodoAuth()

      log(.checkingStatus)
      let status = try await auth.getCurrentStatus()

      switch status {
      case .unauthenticated:
        log(.logoutSkipping)
      case .authenticated:
        log(.logoutInProgress)
        try await auth.invalidateSession()
        log(.logoutSuccess)
      }
    }
  }
}
