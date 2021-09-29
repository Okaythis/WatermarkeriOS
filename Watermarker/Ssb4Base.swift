import UIKit

@objc
public class Ssb4Base: NSObject {
    private var image: UIImage
    private var seed = 0
    private var messageLength = 0
    private var currentPixelX = 0
    private var currentPixelY = 0
    private var currentPixelColor = UIColor()
    private var currentPixelColorRgb: (r: Double, g: Double, b: Double, a: Double)?
    private var message: [UInt8]
    private var currentByte: UInt8 = 0

    @objc
    public init(image: UIImage, seed: Int, message: String) {
        self.message = Array(message.utf8)
        self.image = image
        self.seed = seed
        self.messageLength = message.count
    }
    
    @objc
    public func execute(completion: @escaping (UIImage?) -> ()) {
        let bitmapHeight = Int(image.size.height)
        let bitmapWidth = Int(image.size.width)
        let pixelCount = bitmapWidth * bitmapHeight
        let blockCount = messageLength * 8
        let blockLength = pixelCount / blockCount
        let blockHalfLength = blockLength / 2
        let randomUniqueSequence = createRandomUniqueSequence(blockCount: blockCount)

        for byteIndex in 0..<messageLength {
            var bitIndex = 0
            var pixelShift = 0
            while bitIndex < 8 {
                let index = byteIndex * 8 + bitIndex
                let firstPixelInBlock = blockLength * Int(randomUniqueSequence[index])
                let blockCenterPixel = firstPixelInBlock + blockHalfLength + pixelShift

                currentPixelX = blockCenterPixel % bitmapWidth
                currentPixelY = blockCenterPixel / bitmapWidth

                guard let rgba = image.rgba(x: currentPixelX, y: currentPixelY) else {
                    assertionFailure()
                    completion(nil)
                    break
                }
                currentPixelColor = UIColor(red: CGFloat(rgba.r), green: CGFloat(rgba.g), blue: CGFloat(rgba.b), alpha: CGFloat(rgba.a))
                currentPixelColorRgb = rgba
                let blueChannel = Int(rgba.b)

                if 4 <= blueChannel && blueChannel <= 251 {
                    loop(blueChannel: blueChannel, byteIndex: byteIndex, bitIndex: bitIndex)
                    bitIndex += 1
                } else { // Current pixel is bad, shift to right to get next pixel in block
                    pixelShift += 1
                    if pixelShift >= blockHalfLength {
                       // assertionFailure()
                        print("-- finding pixel Failure --")
                        completion(image)
                        return
                    }
                }
            }
        }
        completion(image)
    }

    private func loop(blueChannel: Int, byteIndex: Int, bitIndex: Int) {
        if bitIndex == 0 {
            currentByte = message[byteIndex]
        }
        let currentBit = BitUtils.fetchBit(value: Int(currentByte), bitIndex: bitIndex)
        let blueChanelSignificantBit = BitUtils.fetchSignificantBit(value: blueChannel)

        guard currentBit != blueChanelSignificantBit,
            let newBlueChannel = BitUtils.updateSignificantBitAndBits1235(value: blueChannel, bit: currentBit),
            let image = PixelsProcessor.update(image: image,
                                       blueComponent: UInt8(newBlueChannel) & 0xFF,
                                       x: currentPixelX,
                                       y: currentPixelY) else {
                return
        }
        print(currentPixelX, currentPixelY, UInt8(newBlueChannel) & 0xFF)
        self.image = image
    }

    private func createRandomUniqueSequence(blockCount: Int) -> [UInt64] {
        let random = Random(seed: UInt64(seed))
        var randomUniqueSequence = [UInt64]()
        var uniqueSequence = generateUniqueSequenceArray(withBlockCount: blockCount)

        while randomUniqueSequence.count < blockCount {
            guard var index = random.nextInt(bound: UInt64(blockCount - 1)) else {
                assertionFailure()
                return []
            }
            if randomUniqueSequence.contains(index) {
                guard let i = uniqueSequence.last else {
                    return []
                }
                index = i
                if index >= UInt64(blockCount) {
                    assertionFailure()
                    return []
                }
            }
            uniqueSequence = uniqueSequence.filter() { $0 != index }
            randomUniqueSequence.append(index)
        }
        return randomUniqueSequence
    }

    private func generateUniqueSequenceArray(withBlockCount blockCount: Int) -> [UInt64] {
        var sequence = [UInt64]()
        for number in 0..<blockCount {
            sequence.append(UInt64(number))
        }
        return sequence
    }
}
