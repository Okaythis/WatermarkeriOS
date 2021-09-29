import UIKit

class PixelsProcessor {

    static func update(image: UIImage, blueComponent: UInt8, x: Int, y: Int) -> UIImage? {
        guard let cgImage = image.cgImage else {
            assertionFailure()
            return nil
        }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
        bitmapInfo |= CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        let width = Int(image.size.width)
        let height = Int(image.size.height)
        let bytesPerRow = width * 4
        let imageData = UnsafeMutablePointer<PixelData>.allocate(capacity: width * height)
        defer { imageData.deallocate() }
        guard let imageContext = CGContext(data: imageData,
                                           width: width,
                                           height: height,
                                           bitsPerComponent: 8,
                                           bytesPerRow: bytesPerRow,
                                           space: colorSpace,
                                           bitmapInfo: bitmapInfo) else {
            assertionFailure()
            return nil
        }
        imageContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        let pixels = UnsafeMutableBufferPointer<PixelData>(start: imageData, count: width * height)
        let index = width * y + x
        let pixel = pixels[index]
        pixels[index] = PixelData(r: pixel.r, g: pixel.g, b: blueComponent, a: pixel.a)
        guard let newCGImage = imageContext.makeImage() else {
            assertionFailure()
            return nil
        }
        return UIImage(cgImage: newCGImage)
    }
}

public struct PixelData {
    var r: UInt8
    var g: UInt8
    var b: UInt8
    var a: UInt8
}
