import XCTest
@testable import Titlecaser

final class TitlecaserTests: XCTestCase {
    struct TestCase: Codable {
        var original: String
        var expectedResult: String
    }
    
    let testCasesPath = Bundle.module.url(forResource: "TestCases", withExtension: "json")
    
    func test() throws {
        guard let testCasesPath else { throw TestError.missingTestCasesFile }
        let testCasesData = try Data(contentsOf: testCasesPath)
        let testCases = try JSONDecoder().decode([TestCase].self, from: testCasesData)
        
        for testCase in testCases {
            let titleCased = testCase.original.toTitleCase()
            let expected = testCase.expectedResult
            
            XCTAssertEqual(titleCased, expected)
        }
    }
    
    enum TestError: Error {
        case missingTestCasesFile
    }
}
