import Foundation
import TodoCommon

extension TodoAuth {
  static private(set) var config: AuthConfig?

  public static func configure(
    appClientId: String,
    oauthApiUrl: String = "https://login.microsoftonline.com/consumers/oauth2/v2.0",
    cryptoKey: String = "uw8cpkiP0WvAKDWpzQ7GVE4b0BxnqqHk",
    authStoragePath: String = homeDirFilePath(at: "msTodoCliData"),
  ) {
    config = .init(
      appClientId: appClientId,
      oauthApiUrl: oauthApiUrl,
      cryptoKey: cryptoKey,
      authStoragePath: authStoragePath,
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
      authStorage: AuthStorage(
        valueCrypto: JsonCrypto(key: config.cryptoKey),
        filePath: config.authStoragePath,
      ),
    )
  }
}

public func homeDirFilePath(at fileName: String) -> String {
  FileManager.default.homeDirectoryForCurrentUser.appending(path: fileName).path
}

struct AuthConfig {
  let appClientId: String
  let oauthApiUrl: String
  let cryptoKey: String
  let authStoragePath: String
}
