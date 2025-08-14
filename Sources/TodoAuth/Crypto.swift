import Crypto
import Foundation

protocol ValueCrypto {
  func encrypt<T: Codable>(value: T) throws -> String
  func decrypt<T: Codable>(value: String) throws -> T
}

struct JsonCrypto: ValueCrypto {
  init(key: String) {
    let keyData = SHA256.hash(data: Data(key.utf8))
    self.key = SymmetricKey(data: keyData)
  }

  let key: SymmetricKey

  func encrypt<T: Codable>(value: T) throws -> String {
    let data = try JSONEncoder().encode(value)
    let box = try AES.GCM.seal(data, using: key)
    guard let combined = box.combined else {
      throw JsonCryptoError.invalidEncryptData
    }
    return combined.base64EncodedString()
  }

  func decrypt<T: Codable>(value: String) throws -> T {
    guard let combined = Data(base64Encoded: value) else {
      throw JsonCryptoError.invalidDecryptData
    }
    let box = try AES.GCM.SealedBox(combined: combined)
    let data = try AES.GCM.open(box, using: key)
    return try JSONDecoder().decode(T.self, from: data)
  }
}

enum JsonCryptoError: Error, CustomStringConvertible {
  case invalidEncryptData
  case invalidDecryptData

  var description: String {
    switch self {
    case .invalidEncryptData:
      "Invalid data provided for encryption"
    case .invalidDecryptData:
      "Invalid data provided for decryption"
    }
  }
}
