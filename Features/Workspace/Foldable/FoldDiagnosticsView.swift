import SwiftUI

/// Live fold diagnostics, available in DEBUG builds as the "Fold" tab.
///
/// This file is also the **Phase 0 API probe**: it calls each iOS 27.1 iPhone Duo API
/// that DuoTrade depends on, using the signatures from public example code.
/// If one of them differs in the shipping SDK, the build error lands here and the fix
/// stays inside `Features/Workspace/Foldable/`.
///
/// APIs exercised:
/// - `ArrangementView { } secondary: { }` with `.arrangementViewStyle(.split.axes(_:))`
/// - `.splitArrangementLayoutRatio(_:)` on the primary pane, `\.splitArrangementAxis`
/// - `GeometryProxy.reservedRegions(kind:options:)` for `.division` and `.occlusion`
/// - `.onHingeChange { old, new in }` with `DeviceHinge.status` and `.angle`
/// - `\.toolbarVerticalEdge`, `ToolbarItem.axisBehavior(_:)`, `.visibilityPriority(_:)`,
///   `ToolbarItemVisibilityPriority(higherThan:)` and `ToolbarOverflowMenu`
struct FoldDiagnosticsView: View {
    @Environment(\.toolbarVerticalEdge) private var toolbarVerticalEdge
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.displayScale) private var displayScale

    @State private var hinge: DeviceHinge?
    @State private var includeInactive = true
    @State private var hingeEventCount = 0

    var body: some View {
        ArrangementView {
            RegionsCanvas(includeInactive: includeInactive)
                .splitArrangementLayoutRatio(0.6)
        } secondary: {
            statusList
        }
        .arrangementViewStyle(.split.axes([.horizontal, .vertical]))
        .onHingeChange { _, newContext in
            hinge = newContext.hinge
            hingeEventCount += 1
        }
        .navigationTitle("Fold Diagnostics")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Toggle(isOn: $includeInactive) {
                    Label("Show Inactive Regions", systemImage: "eye")
                }
            }
            .axisBehavior(.verticalPreferred)
            .visibilityPriority(ToolbarItemVisibilityPriority(higherThan: .high))

            ToolbarItem(placement: .secondaryAction) {
                Button("Reset Counter", systemImage: "arrow.counterclockwise") {
                    hingeEventCount = 0
                }
            }
            .axisBehavior(.automatic)
            .visibilityPriority(.low)

            ToolbarOverflowMenu {
                Button("Copy Snapshot", systemImage: "doc.on.doc") {}
            }
        }
    }

    private var statusList: some View {
        List {
            Section("Hinge (haptics / animation only)") {
                LabeledContent("Status", value: hinge.map { String(describing: $0.status) } ?? "unavailable")
                LabeledContent("Angle", value: hinge.map { String(format: "%.0f°", $0.angle.degrees) } ?? "—")
                LabeledContent("Updates", value: "\(hingeEventCount)")
            }
            Section("Environment") {
                LabeledContent("Horizontal size class", value: horizontalSizeClass.map { String(describing: $0) } ?? "nil")
                LabeledContent("Vertical size class", value: verticalSizeClass.map { String(describing: $0) } ?? "nil")
                LabeledContent("Display scale", value: String(format: "%.1f", displayScale))
                LabeledContent("Vertical toolbar edge", value: toolbarVerticalEdge.map { String(describing: $0) } ?? "horizontal bars")
            }
        }
    }
}

/// Draws every reserved region reported for this pane's geometry.
private struct RegionsCanvas: View {
    let includeInactive: Bool

    @Environment(\.splitArrangementAxis) private var splitAxis

    var body: some View {
        GeometryReader { proxy in
            let options: ReservedRegion.QueryOptions = includeInactive ? [.includeInactive] : []
            let divisions = proxy.reservedRegions(kind: .division, options: options)
            let occlusions = proxy.reservedRegions(kind: .occlusion, options: options)

            ZStack(alignment: .topLeading) {
                Color.secondary.opacity(0.08)

                ForEach(divisions) { region in
                    RegionOverlay(region: region, label: "division", tint: .orange)
                }
                ForEach(occlusions) { region in
                    RegionOverlay(region: region, label: "occlusion", tint: .red)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Pane \(Int(proxy.size.width)) × \(Int(proxy.size.height)) pt")
                    Text("Divisions: \(divisions.count)  Occlusions: \(occlusions.count)")
                    Text("Split axis: \(splitAxis.map { String(describing: $0) } ?? "none")")
                }
                .font(.caption.monospaced())
                .padding(8)
            }
        }
    }
}

private struct RegionOverlay: View {
    let region: ReservedRegion
    let label: String
    let tint: Color

    var body: some View {
        let frame = region.frame
        Rectangle()
            .fill(tint.opacity(region.isActive ? 0.45 : 0.15))
            .overlay {
                Rectangle().strokeBorder(tint, style: StrokeStyle(lineWidth: 1, dash: region.isActive ? [] : [4, 3]))
            }
            .overlay(alignment: .top) {
                Text("\(label)\(region.isActive ? "" : " (inactive)")")
                    .font(.caption2.monospaced())
                    .foregroundStyle(tint)
                    .fixedSize()
            }
            .frame(width: max(frame.width, 1), height: max(frame.height, 1))
            .offset(x: frame.minX, y: frame.minY)
            .allowsHitTesting(false)
            .accessibilityLabel("\(label) region, \(region.isActive ? "active" : "inactive")")
    }
}
