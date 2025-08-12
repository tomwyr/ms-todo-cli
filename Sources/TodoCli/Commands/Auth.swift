import ArgumentParser
import TodoAuth

struct Auth: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "auth",
    subcommands: [LogIn.self, LogOut.self, Status.self],
  )

  struct LogIn: AsyncParsableCommand {
    static let _commandName = "login"

    @MainActor
    func run() async throws {
      try configure()
      try await TodoAuth().authenticate()
    }
  }

  struct LogOut: AsyncParsableCommand {
    static let _commandName = "logout"

    @MainActor
    func run() async throws {
      try configure()
      try await TodoAuth().invalidateSession()
    }
  }

  struct Status: AsyncParsableCommand {
    static let _commandName = "status"

    @MainActor
    func run() async throws {
      try configure()
      let authenticated = try await TodoAuth().isAuthenticated()
      print(authenticated)
    }
  }
}
