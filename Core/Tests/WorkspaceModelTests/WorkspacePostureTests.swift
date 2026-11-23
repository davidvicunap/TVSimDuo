import Testing
@testable import WorkspaceModel

@Suite("Workspace posture")
struct WorkspacePostureTests {
    @Test func coversAllFourPoses() {
        #expect(Set(WorkspacePosture.allCases) == [.cover, .unfolded, .book, .tabletop])
    }
}
