import XCTest
import class Foundation.Bundle
import ProcessPretty
import TSCBasic

final class ProcessPrettyTests: XCTestCase {
    func test_run_sync() throws {
        var logs = [String]()
        
        let process = try ProcessPretty(
            executable: "echo", arguments: ["some text"],
            output: { text, _, _ in logs.append(text) }
        )
        try process.run(in: #function, at: #filePath)
        
        XCTAssertEqual(logs, ["📍 echo some text ... ", "✅ echo some text "])
    }
    
    func test_run_sync_verbose() throws {
        var logs = [String]()
        
        let process = try ProcessPretty(
            executable: "echo", arguments: ["some text"],
            output: { text, _, _ in logs.append(text) },
            verbose: true
        )
        try process.run(in: #function, at: #filePath)
        
        XCTAssertEqual(logs, ["\nin: .\n", "📍 echo some text ... ", "some text\n", "✅ echo some text "])
    }
    
    func test_run_sync_outputDirection() throws {
        var logs = [String]()
        
        let process = try ProcessPretty(
            executable: "echo", arguments: ["some text"],
            output: { text, _, _ in logs.append(text) },
            outputDirection: .none,
            verbose: true
        )
        try process.run(in: #function, at: #filePath)
        
        XCTAssertEqual(logs, ["\nin: .\n", "📍 echo some text ... ", "", "✅ echo some text "], "intermediate logs go to stdout and are not collected with outputDirection = .none. See test test_run_sync_verbose")
    }

    static var allTests = [
        ("test_run_sync", test_run_sync),
        ("test_run_sync_verbose", test_run_sync_verbose),
        ("test_run_sync_outputDirection", test_run_sync_outputDirection)
    ]
}
