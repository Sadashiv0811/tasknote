# TaskNote

**TaskNote** is a productivity-focused notes application built with Flutter for creating, organizing, protecting, and managing personal notes and checklists.

It combines local data storage with Firebase cloud backup, reminders, note sharing, folder organization, and password-protected notes with recovery support. The application is designed to provide a reliable workspace for managing both simple notes and actionable checklist-based information.

---

## ✨ Features

### 📝 Notes

- Create, edit, and delete notes.
- Create both **Text Notes** and **Checklist Notes**.
- Prevent duplicate note titles.
- Pin notes and display relevant reminder information.
- Automatically save notes when:
  - Saving manually.
  - Navigating back.
  - The application moves to the background.
- Display created and last-updated timestamps.
- Search notes by title.
- Sort notes by:
  - Created date
  - Last updated
  - Alphabetical order
- Switch between multiple note layouts:
  - Small Grid
  - Large Grid
  - List
  - Title
- Select multiple notes for batch operations.
- Share individual notes.
- Move notes into folders.
- Delete notes along with their associated reminders.

### ☑️ Checklists

- Create and manage checklist-based notes.
- Add multiple checklist items continuously.
- Insert items at the beginning or end of a checklist.
- Edit existing checklist items.
- Delete individual checklist items.
- Reorder checklist items using drag and drop.
- Enable or disable checklist items.
- Copy individual checklist items to the clipboard.
- Display formatted checklists when viewing, sharing, or using reminders.

### 📁 Folders

- Create and manage folders for organizing notes.
- Prevent duplicate folder names.
- Add notes to new or existing folders.
- Remove individual notes from folders.
- Delete individual notes from folders.
- Delete folders while:
  - Keeping their notes.
  - Deleting their notes.
- Search folders by title.
- Sort folders by creation date, last updated date, or alphabetically.
- Display the number of notes contained in each folder.
- Display password-protected note counts within folders.

### 🔔 Reminders & Notifications

TaskNote provides reminder functionality for both regular and checklist notes.

- Create scheduled reminders for notes.
- Pin reminders to the notification/status area.
- Allow one reminder per note.
- Prevent duplicate reminders.
- Automatically update the UI when reminders are created or cancelled.
- Automatically cancel reminders when their associated notes are deleted.
- Remove reminder data when a reminder is cancelled.
- Reschedule valid reminders when the application starts.
- Automatically remove expired reminders.
- Display checklist content in notifications.
- Handle notification permissions for different Android versions.

Reminder data is maintained locally and is not included in Firebase backup/import operations.

### 🔐 Password-Protected Notes

TaskNote provides a dedicated security system for protecting sensitive notes.

- Protect individual notes with a master password.
- View protected notes through a dedicated protected-notes section.
- Support both regular and checklist notes.
- Authenticate before accessing protected notes.
- Select and remove multiple protected notes.
- Sort protected notes by last updated date.
- Prevent sharing of protected notes.
- Prevent reminders from being created for protected notes.
- Provide password recovery using a Recovery Key.
- Allow users to change their password through the recovery process.
- Display the Recovery Key only once after initial security setup.
- Provide clipboard support for copying the Recovery Key.

The security implementation uses a generated master encryption key and separate password/recovery-key protection mechanisms.

### 🔑 Password Recovery

TaskNote includes a recovery mechanism for password-protected notes.

- Generate a unique Recovery Key during initial security setup.
- Use a structured Recovery Key format:

`XXXX-XXXX-XXXX-XXXX-XXXX`

- Validate the Recovery Key before allowing password recovery.
- Allow users to reset their password using the Recovery Key.
- Display the Recovery Key only once.
- Encourage users to store their Recovery Key and password securely.

### ☁️ Cloud Backup & Data Sync

TaskNote supports Firebase-based backup and restoration of user data.

- Backup notes and folders to Firebase.
- Import notes and folders from Firebase.
- Avoid duplicate cloud data during backup.
- Avoid duplicate local data during import.
- Merge cloud data with existing local data.
- Check for existing cloud data after user login.
- Keep local and cloud note/folder data synchronized.
- Clear both local and cloud data when requested by the user.

Firestore batch operations are handled through a dedicated `FirestoreBatchHelper` to work around Firestore's batch write operation limits.

### 📤 Sharing

Notes can be shared in multiple formats.

- Share notes as plain text.
- Generate and share notes as PDF.
- Share checklist notes with their formatted checklist content.
- Preview generated PDFs before sharing.
- Edit PDF text before sharing.

Password-protected notes cannot be shared.

### 🔍 Search, Sorting & Organization

