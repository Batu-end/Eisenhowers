import SwiftUI
import SwiftData

struct ContentView: View {
    @Namespace private var heroAnimation
    @State private var selectedQuadrant: Quadrant? = nil
    @Query private var allTasks: [TodoItem]

    // Single pass: compute both counts at once instead of iterating twice.
    private var counts: [String: (remaining: Int, total: Int)] {
        var incomplete: [String: Int] = [:]
        var total:      [String: Int] = [:]
        for task in allTasks {
            total[task.quadrantRaw, default: 0] += 1
            if !task.isCompleted { incomplete[task.quadrantRaw, default: 0] += 1 }
        }
        return Dictionary(uniqueKeysWithValues: Quadrant.allCases.map {
            ($0.rawValue, (incomplete[$0.rawValue, default: 0], total[$0.rawValue, default: 0]))
        })
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    .padding(.horizontal)
                    .padding(.top)
                    .padding(.bottom, 10)

                // Axis column labels
                HStack(spacing: 16) {
                    axisLabel("URGENT")
                    axisLabel("NOT URGENT")
                }
                .padding(.horizontal)
                .padding(.bottom, 6)

                // 2 × 2 grid — rows expand to fill remaining height
                VStack(spacing: 12) {
                    row(.doNow,    .schedule)
                    row(.delegate, .eliminate)
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            }

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

    // MARK: - Grid helpers

    @ViewBuilder
    private func row(_ left: Quadrant, _ right: Quadrant) -> some View {
        HStack(spacing: 12) {
            card(left)
            card(right)
        }
        .frame(maxHeight: .infinity)
    }

    @ViewBuilder
    private func card(_ quadrant: Quadrant) -> some View {
        let c = counts[quadrant.rawValue] ?? (0, 0)
        QuadrantCardView(
            quadrant:  quadrant,
            remaining: c.remaining,
            total:     c.total,
            namespace: heroAnimation
        )
        .opacity(selectedQuadrant == quadrant ? 0 : 1)
        .onTapGesture {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                selectedQuadrant = quadrant
            }
        }
    }

    // MARK: - Sub-views

    private var totalRemaining: Int {
        counts.values.reduce(0) { $0 + $1.remaining }
    }

    private var header: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Eisenhower Matrix")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                Text(headerSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    private var headerSubtitle: String {
        let date = Date.now.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
        if totalRemaining == 0 {
            return "\(date) · All clear"
        }
        return "\(date) · \(totalRemaining) task\(totalRemaining == 1 ? "" : "s") remaining"
    }

    private func axisLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold, design: .rounded))
            .tracking(1.2)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
    }
}
