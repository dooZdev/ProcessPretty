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
        
        XCTAssertEqual(logs, ["✅ echo\n"])
    }
    
    func test_run_sync_verbose() throws {
        var logs = [String]()
        
        let process = try ProcessPretty(
            executable: "echo", arguments: ["some text"],
            output: { text, _, _ in logs.append(text) },
            verbose: true
        )
        try process.run(in: #function, at: #filePath)
        
        XCTAssertEqual(logs, ["some text\n", "✅ echo\n"])
    }

    static var allTests = [
        ("test_run_sync", test_run_sync),
        ("test_run_sync_verbose", test_run_sync_verbose)
    ]
}
