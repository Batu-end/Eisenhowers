import SwiftUI

// A single card in the 2x2 grid.
// The outer VStack receives the matchedGeometryEffect so the entire card
// (background + text) participates in the hero animation.
struct QuadrantCardView: View {
    let quadrant: Quadrant
    let taskCount: Int
    var namespace: Namespace.ID

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top row: icon + optional badge
            HStack(alignment: .top) {
                Image(systemName: quadrant.icon)
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.9))

                Spacer()

                if taskCount > 0 {
                    Text("\(taskCount)")
                        .font(.caption.bold())
                        .foregroundStyle(quadrant.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.white.opacity(0.92), in: Capsule())
                }
            }

            Spacer()

            // Bottom: title + subtitle
            Text(quadrant.title)
                .font(.title2.bold())
                .foregroundStyle(.white)

            Text(quadrant.subtitle)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.75))
                .lineLimit(2)
                .padding(.top, 2)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .frame(height: 160)
        .background(quadrant.color, in: RoundedRectangle(cornerRadius: 22))
        // matchedGeometryEffect links this card to the ExpandedQuadrantView
        // that shares the same id and namespace.
        .matchedGeometryEffect(id: quadrant.rawValue, in: namespace)
    }
}
