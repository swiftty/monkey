import XCTest

import monkeyTests

var tests = [XCTestCaseEntry]()
tests += monkeyTests.allTests()
XCTMain(tests)
