import ArgumentParser
import Foundation
import TodoAuth

struct Auth: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "auth",
    subcommands: [Status.self, LogIn.self, LogOut.self],
  )

  struct Status: AsyncParsableCommand {
    static let _commandName = "status"

    @Flag
    var verbose: Bool = false

    @MainActor
    func run() async throws {
      try await runDefault {
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
  }

  struct LogIn: AsyncParsableCommand {
    static let _commandName = "login"

    @Flag
    var verbose: Bool = false

    @MainActor
    func run() async throws {
      try await runDefault {
        try configure()
        let auth = TodoAuth()

        log(.checkingStatus)
        let status = try await auth.getCurrentStatus()

        switch status {
        case .authenticated(let profile):
          log(.loginSkipping(profile))

        case .unauthenticated:
          log(.loginInProgress)
          let profile = try await auth.authenticate { verificationStatus in
            switch verificationStatus {
            case .pending(let message):
              log(.loginVerificationPending)
              log(message)
            case .complete:
              log(.loginVerificationComplete)
            }
          }
          log(.loginSuccess(profile))
        }
      }
    }
  }

  struct LogOut: AsyncParsableCommand {
    static let _commandName = "logout"

    @Flag
    var verbose: Bool = false

    @MainActor
    func run() async throws {
      try await runDefault {
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
}
