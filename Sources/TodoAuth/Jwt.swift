import Foundation
import JWTKit

func parseJwtPayload<T: Codable>(
  token: String, into: T.Type = T.self,
  keyStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
) throws -> T {
  let segments = token.split(separator: ".")
  guard segments.count == 3 else {
    throw JwtPayloadError.invalidToken
  }
  let payloadSegment = String(segments[1])

  let base64 = base64urlToBase64(base64url: payloadSegment)
  guard let data = Data(base64Encoded: base64) else {
    throw JwtPayloadError.invalidData
  }

  let decoder = JSONDecoder()
  decoder.keyDecodingStrategy = keyStrategy
  return try decoder.decode(T.self, from: data)
}

enum JwtPayloadError: Error {
  case invalidToken
  case invalidData
}

private func base64urlToBase64(base64url: String) -> String {
  var base64 =
    base64url
    .replacingOccurrences(of: "-", with: "+")
    .replacingOccurrences(of: "_", with: "/")
  if base64.count % 4 != 0 {
    base64.append(String(repeating: "=", count: 4 - base64.count % 4))
  }
  return base64
}
