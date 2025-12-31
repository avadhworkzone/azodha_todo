# Azodha Flutter Todo App

A Flutter mobile application built as part of the Azodha hiring assignment.  
This app demonstrates clean architecture, BLoC state management, REST API integration, and offline-first behavior using Hive.

---

## Setup Instructions

### Prerequisites
- Flutter SDK (3.38.5)
- Dart SDK
- Android Studio / VS Code
- Emulator or physical device


### App Features

Display list of todos
Add new todo
Mark todo as complete / incomplete
Delete todo
Search todos locally
Pull-to-refresh
Offline access using Hive
Optimistic UI updates
Automatic sync when internet is restored

### Mock login screen
Mock Login Credentials
Email: test@azodha.com
Password: 123456


### Events

LoadTasks
AddTaskEvent
ToggleTaskEvent
DeleteTaskEvent
SearchTaskEvent
SyncPendingTasks


### API Integration

The app integrates with JSONPlaceholder using the following endpoints:

GET /todos – Fetch all todos
POST /todos – Create a new todo
PATCH /todos/:id – Update a todo (mark as complete)
DELETE /todos/:id – Delete a todo


### Offline Support Strategy

Offline support is a key focus of this app.
Local Cache
All tasks are cached using Hive
Cached data is displayed immediately on app launch

### Optimistic Updates

UI updates instantly for add/update/delete actions
No waiting for server responses
Pending Actions Queue
Offline actions are stored with a pendingAction flag:
add
update
delete

### Each task has an isSynced flag to track sync status
Automatic Sync
connectivity_plus listens for network changes
When internet connectivity is restored:
Pending actions are synced with the API
Tasks are marked as synced locally
UI updates automatically
Challenges Faced & Solutions
1. API Data Not Persisting

Challenge: JSONPlaceholder does not persist CRUD changes
Solution: Implemented Hive as the local source of truth with optimistic updates

2. Offline CRUD Operations

Challenge: Managing add/update/delete while offline
Solution: Used a pending actions queue and sync mechanism

3. Connectivity Handling

Challenge: Handling connectivity changes reliably
Solution: Used connectivity_plus stream (v6+) with proper result handling



### Run the App
```bash
git clone <your-github-repo-url>
cd azodha_todo_app
flutter pub get
flutter run
