# Todo App - Flutter + Riverpod

A clean, minimal task management app built with **Flutter** and **Riverpod v3** for state management. Features persistent local storage with **sqflite**, real-time search, tab-based filtering, swipe-to-delete, and toast notifications.

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

- **Persistent Storage** — todos are saved locally using SQLite and survive app restarts
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
| State Management | Riverpod v3 (`AsyncNotifier` + `Provider`) |
| Local Database | sqflite (SQLite) |
| Icons | Font Awesome Flutter |
| Notifications | Cherry Toast |

## Project Structure

```
lib/
 ├── main.dart                  # App entry point with ProviderScope
 ├── constants/
 │   └── colors.dart            # App color palette
 ├── model/
 │   └── todo_model.dart        # Todo data model with copyWith, toMap, fromMap
 ├── provider/
 │   └── todo_provider.dart     # DatabaseHelper, Riverpod notifiers and providers
 └── screens/
     └── home_screen.dart       # Main UI (search, tabs, task list)
```

## State Management Architecture

```
              SQLite (todos.db)
                    │
                    ▼
todoProvider (AsyncNotifierProvider)
 ├── filteredTodosProvider ──── search filter applied
 │    ├── activeTodosProvider ── isCompleted == false
 │    └── doneTodosProvider ──── isCompleted == true
 ├── remainingCountProvider ─── incomplete task count
 └── searchQueryProvider ─────── current search text
```

- `DatabaseHelper` — singleton that handles all SQLite CRUD operations
- `TodoNotifier` (AsyncNotifier) — loads todos from DB on startup, persists every add/toggle/delete
- Derived providers (`filteredTodos`, `activeTodos`, `doneTodos`) auto-update when the source changes
- Scoped `Consumer` widgets ensure only the affected UI rebuilds

## Database Schema

```sql
CREATE TABLE todos(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  isCompleted INTEGER NOT NULL DEFAULT 0
)
```

`isCompleted` uses `INTEGER` (0/1) since SQLite has no native boolean type.

## Getting Started

### Prerequisites

- Flutter SDK `^3.10.7`
- Dart SDK (bundled with Flutter)

### Installation

```bash
# Clone the repository
git clone https://github.com/Bholi/Todo-App-With-Riverpod-State-Management.git
cd Todo-App-With-Riverpod-State-Management

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Dependencies

```yaml
flutter_riverpod: ^3.2.1
riverpod: ^3.2.1
sqflite: ^2.4.2
path: ^1.9.0
font_awesome_flutter: ^10.12.0
cherry_toast: ^1.13.0
dio: ^5.9.1
```

## License

This project is for learning and practice purposes.
