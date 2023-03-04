import Foundation
import UIKit
import TabularData

#if canImport(CreateML)
import CreateML
#endif

public final class RealTimeRegression {
    
    public static let shared = RealTimeRegression()
    
    var recommendations = 3 // By default 3 recommendations
    
    private let queue = DispatchQueue(label: "com.realtime.regression.queue", qos: .userInitiated)
    
    public func computeRecommendations<Element: Codable>(basedOn items: [FavoriteWrapper<Element>]) async throws -> [Element] {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async {
                if #available(iOS 15.0, *) {
#if targetEnvironment(simulator)
                    continuation.resume(throwing: NSError(domain: "Simulator Not Supported", code: -1))
#else
                    let trainingData = items
                    
                    let trainingDataFrame = self.dataFrame(for: trainingData)
                    
                    let testData = items
                    let testDataFrame = self.dataFrame(for: testData)
                    
                    do {
                        let regressor = try MLLinearRegressor(trainingData: trainingDataFrame, targetColumn: "favorite")
                        
                        let predictionsColumn = (try regressor.predictions(from: testDataFrame)).compactMap { value in
                            value as? Double
                        }
                        
                        let sorted = zip(testData, predictionsColumn)
                          .sorted { lhs, rhs -> Bool in
                              lhs.0.timeSpent > rhs.0.timeSpent && lhs.1 > rhs.1
                          }
                          .filter {
                            $0.1 > 0
                          }
                          .prefix(self.recommendations)
                        
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
        
        dataFrame.append(
          column: Column<Int>(
            name: "favorite",
            contents: data.map {
              if let isFavorite = $0.isFavorite {
                return isFavorite ? 1 : -1
              } else {
                return 0
              }
            }
          )
        )
        
        return dataFrame
    }
}
