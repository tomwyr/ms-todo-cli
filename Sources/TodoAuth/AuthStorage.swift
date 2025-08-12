import Foundation

struct AuthStorage {
  let valueCrypto: ValueCrypto
  let filePath: String

  private let fm = FileManager.default

  func saveSession(_ userSession: UserSession) throws {
    let encrpted = try valueCrypto.encrypt(value: userSession)
    if !fm.fileExists(atPath: filePath) {
      fm.createFile(atPath: filePath, contents: nil)
    }
    try encrpted.write(toFile: filePath, atomically: true, encoding: .utf8)
  }

  func loadSession() throws -> UserSession? {
    guard fm.fileExists(atPath: filePath) else {
      return nil
    }
    let data = try String(contentsOfFile: filePath, encoding: .utf8)
    return try valueCrypto.decrypt(value: data)
  }

  func clearSession() throws {
    try fm.removeItem(atPath: filePath)
  }
}
