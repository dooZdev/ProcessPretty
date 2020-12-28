import TSCBasic
import TSCUtility
import Dispatch

let currentVersion: Version = Version(0, 0, 2, prereleaseIdentifiers: [], buildMetadataIdentifiers: [])
public let terminalController = TerminalController(stream: stdoutStream)

/// Commandline tool that is platform endepended. Its main features are
/// - captures the output for evaluation before writing to console
/// - outputs in colors with optional progress bar
/// - offers generic way to run asynchronous processes
public final class ProcessPretty {
    
    public let process: TSCBasic.Process
    public let output: (String, TerminalController.Color, _ bold: Bool) -> Void
    
    private let evaluate: (ProcessResult) throws -> Void
    private let executable: AbsolutePath
    private let queue: DispatchQueue
    private let identifier: String
    
    /// A process can be executed only once. The executable has to be something that can be found in PATH or is a absolute path to an executable
    /// - Parameters:
    ///   - executable: name of executable found int PATH or absolute path to executable
    ///   - arguments: the arguments to send to the executable
    ///   - queue: The queue to use when running asynchronous tasks, defaults to global background
    ///   - workingDirectory: The working directory is by default the currentWorkingDirectory but when that is unavailable on the system it takes the homeDirectory.
    ///   - output: The output output is used to output formatted and colored
    ///   - verbose: by default takes the global `Process.verbose` value
    ///   - outputDirection: the direction to output defaults to collect, see type for more info
    ///   - evaluate: function that evalute the output before success is returned.
    /// - Throws: `ProcessPretty.error` or `Process.Error`
    public init(
        executable: String,
        arguments: [String] = [],
        queue: DispatchQueue = .global(qos: DispatchQoS.QoSClass.background),
        workingDirectory: AbsolutePath = localFileSystem.currentWorkingDirectory ?? localFileSystem.homeDirectory,
        output: @escaping (String, TerminalController.Color, _ bold: Bool) -> Void = { text, color, bold in terminalController?.write(text, inColor: color, bold: bold) } ,
        evaluate: @escaping (ProcessResult) throws -> Void = { _ in },
        outputDirection: Process.OutputRedirection = .collect,
        verbose: Bool = Process.verbose
    ) throws {
        self.queue = queue
        guard let exe = Process.findExecutable(executable) else {
            throw Process.Error.missingExecutableProgram(program: executable)
        }
        self.executable = exe
        self.evaluate = evaluate
        self.output = output
        self.identifier = "\(self.executable.prettyPath()) \(arguments.joined(separator: " "))"
        
        if #available(OSX 10.15, *) {
            process = Process(
                arguments: [exe.pathString] + arguments,
                environment: ProcessEnv.vars,
                workingDirectory: workingDirectory,
                outputRedirection: .collect(redirectStderr: true),
                verbose: verbose,
                startNewProcessGroup: true
            )
            
        } else {
            output("working directory cannot be set prior to macOS 10.15, ", .yellow, false)
            process = Process(
                arguments: [exe.pathString] + arguments,
                environment: ProcessEnv.vars,
                outputRedirection: .collect(redirectStderr: true),
                verbose: verbose,
                startNewProcessGroup: true
            )
        }
    }
    
    /// Runs in process in sync. Any output is redirected to stdout and will output colorred. In case of error that error is thrown
    /// - Parameters:
    ///   - function: the function where process is ran
    ///   - file:  the file where process is ran
    /// - Throws: `ProcessPretty.Error`
    /// - Returns: The result when there was no error
    @discardableResult
    public func run(in function: String, at file: String) throws -> ProcessResult {
        
        do {
            try outputWorkingDirectoryIfNeeded()
            output("📍 \(identifier) ... ", .green, false)
            try process.launch()
            let result = try process.waitUntilExit()
            return try process(result: result)
        } catch {
            let error = formatError(error, in: function, at: file)
            output("❌ \(identifier)\n", .red, true)
            throw error
        }
    }
    
    public func run(in function: String, at file: String,
                    result: @escaping (Swift.Result<ProcessResult, ProcessPretty.Error>) -> Void
    ) {
        do {
            try outputWorkingDirectoryIfNeeded()
            output("📍䷖ \(identifier) ... ", .green, false)
            try process.launch()
        } catch {
            result(.failure(formatError(error, in: function, at: file)))
        }
        
        queue.async { [self] in
            do {
                let _result = try process.waitUntilExit()
                result(.success(try process(result: _result)) )
            } catch {
                result(.failure(formatError(error, in: function, at: file)))
            }
        }
    }
    
    /// Formats the error
    /// - Parameters:
    ///   - error: the error to output
    ///   - function: use #function
    ///   - file: use #filePath
    /// - Returns: the error that has been written to the therminal, chan be rethrown for example
    public func formatError(_ error: Swift.Error, in function: String, at file: String) -> ProcessPretty.Error {
        return ProcessPretty.Error.run(error: error, in: function, at: .init(file))
    }
    
    private func outputWorkingDirectoryIfNeeded() throws {
        guard let workingDirectory = process.workingDirectory else {
            throw Error.missingWorkingDirectory
        }
        if process.verbose { output("\nin: \(workingDirectory.prettyPath())\n", .grey, false) }
    }
    
    private func process(result: ProcessResult) throws -> ProcessResult {
        guard result.exitStatus == .terminated(code: 0) else {
            throw ProcessPretty.Error.nonZeroExitStatus(result)
        }
        try evaluate(result)
        if process.verbose {
            output(try result.utf8Output(), .grey, false)
        }
        output("✅ \(identifier) ", .green, false)
        return result
    }
    
}


// MARK: Error

extension ProcessPretty {
    public enum Error: Swift.Error, CustomStringConvertible {
        case missingOutputTerminals
        case processCouldNotBeMadeFrom(executable: AbsolutePath, arguments: [String])
        case nonZeroExitStatus(ProcessResult)
        case missingWorkingDirectory
        case run(error: Swift.Error, in: String, at: AbsolutePath)
        
        public var description: String {
            switch self {
            case .missingOutputTerminals: return "❌ missing output terminal"
            case .processCouldNotBeMadeFrom(executable: let executable, arguments: let arguments): return "❌ invalid process for \(executable.prettyPath()) args: \(arguments.joined(separator: ", "))"
            case .nonZeroExitStatus(let result): return "❌ error result: \(result)"
            case .missingWorkingDirectory: return "❌ missing working directory"
            case .run(error: let error, in: let function, at: let file):
                return """
                ❌ in: \(function) at: \(file.prettyPath())
                \(error)
                """
            }
        }
    }
}
