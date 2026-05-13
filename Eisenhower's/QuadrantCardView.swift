import SwiftUI

struct QuadrantCardView: View {
    let quadrant: Quadrant
    let remaining: Int
    let total: Int
    var namespace: Namespace.ID

    private var completed: Int { total - remaining }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Dark background
            Color(white: 0.09)

            // Watermark — color-tinted, centered
            Image(systemName: quadrant.icon)
                .font(.system(size: 96, weight: .heavy))
                .foregroundStyle(quadrant.color.opacity(0.18))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

            VStack(alignment: .leading, spacing: 0) {

                // ── Title ─────────────────────────────────────────────
                Text(quadrant.title)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                // ── Badge on its own line, below the title ─────────────
                if remaining > 0 {
                    Text("\(remaining) left")
                        .font(.caption.bold())
                        .foregroundStyle(quadrant.color)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(quadrant.color.opacity(0.14), in: Capsule())
                        .padding(.top, 5)
                } else if total > 0 {
                    Label("All done", systemImage: "checkmark.circle.fill")
                        .font(.caption.bold())
                        .foregroundStyle(quadrant.color)
                        .padding(.top, 5)
                }

                Spacer()

                // ── Subtitle (2 lines) ─────────────────────────────────
                Text(quadrant.subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.42))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                if total > 0 {
                    progressBar.padding(.top, 10)
                }
            }
            .padding(18)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        // Color accent lives on the border, not the fill
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(quadrant.color.opacity(0.55), lineWidth: 1.5)
        )
        .matchedGeometryEffect(id: quadrant.rawValue, in: namespace)
    }

    private var progressBar: some View {
        VStack(alignment: .leading, spacing: 5) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.1))
                    Capsule()
                        .fill(quadrant.color)
                        .frame(width: geo.size.width * CGFloat(completed) / CGFloat(total))
                        .animation(.spring(response: 0.4), value: completed)
                }
            }
            .frame(height: 4)

            Text("\(completed) of \(total) done")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.38))
                .monospacedDigit()
        }
    }
}
