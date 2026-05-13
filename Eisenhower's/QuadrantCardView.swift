import SwiftUI

struct QuadrantCardView: View {
    let quadrant: Quadrant
    let remaining: Int
    let total: Int
    var namespace: Namespace.ID

    private var completed: Int { total - remaining }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Gradient background
            LinearGradient(
                colors: [quadrant.color, quadrant.color.opacity(0.72)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Watermark icon — vertically centered in the card
            Image(systemName: quadrant.icon)
                .font(.system(size: 96, weight: .heavy))
                .foregroundStyle(.white.opacity(0.1))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

            // Foreground content
            VStack(alignment: .leading, spacing: 0) {

                // ── Top: title + badge ────────────────────────────────
                HStack(alignment: .firstTextBaseline) {
                    Text(quadrant.title)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Spacer()

                    if remaining > 0 {
                        Text("\(remaining) left")
                            .font(.caption.bold())
                            .foregroundStyle(quadrant.color)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(.white, in: Capsule())
                    } else if total > 0 {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.75))
                    }
                }

                Spacer()

                // ── Bottom: 2-line subtitle + optional progress bar ───
                Text(quadrant.subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.68))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                if total > 0 {
                    progressBar
                        .padding(.top, 10)
                }
            }
            .padding(18)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .matchedGeometryEffect(id: quadrant.rawValue, in: namespace)
    }

    private var progressBar: some View {
        VStack(alignment: .leading, spacing: 5) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.22))
                    Capsule()
                        .fill(.white.opacity(0.85))
                        .frame(width: geo.size.width * CGFloat(completed) / CGFloat(total))
                        .animation(.spring(response: 0.4), value: completed)
                }
            }
            .frame(height: 4)

            Text("\(completed) of \(total) done")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.60))
                .monospacedDigit()
        }
    }
}
