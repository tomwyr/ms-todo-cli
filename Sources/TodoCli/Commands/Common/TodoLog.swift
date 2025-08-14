enum TodoLog {
  case errorOccurred(_ verbose: Bool)

  var message: String {
    switch self {
    case .errorOccurred(let verbose):
      if verbose {
        "An unexpected error occurred"
      } else {
        "An unexpected error occurred. Use --verbose for more info"
      }
    }
  }
}
