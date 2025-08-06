struct AppConfig {
  let graphApiUrl: String
  let oauthApiUrl: String
  let appClientId: String

  static func fromEnvAndDefaults() throws -> AppConfig {
    let envVar = try EnvVars.load()
    return .init(
      graphApiUrl: "https://graph.microsoft.com/v1.0",
      oauthApiUrl: "https://login.microsoftonline.com/consumers/oauth2/v2.0",
      appClientId: try envVar("APP_CLIENT_ID"),
    )
  }
}
