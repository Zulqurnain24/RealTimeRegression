//
//  File.swift
//  
//
//  Created by Mohammad Zulqurnain on 04/03/2023.
//

import UIKit

extension UIImage {
    open func imageHistogram() -> [CGFloat] {
        // Create color space and histogram data
        guard let cgImage = self.cgImage, let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            return []
        }
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bytesCount = bytesPerRow * height
        var rawData = [UInt8](repeating: 0, count: bytesCount)
        let context = CGContext(data: &rawData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
        
        // Calculate histogram data
        var histogramData = [CGFloat](repeating: 0, count: 256)
        for i in 0..<width {
            for j in 0..<height {
                let index = (j * width + i) * bytesPerPixel
                let red = CGFloat(rawData[index]) / 255.0
                let green = CGFloat(rawData[index + 1]) / 255.0
                let blue = CGFloat(rawData[index + 2]) / 255.0
                let luminance = (0.2126 * red + 0.7152 * green + 0.0722 * blue) * 255.0
                histogramData[Int(luminance)] += 1
            }
        }
        
        // Normalize histogram data
        let totalCount = CGFloat(width * height)
        for i in 0..<histogramData.count {
            histogramData[i] /= totalCount
        }
        
        return histogramData
    }
}

