import TodoAuth
import TodoCommon

struct Dependencies {
  init() throws {
    config = try AppConfig.fromEnvAndDefaults()
  }

  let config: AppConfig

  func authService() throws -> AuthService {
    AuthService(
      authClient: AuthClient(
        clientId: config.appClientId,
        httpClient: HttpClient(baseUrl: config.oauthApiUrl),
      ),
      authStorage: AuthStorage(),
    )
  }
}
