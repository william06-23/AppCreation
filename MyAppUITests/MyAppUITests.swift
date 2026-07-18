import XCTest

// MARK: - UI 测试
// 模拟用户交互，验证界面行为

final class MyAppUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launch()
    }

    func testHomeScreen_showsNavigationTitle() {
        XCTAssertTrue(app.navigationBars["Users"].exists)
    }
}
