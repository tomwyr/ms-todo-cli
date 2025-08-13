import Foundation

public class HttpClient {
  public init(baseUrl: String? = nil) {
    self.baseUrl = baseUrl
  }

  let baseUrl: String?

  public func request(
    url: String,
    method: String = "GET",
    headers: [String: String] = [:],
    body: [String: String]? = nil
  ) async throws -> (Data, HTTPURLResponse) {
    let urlString = if let baseUrl { baseUrl + url } else { url }
    guard let requestUrl = URL(string: urlString) else {
      throw URLError(.badURL)
    }

    var request = URLRequest(url: requestUrl)
    request.httpMethod = method
    headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

    if let body {
      let bodyString = body.map { "\($0)=\($1)" }.joined(separator: "&")
      request.httpBody = bodyString.data(using: .utf8)
    }

    let (data, response) = try await URLSession.shared.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse else {
      throw URLError(.badServerResponse)
    }

    return (data, httpResponse)
  }
}

extension HTTPURLResponse {
  public var isSuccessful: Bool {
    200..<300 ~= statusCode
  }
}

extension Data {
  public func jsonDecoded<T: Codable>(
    into: T.Type = T.self,
    keyStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
  ) throws -> T {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = keyStrategy
    return try decoder.decode(T.self, from: self)
  }
}
