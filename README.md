# rkrkj7 TweetX 🐦

A **minimal Twitter clone built with Flutter & Firebase**.
TweetX lets users share thoughts, connect with others, and explore timelines — a lightweight yet feature-rich project to practice Flutter + Firebase integration.

---

## ✨ Features

- 🔑 **User Authentication**
- 📝 **Post Tweets**
- ❤️ **Like & Delete Tweets**
- 💬 **Comment on Tweets**
- 🔍 **Search Users**
- ➕ **Follow / Unfollow Users**
- 🌓 **Toggle Dark Mode**

---

## 🚀 Tech Stack

- **Frontend:** Flutter (Dart)
- **Backend & Services:** Firebase

  - Firebase Authentication
  - Cloud Firestore
  - Firebase Storage (for profile pics / media)
  - Firebase Hosting (optional for web build)

---

## 📦 Installation & Setup

Clone the repository:

```bash
git clone https://github.com/your-username/rkrkj7-tweetx.git
cd rkrkj7-tweetx
```

Install dependencies:

```bash
flutter pub get
```

Set up Firebase:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Enable **Authentication** (Email/Password, Google Sign-In, etc.)
4. Enable **Cloud Firestore**
5. Enable **Firebase Storage** (for images, if used)
6. Add your Flutter apps (iOS, Android, Web) and download `google-services.json` / `GoogleService-Info.plist`
7. Place them in the respective `android/app/` and `ios/Runner/` directories

Run the app:

```bash
flutter run
```

---

💡 Built with ❤️ using **Flutter & Firebase** by **rkrkj7**
