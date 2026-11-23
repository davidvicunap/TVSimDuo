/// The physical arrangement the workspace is laid out for.
///
/// Derived purely from layout geometry (reserved `.division` regions, container size
/// and horizontal size class), never from device orientation or hinge angle.
public enum WorkspacePosture: String, Sendable, Codable, CaseIterable {
    /// Compact width with no active fold: outer cover display ("Glance & Execute").
    case cover
    /// Regular width with no active fold: fully unfolded workstation.
    case unfolded
    /// Partially folded with a vertical crease: chart on one side, execution on the other.
    case book
    /// Partially folded with a horizontal crease: chart above, DOM / hotkeys below.
    case tabletop
}
