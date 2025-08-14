import Foundation

protocol TodoCommand {
  var verbose: Bool { get }

  func runDefault(body: () async throws -> Void) async throws
}

extension TodoCommand {
  func runDefault(body: () async throws -> Void) async throws {
    do {
      try await body()
    } catch {
      log(.errorOccurred(verbose))
      log(error)
      if verbose {
        log(Thread.callStackSymbols.prefix(10).joined(separator: "\n"))
      }
    }
  }

}

extension TodoCommand {
  func log(_ log: TodoLog) {
    print(log.message)
  }

  func log(_ message: String) {
    print(message)
  }

  func log(_ error: any Error) {
    print(error)
  }
}