TaskNote provides multiple ways to quickly find and organize information.

- Search notes by title.
- Search folders by title.
- Sort notes by creation date, last updated date, alphabetically.
- Switch between different note layouts.
- View notes associated with a particular date.
- Organize notes into folders.
- Select multiple items for batch operations.

### 📅 Calendar

The calendar provides a date-oriented way to access notes.

- View notes associated with a selected date.
- Display notes sorted by last updated date.
- Add notes directly from a selected date.
- Create either text or checklist notes from the calendar.
- View notes associated with a specific date.
- Edit notes directly from the calendar.
- Perform note selection and deletion.
- Share notes and manage reminders from the calendar.

### 👤 Authentication & User Management

TaskNote supports authenticated and guest usage.

- Email/password authentication.
- Google account authentication.
- User profile information.
- Login and logout.
- Confirmation before logout.
- Guest user support.
- Display user name and email for authenticated users.
- Clear local data when logging out.

### 💾 Local Data Management

TaskNote maintains application data locally to provide fast and reliable access.

- Local note, folder, reminder storage.
- Local protected-note data.
- Local/cloud data merging.
- Clear local data independently.
- Clear local and cloud data together.
- Automatically update the UI after data operations.

### 🎨 User Experience

- Light and dark theme support.
- Confirmation dialogs for destructive operations.
- Input validation with user-friendly error messages.
- Dynamic UI based on selection state.
- Automatic UI updates when notes or reminders change.
- Empty-state handling.
- Notification permission handling.
- Automatic initialization of required controllers and local database services.

---

### Firebase Authentication

- Email/password authentication.
- Google authentication.

Firebase App Check is also implemented to add an additional layer of protection for Firebase resources.

---

### Main Technologies

- **Flutter**
- **Dart**
- **MVC**
- **Isar**
- **Firebase**
- **Cloud Firestore**
- **Firebase Authentication**

## 🗄️ Data Storage

TaskNote follows a local-first approach.

```text
                    ┌─────────────────┐
                    │    TaskNote     │
                    └────────┬────────┘
                             │
                ┌────────────┴────────────┐
                │                         │
        ┌───────▼───────┐         ┌───────▼───────┐
        │     Isar      │         │    Firebase   │
        │ Local Storage │◄───────►│ Cloud Storage │
        └───────────────┘         └───────────────┘
```

Local storage is used for normal application operations, while Firebase provides cloud backup and restoration.

This allows the application to work with locally available data while still providing cloud-based data protection and synchronization.

---

## 📄 PDF & Export

TaskNote includes PDF functionality for sharing notes.

- Convert notes into PDF documents.
- Support formatted checklist content.
- Preview generated PDFs.
- Edit PDF text before sharing.
- Share generated PDFs with other applications.

---

## 🔔 Notification Handling

TaskNote manages scheduled notifications locally.

The application:

1. Creates a local reminder.
2. Stores the reminder information locally.
3. Schedules the notification.
4. Displays the reminder in the UI.
5. Reschedules valid reminders when the app starts.
6. Removes reminders whose scheduled time has passed.
7. Removes the reminder when its associated note is deleted.

---

## 🧩 Project Highlights

TaskNote demonstrates several practical Flutter development concepts:

- Flutter application architecture.
- Local-first application design.
- Isar database integration.
- Firebase Authentication.
- Cloud Firestore integration.
- Firestore batch operation handling.
- Firebase App Check.
- Local notification scheduling.
- AES-based data encryption.
- Password-based key derivation.
- Recovery-key-based password recovery.
- PDF generation and preview.
- Text and checklist data management.
- Local/cloud data synchronization.
- Background save handling.
- Dynamic UI state management.
- Android notification permission handling.

---

## 🎯 Purpose of the Project

TaskNote was developed as a practical Flutter application demonstrating how multiple real-world application requirements can be combined into a single project.

The project focuses on:

- Productivity.
- Data organization.
- Offline/local data management.
- Cloud backup.
- Secure note storage.
- Reminder management.
- Rich note sharing.
- Scalable Flutter architecture.

---

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform application development |
| Dart | Programming language |
| Isar | Local database |
| Firebase Authentication | User authentication |
| Cloud Firestore | Cloud storage and synchronization |
| Firebase App Check | Firebase resource protection |
| Local Notifications | Reminder scheduling |
| AES Encryption | Protected note encryption |
| PDF | Note export and sharing |

---

## 📌 Summary

**TaskNote** is a feature-rich productivity application that combines note-taking, checklists, folders, reminders, secure notes, cloud backup, authentication, and PDF sharing in a single Flutter application.