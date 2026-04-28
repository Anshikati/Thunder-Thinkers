# 🌟 NeedsBridge (Thunder-Thinkers)
### *Bridging the Gap in Disaster Relief with AI-Powered Intelligence*

[![Google Solution Challenge 2024](https://img.shields.io/badge/Google-Solution%20Challenge%202024-blue?style=for-the-badge&logo=google)](https://developers.google.com/community/gdsc-solution-challenge)
[![Flutter](https://img.shields.io/badge/Built%20with-Flutter-02569B?style=for-the-badge&logo=flutter)](https://flutter.dev)
[![Gemini AI](https://img.shields.io/badge/Powered%20by-Gemini%20AI-8E75B2?style=for-the-badge&logo=google-gemini)](https://deepmind.google/technologies/gemini/)

---

[Click here to see Demo](https://appetize.io/app/b_ubnqo6jmckhejavuvwf6x7m3sa)
## 📌 The Problem
During disasters, communication breakdown is the biggest hurdle. Field workers often have to fill out complex forms manually, while victims' needs are lost in the chaos. Data is slow, inaccurate, and often unstructured.

## 🚀 The Solution: NeedsBridge
**NeedsBridge** is a comprehensive disaster relief management platform designed to streamline aid distribution using cutting-edge AI. We empower field workers to report needs via **Voice** and **Image Scanning**, providing real-time data visualization for NGOs and volunteers.

---

## ✨ Key Features

### 🎙️ AI Voice Reporting
Field workers can simply speak about the situation. Our app uses **Real-time Speech-to-Text** and **Smart Natural Language Processing (NLP)** to automatically extract:
- **Category** (Food, Medical, Shelter, etc.)
- **Urgency Level**
- **Number of People Affected**
- **Location Details**

### 📄 Intelligent Form Scanner
Have a paper record? Just take a photo. NeedsBridge uses **On-Device OCR (ML Kit)** to read the text and our custom **Smart Parser** to structure the data instantly—even without an internet connection.

### 📍 Live Relief Mapping
A high-performance mapping interface powered by **Google Maps API** that shows real-time "Need Clusters," allowing NGOs to prioritize high-urgency zones and deploy resources efficiently.

### 🤝 Multi-Role Dashboard
- **NGO Admins:** Full overview of global needs and resource allocation.
- **Volunteers:** Find nearby tasks and help victims in real-time.

---

## 🛠️ Tech Stack
- **Frontend:** Flutter (Dart)
- **Backend:** Firebase (Auth, Firestore, Storage)
- **AI/ML:** Google Gemini AI, Google ML Kit (OCR), Speech-to-Text
- **Maps:** Google Maps API
- **Animations:** AnimateDo & Lottie

---

## ⚙️ Setup Instructions

### 1. Prerequisites
- Flutter SDK installed
- A Firebase project configured

### 2. API Keys Setup
For security, API keys are redacted. Create a file at `lib/config/api_keys.dart` and add your keys:
```dart
class ApiKeys {
  static const String geminiApiKey = 'YOUR_GEMINI_KEY';
  static const String googleMapsApiKey = 'YOUR_MAPS_KEY';
}
```

### 3. Run the Project
```bash
flutter pub get
flutter run
```

---

## 🏆 Google Solution Challenge 2024
This project was built by **Team Thunder-Thinkers** for the Google Solution Challenge. Our mission is to leverage technology to ensure that in times of crisis, no one is left behind.

---

## 👨‍💻 Developed By
- **Team Thunder-Thinkers** 

---
<p align="center">Made with ❤️ for a better world</p>
