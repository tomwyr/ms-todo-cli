import TodoCommon

public class AuthClient {
  public init(clientId: String, httpClient: HttpClient) {
    self.clientId = clientId
    self.httpClient = httpClient
  }

  let clientId: String
  let httpClient: HttpClient

  func authorizeDevice() async throws -> DeviceAuthorization {
    let (data, response) = try await httpClient.request(
      url: "/devicecode",
      method: "POST",
      headers: ["Content-Type": "application/x-www-form-urlencoded"],
      body: [
        "clientId": clientId,
        "scope": "user.read%20openid%20profile%20offline_access",
      ],
    )

    return if response.isSuccessful {
      try data.jsonDecoded()
    } else {
      fatalError("TODO")
    }
  }

  func authenticate(deviceCode: String) async throws -> UserSession {
    let (data, response) = try await httpClient.request(
      url: "/token",
      method: "POST",
      headers: ["Content-Type": "application/x-www-form-urlencoded"],
      body: [
        "grant_type": "urn:ietf:params:oauth:grant-type:device_code",
        "client_id": clientId,
        "device_code": deviceCode,
      ]
    )

    return if response.isSuccessful {
      try data.jsonDecoded()
    } else {
      fatalError("TODO")
    }
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

struct UserSession: Codable {
  let expiresIn: Int
  let accessToken: String
  let refreshToken: String
}
