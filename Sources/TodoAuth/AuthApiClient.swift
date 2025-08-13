import Foundation
import TodoCommon

class AuthApiClient {
  init(clientId: String, httpClient: HttpClient) {
    self.clientId = clientId
    self.httpClient = httpClient
  }

  let clientId: String
  let httpClient: HttpClient

  func authorizeDevice() async throws -> DeviceAuthorization {
    let result = try await httpClient.request(
      url: "/devicecode",
      method: "POST",
      headers: ["Content-Type": "application/x-www-form-urlencoded"],
      body: [
        "client_id": clientId,
        "scope": "user.read%20openid%20profile%20offline_access",
      ],
    )

    return try parseResult(result)
  }

  func authenticate(deviceCode: String) async throws -> AuthCredentials {
    let result = try await httpClient.request(
      url: "/token",
      method: "POST",
      headers: ["Content-Type": "application/x-www-form-urlencoded"],
      body: [
        "grant_type": "urn:ietf:params:oauth:grant-type:device_code",
        "client_id": clientId,
        "device_code": deviceCode,
      ]
    )

    return try parseResult(result)
  }

  private func parseResult<T>(
    _ result: (Data, HTTPURLResponse),
    into: T.Type = T.self,
  ) throws -> T where T: Codable {
    let (data, response) = result
    if response.isSuccessful {
      return try data.jsonDecoded(keyStrategy: .convertFromSnakeCase)
    } else {
      throw try data.jsonDecoded(into: AuthApiError.self, keyStrategy: .convertFromSnakeCase)
    }
  }
}

struct AuthApiError: Error, Codable {
  let error: String

  var isAuthorizationPending: Bool {
    error == "authorization_pending"
  }
}

struct DeviceAuthorization: Codable {
  let deviceCode: String
  let userCode: String
  let verificationUri: String
  let expiresIn: Int
  let interval: Int
  let message: String
}

struct AuthCredentials: Codable {
  let expiresIn: Int
  let idToken: String
  let accessToken: String
  let refreshToken: String
}
