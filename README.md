# ⚖️ Pocket Court App

Pocket Court App is a mobile-based legal assistance platform designed to provide users with easy access to legal information, laws, categories, and personal legal resources.

The application provides a simple interface where users can explore different laws, browse legal categories, bookmark important legal information, and securely manage their accounts.

The project follows a full-stack architecture with a **Flutter mobile application frontend** and a **Node.js backend API**.

---

# 🚀 Key Highlights

- 📱 Cross-platform mobile application
- ⚖️ Digital legal information platform
- 🔐 Secure user authentication
- 📚 Browse laws and legal categories
- 🔖 Bookmark important laws
- 🌐 REST API based backend
- 🗄️ MongoDB database integration

---

# ✨ Features

## 👤 User Features

- User registration and login
- Secure authentication system
- Browse legal categories
- View detailed law information
- Search legal resources
- Bookmark important laws
- User-friendly mobile interface

---

## ⚖️ Legal Information System

- Law categorization
- Law details management
- Organized legal resources
- Easy access to important information

---

## 🔐 Authentication

- JWT-based authentication
- Password encryption using bcryptjs
- Protected API routes
- User authorization middleware

---

# 🛠️ Technologies Used

## Mobile Application

- Flutter
- Dart

## Backend

- Node.js
- Express.js

## Database

- MongoDB
- Mongoose

## Authentication

- JWT (JSON Web Token)
- bcryptjs

## Development Tools

- Git & GitHub
- REST APIs

---

# 📂 Project Structure

```text
PocketCourtApp/

│
├── pocket-court-backend/
│
│   ├── config/
│   │   └── db.js
│   │
│   ├── controllers/
│   │   ├── authController.js
│   │   ├── bookmarkController.js
│   │   ├── categoryController.js
│   │   └── lawController.js
│   │
│   ├── middleware/
│   │   └── auth.js
│   │
│   ├── models/
│   │   ├── User.js
│   │   ├── Law.js
│   │   └── Category.js
│   │
│   ├── routes/
│   │   ├── authRoutes.js
│   │   ├── bookmarkRoutes.js
│   │   ├── categoryRoutes.js
│   │   └── lawRoutes.js
│   │
│   ├── seed.js
│   ├── server.js
│   ├── package.json
│   └── .env.example
│
├── pocket_court_app/
│
│   ├── lib/
│   │   ├── models/
│   │   ├── screens/
│   │   ├── services/
│   │   ├── theme/
│   │   ├── widgets/
│   │   ├── main.dart
│   │   └── main_navigation.dart
│   │
│   ├── android/
│   ├── ios/
│   ├── web/
│   ├── windows/
│   ├── macos/
│   │
│   ├── pubspec.yaml
│   └── test/
│
├── run.bat
├── start.ps1
└── README.md
```

---

# ⚙️ Installation & Setup

## 1. Clone Repository

```bash
git clone https://github.com/ankita12365/PocketCourtApp.git
```

Navigate into project:

```bash
cd PocketCourtApp
```

---

# 🔙 Backend Setup

Go to backend folder:

```bash
cd pocket-court-backend
```

Install dependencies:

```bash
npm install
```

Create `.env` file:

```env
MONGO_URI=your_mongodb_connection
JWT_SECRET=your_secret_key
PORT=5000
```

Start backend server:

```bash
npm start
```

---

# 📱 Flutter App Setup

Go to Flutter project:

```bash
cd pocket_court_app
```

Install packages:

```bash
flutter pub get
```

Run application:

```bash
flutter run
```

---

# 🧠 How It Works

1. User creates an account
2. Authentication is handled securely using JWT
3. User browses legal categories and laws
4. Backend provides legal data through REST APIs
5. Users can bookmark useful legal information
6. MongoDB stores application data

---

# 🎯 Project Objectives

- Make legal information easily accessible
- Provide a simple digital legal resource platform
- Demonstrate full-stack mobile application development
- Implement secure authentication and database management

---

# 🔮 Future Improvements

- AI-powered legal assistant chatbot
- Voice-based legal search
- Lawyer consultation feature
- Real-time legal updates
- Multi-language support
- Online appointment booking

---

# 👩‍💻 Developer

**Ankita Nitin Chavan**

GitHub:  
https://github.com/ankita12365

---

⭐ A full-stack legal technology solution built using Flutter, Node.js, Express, and MongoDB.
