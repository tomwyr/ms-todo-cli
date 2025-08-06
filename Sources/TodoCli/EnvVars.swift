import Foundation
import SwiftDotenv

typealias GetEnvVar = (String) throws -> String

struct EnvVars {
  static func load() throws -> GetEnvVar {
    let filePath = ".env"
    guard let filePath = Bundle.module.path(forResource: filePath, ofType: nil) else {
      throw EnvVarsError.fileMissing(name: filePath)
    }

    try Dotenv.configure(atPath: filePath)

    return { (key: String) throws in
      guard let value = Dotenv[key] else {
        throw EnvVarsError.valueMissing(key: key)
      }
      return value.stringValue
    }
  }
}

enum EnvVarsError: Error {
  case fileMissing(name: String)
  case valueMissing(key: String)
}
