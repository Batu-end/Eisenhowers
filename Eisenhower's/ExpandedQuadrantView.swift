import SwiftUI
import SwiftData

struct ExpandedQuadrantView: View {
    let quadrant: Quadrant
    var namespace: Namespace.ID
    let onClose: () -> Void

    @Query var tasks: [TodoItem]
    @Environment(\.modelContext) private var modelContext

    @State private var newTaskTitle = ""
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
        // System background for the content area — keeps it readable and native.
        // The colored header band above provides continuity with the card animation.
        .background(Color(.systemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .matchedGeometryEffect(id: quadrant.rawValue, in: namespace)
        .ignoresSafeArea(edges: .bottom)
    }

    // MARK: - Header

    // Compact colored band — mirrors the card's color so the hero expansion
    // feels continuous. Everything below this uses the system background.
    private var headerBand: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.25))
                    .frame(width: 38, height: 38)
                Image(systemName: quadrant.icon)
                    .font(.footnote.bold())
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(quadrant.title)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                Text(quadrant.subtitle.replacingOccurrences(of: "\n", with: " · "))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.78))
            }

            Spacer()

            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 56)
        .padding(.bottom, 18)
        .background(quadrant.color)
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

            // Submit arrow appears only when there is text
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
                    // Indent separator to align with the text, not the checkbox
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
            // Reminders-style circle checkbox
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
