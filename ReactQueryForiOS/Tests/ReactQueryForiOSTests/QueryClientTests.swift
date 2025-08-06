import Combine
import XCTest

@testable import ReactQueryForiOS

@available(iOS 15.0, *)
final class QueryClientTests: XCTestCase {

    var queryClient: QueryClient!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        queryClient = QueryClient()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        queryClient = nil
        cancellables = nil
        super.tearDown()
    }

    // MARK: - Query Tests

    func testQuerySuccess() async {
        let expectation = XCTestExpectation(description: "Query should succeed")

        queryClient.query(key: "test", queryFn: { "success" })
            .sink { result in
                switch result {
                case .success(let data):
                    XCTAssertEqual(data, "success")
                    expectation.fulfill()
                case .failure:
                    XCTFail("Query should not fail")
                case .loading:
                    break
                }
            }
            .store(in: &cancellables)

        await fulfillment(of: [expectation], timeout: 5.0)
    }

    func testQueryFailure() async {
        let expectation = XCTestExpectation(description: "Query should fail")

        queryClient.query(key: "test", queryFn: { throw TestError.test })
            .sink { result in
                switch result {
                case .success:
                    XCTFail("Query should not succeed")
                case .failure(let error):
                    XCTAssertTrue(error is TestError)
                    expectation.fulfill()
                case .loading:
                    break
                }
            }
            .store(in: &cancellables)

        await fulfillment(of: [expectation], timeout: 5.0)
    }

    func testQueryCaching() async {
        let expectation1 = XCTestExpectation(description: "First query should succeed")
        let expectation2 = XCTestExpectation(description: "Second query should use cache")

        var callCount = 0

        let queryFn: () async throws -> String = {
            callCount += 1
            return "cached"
        }

        // 第一次查询
        queryClient.query(key: "cache-test", queryFn: queryFn)
            .sink { result in
                switch result {
                case .success(let data):
                    XCTAssertEqual(data, "cached")
                    XCTAssertEqual(callCount, 1)
                    expectation1.fulfill()
                case .failure:
                    XCTFail("First query should not fail")
                case .loading:
                    break
                }
            }
            .store(in: &cancellables)

        await fulfillment(of: [expectation1], timeout: 5.0)

        // 第二次查询应该使用缓存
        queryClient.query(key: "cache-test", queryFn: queryFn)
            .sink { result in
                switch result {
                case .success(let data):
                    XCTAssertEqual(data, "cached")
                    XCTAssertEqual(callCount, 1)  // 应该没有再次调用
                    expectation2.fulfill()
                case .failure:
                    XCTFail("Second query should not fail")
                case .loading:
                    break
                }
            }
            .store(in: &cancellables)

        await fulfillment(of: [expectation2], timeout: 5.0)
    }

    func testQueryInvalidation() async {
        let expectation1 = XCTestExpectation(description: "First query should succeed")
        let expectation2 = XCTestExpectation(
            description: "Second query should succeed after invalidation")

        var callCount = 0

        let queryFn: () async throws -> String = {
            callCount += 1
            return "data"
        }

        // 第一次查询
        queryClient.query(key: "invalidate-test", queryFn: queryFn)
            .sink { result in
                switch result {
                case .success(let data):
                    XCTAssertEqual(data, "data")
                    XCTAssertEqual(callCount, 1)
                    expectation1.fulfill()
                case .failure:
                    XCTFail("First query should not fail")
                case .loading:
                    break
                }
            }
            .store(in: &cancellables)

        await fulfillment(of: [expectation1], timeout: 5.0)

        // 使查询失效
        queryClient.invalidateQuery(key: "invalidate-test")

        // 第二次查询应该重新执行
        queryClient.query(key: "invalidate-test", queryFn: queryFn)
            .sink { result in
                switch result {
                case .success(let data):
                    XCTAssertEqual(data, "data")
                    XCTAssertEqual(callCount, 2)  // 应该再次调用
                    expectation2.fulfill()
                case .failure:
                    XCTFail("Second query should not fail")
                case .loading:
                    break
                }
            }
            .store(in: &cancellables)

        await fulfillment(of: [expectation2], timeout: 5.0)
    }

    func testPrefetch() async {
        let expectation = XCTestExpectation(description: "Prefetch should succeed")

        queryClient.prefetch(key: "prefetch-test", queryFn: { "prefetched" })

        // 等待一段时间让预取完成
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        // 验证缓存中有数据
        let cachedData: String? = queryClient.getCachedData(for: "prefetch-test")
        XCTAssertEqual(cachedData, "prefetched")

        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 5.0)
    }
}

// MARK: - Test Error

@available(iOS 15.0, *)
enum TestError: Error {
    case test
}
