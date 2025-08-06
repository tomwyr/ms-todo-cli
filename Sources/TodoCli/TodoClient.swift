import TodoCommon

class TodoClient {
  init(httpClient: HttpClient) {
    self.httpClient = httpClient
  }

  let httpClient: HttpClient

  func getTaskLists() async throws -> [TaskList] {
    let accessToken = ""
    let (data, response) = try await httpClient.request(
      url: "/me/todo/lists",
      headers: ["Authorization": "Bearer \(accessToken)"],
    )
    return if response.isSuccessful {
      try data.jsonDecoded()
    } else {
      fatalError("TODO")
    }
  }
}
