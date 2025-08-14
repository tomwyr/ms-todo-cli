import TodoAuth

protocol AuthCommand: TodoCommand {}

extension AuthCommand {
  func log(_ authLog: AuthLog) {
    print(authLog.message)
  }
}

extension Auth.Status: AuthCommand {}
extension Auth.LogIn: AuthCommand {}
extension Auth.LogOut: AuthCommand {}
