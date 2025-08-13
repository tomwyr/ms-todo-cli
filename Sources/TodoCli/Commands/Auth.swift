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
      let status = try await TodoAuth().getCurrentStatus()

      print("Checking authentication status...")
      switch status {
      case .unauthenticated:
        print("Not logged in")
      case .authenticated(let userProfile):
        print("Logged in as \(userProfile.displayName)")
      }
    }
  }

  struct LogIn: AsyncParsableCommand {
    static let _commandName = "login"

    @MainActor
    func run() async throws {
      try configure()
      let todoAuth = TodoAuth()

      print("Checking authentication status...")
      let status = try await todoAuth.getCurrentStatus()

      switch status {
      case .unauthenticated:
        print("Logging in...")
        let userProfile = try await todoAuth.authenticate()
        print("Successfully logged in as \(userProfile.displayName)")
      case .authenticated(let userProfile):
        print("Already logged in as \(userProfile.displayName)")
      }
    }
  }

  struct LogOut: AsyncParsableCommand {
    static let _commandName = "logout"

    @MainActor
    func run() async throws {
      try configure()
      let todoAuth = TodoAuth()

      print("Checking authentication status...")
      let status = try await todoAuth.getCurrentStatus()

      switch status {
      case .unauthenticated:
        print("Currently not logged in")
      case .authenticated:
        print("Logging out...")
        try await todoAuth.invalidateSession()
        print("Successfully logged out")
      }
    }
  }
}
