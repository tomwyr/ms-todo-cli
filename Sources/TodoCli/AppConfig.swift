struct AppConfig {
  let appClientId: String

  static func fromEnv() throws -> AppConfig {
    try EnvVars.load()
    return .init(
      appClientId: try EnvVars.get("APP_CLIENT_ID"),
    )
  }
}
