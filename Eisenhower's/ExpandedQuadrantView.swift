import SwiftUI
import SwiftData

// Full-screen view for one quadrant.
// Uses a custom @Query initialiser so the predicate can be built from the
// quadrant value passed in at runtime.
struct ExpandedQuadrantView: View {
    let quadrant: Quadrant
    var namespace: Namespace.ID
    let onClose: () -> Void

    // Dynamic SwiftData query: filter by the quadrant's raw string value.
    @Query var tasks: [TodoItem]
    @Environment(\.modelContext) private var modelContext

    @State private var newTaskTitle = ""
    @FocusState private var inputFocused: Bool

    init(quadrant: Quadrant, namespace: Namespace.ID, onClose: @escaping () -> Void) {
        self.quadrant  = quadrant
        self.namespace = namespace
        self.onClose   = onClose

        // Build the predicate here so @Query can be initialised with a
        // value known at init time rather than a generic "all tasks".
        let raw = quadrant.rawValue
        _tasks = Query(
            filter: #Predicate<TodoItem> { $0.quadrantRaw == raw },
            sort:   [SortDescriptor(\.title)]
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            headerBar
            addTaskBar
            taskList
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(quadrant.color)
        // matchedGeometryEffect with the same id as the corresponding
        // QuadrantCardView causes SwiftUI to animate the frame from the
        // card's position/size to this full-screen position/size (and back).
        .matchedGeometryEffect(id: quadrant.rawValue, in: namespace)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .ignoresSafeArea(edges: .bottom)
    }

    // MARK: - Sub-views

    private var headerBar: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Label(quadrant.title, systemImage: quadrant.icon)
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                Text(quadrant.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.75))
            }

            Spacer()

            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .padding(.horizontal)
        .padding(.top, 56)   // clears the status bar
        .padding(.bottom, 16)
    }

    private var addTaskBar: some View {
        HStack(spacing: 10) {
            TextField("New task…", text: $newTaskTitle)
                .padding(12)
                .background(.white.opacity(0.2), in: RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(.white)
                .tint(.white)
                .focused($inputFocused)
                .submitLabel(.done)
                .onSubmit { addTask() }

            Button(action: addTask) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
            }
            .disabled(newTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal)
        .padding(.bottom, 12)
    }

    private var taskList: some View {
        List {
            ForEach(tasks) { task in
                TaskRowView(task: task)
                    .listRowBackground(Color.white.opacity(0.12))
                    .listRowSeparatorTint(.white.opacity(0.2))
            }
            .onDelete { indexSet in
                for index in indexSet {
                    modelContext.delete(tasks[index])
                }
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

    var body: some View {
        HStack(spacing: 14) {
            // Completion toggle
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    task.isCompleted.toggle()
                }
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(task.isCompleted ? 0.6 : 0.9))
            }
            .buttonStyle(.plain)

            Text(task.title)
                .foregroundStyle(.white.opacity(task.isCompleted ? 0.45 : 1.0))
                .strikethrough(task.isCompleted, color: .white.opacity(0.45))
                .animation(.easeInOut(duration: 0.2), value: task.isCompleted)
        }
        .padding(.vertical, 6)
    }
}
