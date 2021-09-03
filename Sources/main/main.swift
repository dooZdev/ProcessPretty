import Foundation
import ProcessPretty
import TSCBasic

let queue = DispatchQueue(label: "a queue")
Process.verbose = false
let lsAsync = try ProcessPretty(executable: "ls")
let sleepAsyncError = try ProcessPretty(executable: "sleep", arguments: ["5"])
let dispatchGroup = DispatchGroup()

let echoSync = try ProcessPretty(executable: "echo", arguments: ["something to output in sync"])
func sync() {
    do {
        try echoSync.run()
    } catch {
        exit(EXIT_FAILURE)
    }
}
func async() {
    dispatchGroup.enter()
    lsAsync.run() { _ in
        dispatchGroup.leave()
    }
}
func asyncError() {
    dispatchGroup.enter()
    sleepAsyncError.run() { _  in
        dispatchGroup.leave()
    }
}
sync()
async()
asyncError()

dispatchGroup.notify(queue: .main) {
    exit(EXIT_SUCCESS)
}

dispatchMain() // have to do this to wait for the async process to finish
