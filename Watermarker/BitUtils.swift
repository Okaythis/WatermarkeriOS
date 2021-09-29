struct BitUtils {

    static func fetchBit(value: Int, bitIndex: Int) -> Int {
        return (value >> bitIndex) & 0b1 // After shift get first bit
    }

    static func updateBit(value: Int, bit: Int, bitIndex: Int) -> Int? {
        if bit != 1 && bit != 0 {
            assertionFailure()
            return nil
        }
        let mask = 1 << bitIndex
        return bit == 1 ? value | mask : value & ~mask
    }

    static func fetchSignificantBit(value: Int) -> Int {
        return fetchBit(value: value, bitIndex: 3)
    }

    static func updateSignificantBit(value: Int, bit: Int) -> Int? {
        return updateBit(value: value, bit: bit, bitIndex: 3)
    }

    static func updateSignificantBitAndBits1235(value: Int, bit: Int) -> Int? {
        guard value >= 4 && value <= 251,
            var newVal = updateSignificantBit(value: value, bit: bit) else {
                assertionFailure()
                return nil
        }
        let sign = bit == 1 ? -1 : 1

        for delta in 1..<16 {
            if abs(newVal - value) <= 4 && newVal != 0 {
                return newVal
            }
            newVal = value + sign * delta
            guard let newValUpdated = updateSignificantBit(value: newVal, bit: bit) else {
                return nil
            }
            newVal = newValUpdated
        }
        return nil
    }
}
