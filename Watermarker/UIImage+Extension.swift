import UIKit

extension UIImage {

    func rgba(x: Int, y: Int) -> (r: Double, g: Double, b: Double, a: Double)? {
        guard let cgImage = cgImage,
            let provider = cgImage.dataProvider,
            let pixelData = provider.data else {
                return nil
        }
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let pixelInfo = ((Int(size.width) * y) + x) * 4

        let r = Double(data[pixelInfo])
        let g = Double(data[pixelInfo+1])
        let b = Double(data[pixelInfo+2])
        let a = Double(data[pixelInfo+3])
        return (r: r, g: g, b: b, a: a)
    }
}
