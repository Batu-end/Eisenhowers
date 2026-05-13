import SwiftUI
import SwiftData

struct ContentView: View {
    // The Namespace ties together the card and its expanded counterpart.
    // SwiftUI uses it to animate geometry between the two views.
    @Namespace private var heroAnimation

    // Tracks which quadrant (if any) is currently expanded.
    @State private var selectedQuadrant: Quadrant? = nil

    // We query all tasks here only to compute the per-quadrant counts.
    @Query private var allTasks: [TodoItem]

    var body: some View {
        ZStack {
            // ── Background ────────────────────────────────────────────────
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            // ── Matrix grid ───────────────────────────────────────────────
            VStack(spacing: 0) {
                matrixHeader
                    .padding(.horizontal)
                    .padding(.top)
                    .padding(.bottom, 16)

                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 16
                ) {
                    ForEach(Quadrant.allCases) { quadrant in
                        QuadrantCardView(
                            quadrant:  quadrant,
                            taskCount: incompleteCount(for: quadrant),
                            namespace: heroAnimation
                        )
                        // Hide the card while its expanded counterpart is
                        // visible so we don't see a ghost underneath.
                        .opacity(selectedQuadrant == quadrant ? 0 : 1)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                                selectedQuadrant = quadrant
                            }
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()
            }

            // ── Expanded overlay ──────────────────────────────────────────
            // When a quadrant is selected the ExpandedQuadrantView covers
            // the whole screen.  Because it shares the same matchedGeometry
            // id as the tapped card, SwiftUI interpolates the frame from
            // the card's position/size → full screen (and back on close).
            if let quadrant = selectedQuadrant {
                ExpandedQuadrantView(
                    quadrant:  quadrant,
                    namespace: heroAnimation,
                    onClose: {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                            selectedQuadrant = nil
                        }
                    }
                )
                .zIndex(10)
            }
        }
    }

    // MARK: - Header

    private var matrixHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("Eisenhower Matrix")
                    .font(.title.bold())
                Text("Focus on what matters most")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    // MARK: - Helpers

    private func incompleteCount(for quadrant: Quadrant) -> Int {
        allTasks.filter { $0.quadrantRaw == quadrant.rawValue && !$0.isCompleted }.count
    }
}
