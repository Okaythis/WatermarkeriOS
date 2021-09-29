class Random {
    private var seed: UInt64
    private let multiplier: UInt64 = 25214903917
    private let mask: UInt64 = 281474976710655
    private let addend: UInt64 = 11

    init(seed: UInt64) {
        self.seed = (seed ^ 25214903917) & 281474976710655
    }

    func nextInt(bound: UInt64) -> UInt64? {
        if bound <= 0 {
            assertionFailure()
            return nil
        }
        var r = next(bits: 31)
        let m = bound - 1
        if (bound & m) == 0 {
            r = (bound * r) >> 31
        } else {
            var u = r
            r = u % bound
            while u - r + m < 0 {
                r = u % bound
                u = next(bits: 31)
            }
        }
        return r
    }

    private func next(bits: UInt) -> UInt64 {
        let nextseed: UInt64 = (seed &* multiplier &+ addend) & mask
        assert(nextseed != seed)
        seed = nextseed
        return nextseed >> (48 - bits)
    }
}
