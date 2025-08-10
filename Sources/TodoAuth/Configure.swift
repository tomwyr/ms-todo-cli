import TodoCommon

extension TodoAuth {
  static private(set) var config: AuthConfig?

  public static func configure(
    appClientId: String,
    oauthApiUrl: String = "https://login.microsoftonline.com/consumers/oauth2/v2.0"
  ) {
    config = .init(
      appClientId: appClientId,
      oauthApiUrl: oauthApiUrl,
    )
  }

  public convenience init() {
    guard let config = Self.config else {
      fatalError("TodoAuth not initialized - call `configure()` to set up the module before use.")
    }

    self.init(
      authClient: AuthClient(
        clientId: config.appClientId,
        httpClient: HttpClient(baseUrl: config.oauthApiUrl),
      ),
      authStorage: AuthStorage(),
    )
  }
}

struct AuthConfig {
  let appClientId: String
  let oauthApiUrl: String
}
