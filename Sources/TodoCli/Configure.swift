import TodoAuth

func configure() throws {
  let config = try AppConfig.fromEnv()
  TodoAuth.configure(appClientId: config.appClientId)
}
