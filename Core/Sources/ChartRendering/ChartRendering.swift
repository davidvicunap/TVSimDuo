#if canImport(Metal)
import Metal

/// Metal rendering pipeline for DuoTrade charts (implemented in Phase 4).
public enum ChartRendering {
    /// Whether a Metal device is available in the current process.
    public static var isMetalAvailable: Bool { MTLCreateSystemDefaultDevice() != nil }
}
#endif
