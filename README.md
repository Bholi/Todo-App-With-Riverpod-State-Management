# Todo App - Flutter + Riverpod

A clean, minimal task management app built with **Flutter** and **Riverpod v3** for state management. Features real-time search, tab-based filtering, swipe-to-delete, and toast notifications.

## Screenshots

<p align="center">
  <img src="screenshots/empty_state.png" width="250" alt="Empty State"/>
  &nbsp;&nbsp;
  <img src="screenshots/add_task.png" width="250" alt="Add Task"/>
  &nbsp;&nbsp;
  <img src="screenshots/all_tasks.png" width="250" alt="All Tasks"/>
</p>

<p align="center">
  <img src="screenshots/active_tab.png" width="250" alt="Active Tab"/>
  &nbsp;&nbsp;
  <img src="screenshots/done_tab.png" width="250" alt="Done Tab"/>
  &nbsp;&nbsp;
  <img src="screenshots/swipe_delete.png" width="250" alt="Swipe to Delete"/>
</p>

> **Note:** Add your screenshots to the `screenshots/` folder with the names above.

## Features

- **Add Tasks** — type and tap the add button or press enter
- **Complete Tasks** — tap the circular checkbox to mark done (with strikethrough)
- **Delete Tasks** — swipe left to dismiss
- **Search** — real-time filtering across all tasks
- **Tab Filtering** — switch between All, Active, and Done views
- **Live Counter** — app bar shows remaining incomplete tasks
- **Toast Notifications** — feedback on add, delete, and empty input via Cherry Toast

## Tech Stack

| Layer | Tool |
|---|---|
| Framework | Flutter 3.x |
| State Management | Riverpod v3 (`Notifier` + `Provider`) |
| Icons | Font Awesome Flutter |
| Notifications | Cherry Toast |

## Project Structure

```
lib/
 ├── main.dart                  # App entry point with ProviderScope
 ├── constants/
 │   └── colors.dart            # App color palette
 ├── model/
 │   └── todo_model.dart        # Todo data model with copyWith
 ├── provider/
 │   └── todo_provider.dart     # Riverpod notifiers and providers
 └── screens/
     └── home_screen.dart       # Main UI (search, tabs, task list)
```

## State Management Architecture

```
todoProvider (NotifierProvider)
 ├── filteredTodosProvider ──── search filter applied
 │    ├── activeTodosProvider ── isCompleted == false
 │    └── doneTodosProvider ──── isCompleted == true
 ├── remainingCountProvider ─── incomplete task count
 └── searchQueryProvider ─────── current search text
```

- `TodoNotifier` manages the core list with `addTodo`, `toggleTodo`, and `deleteTodo`
- Derived providers (`filteredTodos`, `activeTodos`, `doneTodos`) auto-update when the source changes
- Scoped `Consumer` widgets ensure only the affected UI rebuilds

## Getting Started

### Prerequisites

- Flutter SDK `^3.10.7`
- Dart SDK (bundled with Flutter)

### Installation

```bash
# Clone the repository
git clone <your-repo-url>
cd todo_project

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Dependencies

```yaml
flutter_riverpod: ^3.2.1
riverpod: ^3.2.1
font_awesome_flutter: ^10.12.0
cherry_toast: ^1.13.0
dio: ^5.9.1
```

## License

This project is for learning and practice purposes.
