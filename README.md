# Legal Management System (LMS)

A Flutter-based Legal Management System designed to streamline legal operations with role-based access, Firebase integration, and a modern user interface.

## Features

- **Authentication**: Secure email/password authentication with Firebase.
- **Role-Based Access**: Separate dashboards for Administrators and Legal Officers.
- **Firestore Integration**: User data stored in Firestore, including roles and timestamps.
- **Dynamic Theming**: Light and dark mode toggle for a personalized experience.
- **Responsive Design**: Optimized for both web and mobile platforms.

## Project Structure

```
lib/
├── auth/                # Authentication logic (sign-in, add user)
├── services/            # State management (theme, zoom notifier)
├── views/               # UI components
│   ├── home_pages/      # Role-specific dashboards
│   ├── tabs/            # Modular tabs for different functionalities
│   └── users/           # User management views
└── main.dart            # App entry point
```

## Getting Started

### Prerequisites

- Flutter SDK (>=3.7.0)
- Firebase project configured with Authentication and Firestore

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/muchokisw/lms.git
   cd lms
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Configure Firebase:
   - Add `google-services.json` (Android) and `firebase_options.dart` (Web) to the project.

4. Run the app:
   ```bash
   flutter run -d chrome  # For web
   flutter run -d emulator-5554  # For Android
   ```

## Firebase Setup

1. Enable Authentication in Firebase Console.
2. Add Firestore rules to secure user data:
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
     }
   }
   ```
