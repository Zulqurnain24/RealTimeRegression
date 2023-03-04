import Foundation
import UIKit
import TabularData

#if canImport(CreateML)
import CreateML
#endif

public struct FavoriteWrapper<T> {
    public let model: T
    public var title: String
    public var hasOpened: Bool? = false {
        didSet {
            openingTime = Date()
        }
    }
    public var hasClosed: Bool? = false  {
        didSet {
            guard let closingTime = closingTime, closingTime.timeIntervalSince1970 > 0, let openingTime = openingTime, openingTime.timeIntervalSince1970 > 0 else { return }
            timeSpent = closingTime.timeIntervalSince(openingTime)
        }
    }
    private var openingTime: Date? = Date()
    private var closingTime: Date? = Date()
    public var timeSpent: Double = 0
    public var imageHistogram: [CGFloat] = []
    public var image: UIImage?  {
        didSet {
            imageHistogram = image?.imageHistogram() ?? []
        }
    }
    public init(model: T, title: String, imageHistogram: [CGFloat]) {
        self.model = model
        self.title = title
        self.imageHistogram = imageHistogram
    }
}

public final class RealTimeRegression {

    public static let shared = RealTimeRegression()
    
    private let queue = DispatchQueue(label: "com.realtime.regression.queue", qos: .userInitiated)
    
    public func computeRecommendations<Element: Codable>(basedOn items: [FavoriteWrapper<Element>]) async throws -> [Element] {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async {
                if #available(iOS 15.0, *) {
                #if targetEnvironment(simulator)
                    continuation.resume(throwing: NSError(domain: "Simulator Not Supported", code: -1))
                #else
                    let trainingData = items.filter {
                        $0.timeSpent != 0
                    }
                    
                    let trainingDataFrame = self.dataFrame(for: trainingData)
                    
                    let testData = items
                    let testDataFrame = self.dataFrame(for: testData)
                    
                    do {
                        let regressor = try MLLinearRegressor(trainingData: trainingDataFrame, targetColumn: "timeSpent")
                        
                        let predictionsColumn = (try regressor.predictions(from: testDataFrame)).compactMap { value in
                            value as? Double
                        }
                        
                        let sorted = zip(testData, predictionsColumn)
                            .sorted { lhs, rhs -> Bool in
                                lhs.1 > rhs.1
                            }
                            .filter {
                                $0.1 > 0
                            }
                            .prefix(10)
                        
                        let result = sorted.map(\.0.model)
                        
                        continuation.resume(returning: result)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                #endif
                } else {
                   print("RealTimeRegression is only supported for iOS 15 and beyond")
                }
            }
        }
    }
    
    private func dataFrame<Element: Codable>(for data: [FavoriteWrapper<Element>]) -> DataFrame {
        var dataFrame = DataFrame()
        
        dataFrame.append(
            column: Column(name: "title", contents: data.map(\.title))
        )
        
        dataFrame.append(
            column: Column(name: "timeSpent", contents: data.map(\.timeSpent))
        )
        
        dataFrame.append(
            column: Column(name: "imageHistogram", contents: data.map(\.imageHistogram))
        )
 
        return dataFrame
    }
}
