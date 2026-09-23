# 📝 TaskNote

**TaskNote** is a productivity-focused Flutter application for creating, organizing, protecting and managing personal notes and checklists.

It follows a **local-first approach** using Isar for local storage with Firebase for authentication, cloud backup and synchronization.

## ✨ Features

### 📝 Notes
- Create, edit and delete text and checklist notes
- Prevent duplicate note titles
- Pin and search notes
- Sort by created date, updated date or title
- Multiple layouts: Grid, List and Title
- Auto-save on manual save, navigation and app backgrounding
- Batch note selection and deletion
- Move notes into folders
- Share notes as text or PDF

### ☑️ Checklists
- Create and manage checklist notes
- Add, edit and delete checklist items
- Reorder items using drag and drop
- Enable/disable checklist items
- Copy individual items
- Formatted checklist content for sharing and reminders

### 📁 Folders
- Create and manage folders
- Prevent duplicate folder names
- Add or remove notes from folders
- Search and sort folders
- Display note and protected-note counts
- Delete folders while keeping or deleting their notes

### 🔔 Reminders
- Schedule one reminder per note
- Local notification scheduling
- Persistent/pinned notifications
- Automatic reminder cleanup and rescheduling
- Checklist content in notifications
- Automatic cancellation when notes are deleted
- Android notification permission handling

### 🔐 Password-Protected Notes
- Protect individual notes with encryption
- Dedicated protected-notes section
- Support text and checklist notes
- Password authentication
- Prevent sharing and reminders for protected notes
- AES-based note encryption
- Recovery Key-based password recovery
- Change password through recovery
- Recovery Key displayed only once

**Recovery Key format:**
```text
XXXX-XXXX-XXXX-XXXX-XXXX
```

### ☁️ Firebase Backup & Sync
- Firebase Authentication with Email/Password and Google
- Cloud Firestore backup and restore
- Local/cloud data merging
- Duplicate prevention during backup and import
- Firebase App Check
- Firestore batch operations through a dedicated helper
- Option to clear local and cloud data

### 📅 Calendar
- View notes by date
- Create notes from selected dates
- Edit, delete and share notes
- Manage reminders
- Sort notes by last updated date

### 📤 PDF & Sharing
- Export notes as PDF
- Support formatted checklists
- Preview generated PDFs
- Edit PDF text before sharing
- Share notes with other applications

### 🎨 UI & UX
- Light and dark themes
- Input validation
- Confirmation dialogs
- Dynamic selection-based UI
- Empty states
- Automatic UI updates

## 🗄️ Architecture & Data Storage

TaskNote uses a **local-first architecture**:

```text
                   ┌─────────────────┐
                   │    TaskNote     │
                   └────────┬────────┘
                            │
               ┌────────────┴────────────┐
               │                         │
       ┌───────▼───────┐         ┌───────▼───────┐
       │     Isar      │◄───────►│    Firebase   │
       │ Local Storage │         │ Cloud Backup  │
       └───────────────┘         └───────────────┘
```

**Isar** handles local application data while **Firebase/Firestore** provides cloud backup and synchronization.

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform application development |
| Dart | Programming language |
| Isar | Local database |
| Firebase Authentication | User authentication |
| Cloud Firestore | Cloud backup and synchronization |
| Firebase App Check | Firebase resource protection |
| Local Notifications | Reminder scheduling |
| AES Encryption | Protected note encryption |
| PDF | Note export and sharing |

## 🚀 Project Highlights

- Local-first application design
- Flutter application architecture
- Isar database integration
- Firebase Authentication and Firestore
- Firebase App Check
- Local notification scheduling
- AES-based encryption
- Password and Recovery Key security
- Local/cloud data synchronization
- PDF generation and sharing
- Text and checklist management
- Background auto-save handling
- Android notification permission management

## 🎯 Purpose

TaskNote was developed as a practical Flutter project demonstrating real-world concepts including **offline data management, cloud backup, authentication, encryption, reminders, PDF generation and scalable application architecture**.