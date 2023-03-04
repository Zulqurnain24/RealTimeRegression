//
//  FavoriteWrapper.swift
//  
//
//  Created by Mohammad Zulqurnain on 04/03/2023.
//

import UIKit

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
            guard let closingTime = closingTime,
                  closingTime.timeIntervalSince1970 > 0,
                  let openingTime = openingTime,
                  openingTime.timeIntervalSince1970 > 0 else { return }
            timeSpent = Double(closingTime.timeIntervalSince(openingTime))
        }
    }
    private var openingTime: Date? = Date()
    private var closingTime: Date? = Date()
    public var timeSpent: Double = 0.0
    public var imageHistogram: [Double] = []
    public var image: UIImage?  {
        didSet {
            imageHistogram = image?.imageHistogram() ?? []
        }
    }
    public var isFavorite: Bool?
    public init(model: T, title: String, imageHistogram: [Double]) {
        self.model = model
        self.title = title
        self.imageHistogram = imageHistogram
    }
}
