import Foundation
import SwiftDotenv

struct EnvVars {
  private static var initialized = false

  static func load() throws {
    if initialized { return }

    let filePath = ".env"
    guard let filePath = Bundle.module.path(forResource: filePath, ofType: nil) else {
      throw EnvVarsError.fileMissing(name: filePath)
    }
    try Dotenv.configure(atPath: filePath)

    initialized = true
  }

  static func get(_ key: String) throws -> String {
    guard initialized else {
      throw EnvVarsError.notInitialized
    }
    guard let value = Dotenv[key]?.stringValue else {
      throw EnvVarsError.valueMissing(key: key)
    }
    return value
  }
}

enum EnvVarsError: Error, CustomStringConvertible {
  case notInitialized
  case fileMissing(name: String)
  case valueMissing(key: String)

  var description: String {
    switch self {
    case .notInitialized:
      "Environment variables are not initialized"
    case .fileMissing(let name):
      "Environment file '\(name)' is missing"
    case .valueMissing(let key):
      "Environment variable '\(key)' is missing"
    }
  }
}
