

---

# BuzzIn Flutter App

A lightweight Flutter app built for a coding project submission. This repository contains the core app logic (`lib/`) and `pubspec.yaml` to get it up and running quickly. The app also integrates with Firebase for backend services.

## 🚀 How to Run

1. **Create a new Flutter project**

   ```bash
   flutter create buzzin
   ```

2. **Replace files**

   * Copy the `lib/` folder from this repo into the new project.
   * Replace `pubspec.yaml` with the one provided here.
   * Overwrite if prompted.

3. *(Optional)* Rename folder if needed:

   ```bash
   mv buzzin your_app_name
   cd your_app_name
   ```

4. **Set up Firebase**

   * Go to the [Firebase Console](https://console.firebase.google.com/).
   * Create a new Firebase project.
   * Add your Android/iOS app to Firebase.
   * Download the `google-services.json` (for Android) or `GoogleService-Info.plist` (for iOS) and place it in the appropriate directory (`android/app` for Android or `ios/Runner` for iOS).
   * Follow the official Firebase setup guide to enable the required services (like Firestore, Firebase Auth, etc.).

5. **Install Firebase dependencies**
   In the `pubspec.yaml`, make sure to include the necessary Firebase packages:

   ```yaml
   dependencies:
     firebase_core: ^1.10.0
     firebase_auth: ^3.3.4
     cloud_firestore: ^3.1.5
   ```

6. **Get dependencies**

   ```bash
   flutter pub get
   ```

7. **Run the app**

   ```bash
   flutter run
   ```

## 🛠 Tech Stack

* **Flutter**
* **Dart**
* **Firebase** (Firebase Auth, Firestore, etc.)

---

