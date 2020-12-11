import SPMPipes
import ArgumentParser
import EmbraceChange
import TSCUtility

let currentVersion: Version = Version(0, 1, 4, prereleaseIdentifiers: [], buildMetadataIdentifiers: [])

struct ProcessPrettySPMPipes: ParsableCommand {
    static var configuration: CommandConfiguration = .init(
        commandName: "ProcessPretty-spm-pipes",
        version: currentVersion.description,
        subcommands: [PrePush.self, TestCommand.self, InitSPMPipes.self, UpdateExecutableVersion.self, LastVersionInGit.self, CreateTag.self, Release.self, RunSPMPipesBeforePushing.self, InitGithugActions.self],
        defaultSubcommand: TestCommand.self
    )
}
ProcessPrettySPMPipes.main()
