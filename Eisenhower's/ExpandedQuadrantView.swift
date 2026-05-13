import SwiftUI
import SwiftData

struct ExpandedQuadrantView: View {
    let quadrant: Quadrant
    var namespace: Namespace.ID
    let onClose: () -> Void

    @Query var tasks: [TodoItem]
    @Environment(\.modelContext) private var modelContext

    @State private var newTaskTitle = ""
    @State private var dragOffset: CGFloat = 0
    @FocusState private var inputFocused: Bool

    init(quadrant: Quadrant, namespace: Namespace.ID, onClose: @escaping () -> Void) {
        self.quadrant  = quadrant
        self.namespace = namespace
        self.onClose   = onClose
        let raw = quadrant.rawValue
        _tasks = Query(
            filter: #Predicate<TodoItem> { $0.quadrantRaw == raw },
            sort:   [SortDescriptor(\.title)]
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            headerBand
            addTaskRow
            Divider()
            taskList
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(.systemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .matchedGeometryEffect(id: quadrant.rawValue, in: namespace)
        // All edges: gives matchedGeometryEffect a consistent full-screen
        // destination frame regardless of which card (top or bottom) was tapped.
        .ignoresSafeArea()
        // Force dark appearance so system colors (label, separator, etc.)
        // all resolve to their dark-mode variants without manual hex values.
        .environment(\.colorScheme, .dark)
        .offset(y: max(0, dragOffset))
        .opacity(dragOffset > 0 ? max(0.7, 1 - dragOffset / 600) : 1)
    }

    // MARK: - Header

    // Gesture lives here only so it doesn't fight the list's scroll recogniser.
    private var headerBand: some View {
        VStack(spacing: 0) {
            // Drag handle pill
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color(.tertiaryLabel))
                .frame(width: 36, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 6)

            HStack(spacing: 14) {
                // Solid color circle — only accent in the dark header
                ZStack {
                    Circle()
                        .fill(quadrant.color)
                        .frame(width: 38, height: 38)
                    Image(systemName: quadrant.icon)
                        .font(.footnote.bold())
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(quadrant.title)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundStyle(.primary)
                    Text(quadrant.subtitle.replacingOccurrences(of: "\n", with: " · "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 18)
        }
        // Extra top padding absorbs the status bar area (ignoresSafeArea goes
        // all-edges, so content starts behind the status bar without this).
        .padding(.top, 58)
        .background(Color(.secondarySystemBackground))
        .gesture(
            DragGesture(minimumDistance: 12)
                .onChanged { value in
                    // Resistance: feel slightly heavier than a free drag
                    guard value.translation.height > 0 else { return }
                    dragOffset = value.translation.height * 0.65
                }
                .onEnded { value in
                    let fastFlick = value.predictedEndTranslation.height > 300
                    let farEnough = value.translation.height > 110
                    if fastFlick || farEnough {
                        onClose()
                    } else {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            dragOffset = 0
                        }
                    }
                }
        )
    }

    // MARK: - Add task

    private var addTaskRow: some View {
        HStack(spacing: 14) {
            Image(systemName: "plus.circle.fill")
                .font(.title3)
                .foregroundStyle(quadrant.color)

            TextField("New task", text: $newTaskTitle)
                .font(.body)
                .focused($inputFocused)
                .submitLabel(.done)
                .onSubmit { addTask() }

            if !newTaskTitle.isEmpty {
                Button(action: addTask) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title3)
                        .foregroundStyle(quadrant.color)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color(.systemBackground))
        .animation(.spring(response: 0.25), value: newTaskTitle.isEmpty)
    }

    // MARK: - Task list

    private var taskList: some View {
        List {
            ForEach(tasks) { task in
                TaskRowView(task: task, color: quadrant.color)
                    .listRowBackground(Color(.systemBackground))
                    .listRowSeparatorTint(Color(.separator).opacity(0.6))
                    .alignmentGuide(.listRowSeparatorLeading) { _ in 54 }
            }
            .onDelete { indexSet in
                for i in indexSet { modelContext.delete(tasks[i]) }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    // MARK: - Actions

    private func addTask() {
        let trimmed = newTaskTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        modelContext.insert(TodoItem(title: trimmed, quadrant: quadrant))
        newTaskTitle = ""
        inputFocused = false
    }
}

// MARK: - Task row

struct TaskRowView: View {
    @Bindable var task: TodoItem
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) {
                    task.isCompleted.toggle()
                }
            } label: {
                ZStack {
                    Circle()
                        .strokeBorder(
                            task.isCompleted ? color : color.opacity(0.45),
                            lineWidth: 2
                        )
                        .frame(width: 26, height: 26)

                    if task.isCompleted {
                        Circle()
                            .fill(color)
                            .frame(width: 26, height: 26)
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .animation(.spring(response: 0.25), value: task.isCompleted)
            }
            .buttonStyle(.plain)

            Text(task.title)
                .font(.body)
                .foregroundStyle(task.isCompleted ? Color(.tertiaryLabel) : Color(.label))
                .strikethrough(task.isCompleted, color: Color(.tertiaryLabel))
                .animation(.easeOut(duration: 0.15), value: task.isCompleted)
        }
        .padding(.vertical, 5)
    }
}
