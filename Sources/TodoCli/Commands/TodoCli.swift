import ArgumentParser

@main
struct TodoCli: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "todocli",
        subcommands: [Auth.self],
    )
}
