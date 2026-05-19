<p align="center">
  <img src="https://raw.githubusercontent.com/md-rounaq-ali/VoxCalc/main/assets/icon/app_icon.png" alt="VoxCalc Logo" width="120" height="120" style="border-radius: 24px; box-shadow: 0px 8px 16px rgba(0, 0, 0, 0.35);"/>
</p>

<h1 align="center">VOXCALC - Next-Gen Math Suite</h1>

<p align="center">
  <strong>A Next-Generation Computational Workspace Powering On-Device Mathematical OCR, Dynamic 2D Graphing, & Voice-Driven AI Computations</strong>
</p>

<p align="center">
  <a href="#-live-demos--direct-downloads"><strong>Live Web Demo</strong></a> •
  <a href="#-live-demos--direct-downloads"><strong>Download Android APK</strong></a> •
  <a href="#-key-features"><strong>Features</strong></a> •
  <a href="#-codebase-architecture"><strong>Architecture</strong></a> •
  <a href="#%EF%B8%8F-developer-setup"><strong>Setup Guide</strong></a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter Badge"/>
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart Badge"/>
  <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android Badge"/>
  <img src="https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge" alt="License Badge"/>
</p>

---

VoxCalc is an **elite, production-grade, highly interactive AI-inspired mobile and web application** built using **Flutter and Dart**. Breaking away from boring standard utility designs, VoxCalc merges a **futuristic glassmorphic design system** with vibrant neon gradients, smooth 120 FPS animations, and a powerhouse collection of premium mathematical utilities.

---

## 🚀 Live Demos & Direct Downloads

| Platform | Type | Status | Action Link |
|:---|:---|:---|:---|
| **Android Device** | **Release APK Package** | `v1.0.0-Stable` | [📥 Download Stable APK](https://github.com/md-rounaq-ali/VoxCalc/releases/download/v1.0.0/app-release.apk) |
| **Web Browser** | **Live Interactive App** | `Online` | [🌐 Launch Live Web Demo](https://md-rounaq-ali.github.io/VoxCalc) |

---

## 📸 Interface Showcases

<p align="center">
  <kbd>
    <img src="https://raw.githubusercontent.com/md-rounaq-ali/VoxCalc/main/screenshots/keypad_dark.jpg" width="220" alt="Futuristic Neon Keypad"/>
  </kbd>
  <kbd>
    <img src="https://raw.githubusercontent.com/md-rounaq-ali/VoxCalc/main/screenshots/voice_dark.jpg" width="220" alt="Tactile Pulse Voice AI"/>
  </kbd>
  <kbd>
    <img src="https://raw.githubusercontent.com/md-rounaq-ali/VoxCalc/main/screenshots/drawer_dark.jpg" width="220" alt="Sleek Modern Navigation Menu"/>
  </kbd>
</p>

---

## 🌟 Key Features

### 📷 1. Dynamic On-Device OCR Scanner
* Fully integrated camera viewfinder featuring real-time, **100% local on-device Google ML Kit text recognition**.
* Intelligent mathematical expression normalizer (translates visual and written fractions, brackets, products like `×`/`÷` to math syntax, and cleans background noise).
* Automatically clears active calculation states and computes final results instantly on screenshot capture!

### 📈 2. Advanced algebraic 2D Graph Plotter
* Plot fully dynamic algebraic functions in real-time as you type (e.g. `sin(x) * cos(x)`, `x^2 - 4`, absolute values, exponents, log curves).
* Binds standard math variables (`x`, `pi`, `e`) and constants dynamically.
* Fluid custom canvas painter supporting intuitive drag-to-pan translations and pinch-to-zoom scales.

### 🎙️ 3. Voice Speech-To-Math AI
* Speak equations naturally (e.g. *"fifty-five times four divided by two"*) and watch them translate instantly into mathematical symbols.
* High-tech visual interface featuring continuous audio wave ripple animations and pulsing neon microphones.
* App Smart Vocal Triggers: *"Vox, set theme to Cyberpunk"*, *"Vox, clear workspace"*, *"Vox, show history"*, *"Vox, export calculations"*.
* Text-to-Speech synthesis readouts vocalizing results in a clean, futuristic AI voice.

### 🔄 4. Global Live Currency & Unit Converter
* Convert between **156 global currencies** (including INR, USD, EUR, JPY, GBP, CAD) with live dynamic rates pulled over secure HTTPS REST APIs.
* Fully featured, instant currency and country search bar with glassmorphic listings and robust offline caching.
* Built-in dynamic scientific unit converter supporting Length and Mass dimensions.

### 📐 5. Step-by-Step System Solvers
* **Quadratic Solver:** Displays standard discriminant derivations, real/complex roots, and step-by-step factoring calculations.
* **Linear Systems (2-Variables):** Deciphers simultaneous linear systems instantly via Cramer's Rule.
* **Matrix Utilities:** Interactive matrices calculating determinants, matrix transposes, and matrix inversions in real-time.

### 📚 6. Comprehensive Encyclopedia & History logs
* Expansive mathematical formula database (Algebra, Calculus, Geometry, Physics, Statistics, and Financial Mathematics).
* Direct one-tap **"INJECT FORMULA"** shortcut, allowing you to load complex formulas instantly into your workspace.
* Swipe-to-delete history timeline with direct CSV/PDF document exporters.

### 📊 7. Student Analytics Stats Dashboard
* Performance profile tracker monitoring study streaks, weekly targets, and computational metrics.
* Dynamic variable memory registers ($x$, $y$, $z$, $a$, $b$) with direct editable dialogs.

---

## 📂 Codebase Architecture (Feature-First Clean Architecture)

VoxCalc adheres to robust **Clean Architecture** patterns combined with **Provider state management**, ensuring the code is fully decoupled, extensible, and completely stable across mobile, web, and desktop.

```
VoxCalc/
├── android/                              # Native Android Platform Build Scripts & Rules
│   ├── app/                              # Android Application Module
│   │   ├── build.gradle.kts              # Application Build Configuration (compileSdk = 36, R8 active)
│   │   └── proguard-rules.pro            # Custom R8/Proguard rules for Google ML Kit modules
│   └── build.gradle.kts                  # Root Gradle Configuration (overrides library dependency compileSdk to 36)
├── assets/                               # Static Application Resources & Audio Cache
│   ├── audio/                            # Tactical Audio Feedback (click, erase, success SFX)
│   └── icon/                             # High-Resolution Application Branding Logo
├── ios/                                  # Native iOS Platform App Files
├── web/                                  # Flutter Web Support (HTML/JS canvas targets)
├── windows/                              # Flutter Native Windows Desktop Target Configuration
├── lib/                                  # Main Application Source Code
│   ├── main.dart                         # Main Application Entry Point, Service Initializer & Device Config
│   ├── core/                             # Shared Foundation Classes & Services
│   │   ├── services/                     # Application-Wide Platform Integrations
│   │   │   ├── storage_service.dart      # Hive Local Database Persistence Engine
│   │   │   ├── tts_service.dart          # Text-To-Speech Audio Voice Synthesis
│   │   │   ├── export_service.dart       # High-Tech PDF Document & CSV File Exporter
│   │   │   └── service_locator.dart      # Dependency Injection Container (GetIt Registry)
│   │   ├── theme/                        # Sleek Dark Slate, Neon Cyberpunk, & Aurora Engine Token Rules
│   │   │   ├── app_theme.dart            # Multi-Theme Application System Configurations
│   │   │   └── text_styles.dart          # Typographic styling rules using premium Google Fonts
│   │   └── utils/                        # System Constants & Helper Pipelines
│   │       ├── math_parser.dart          # Safe PEMDAS Math Compiler & Custom Equation Solver
│   │       └── haptic_helper.dart        # Native Tactile Vibration Controller
│   └── features/                         # Decoupled Feature Modules (Feature-First Architecture)
│       ├── splash/                       # High-Impact Branded Entry Loading Screen
│       ├── onboarding/                   # Interactive User Onboarding Slider Suite
│       ├── calculator/                   # Core Workspace (Keypad UI & AI Voice Recognition Interfaces)
│       │   ├── domain/                   # Domain Layer (Calculator business rules)
│       │   ├── data/                     # Data Layer (History, database operations)
│       │   └── presentation/             # UI Components (keypads, settings, history widgets)
│       ├── grapher/                      # Real-time algebraic coordinate grid graph canvas
│       ├── solver/                       # Step-by-step math solver (Matrix, simultaneous equations)
│       ├── lens/                         # Camera viewfinder overlay & Google ML Kit OCR scanner
│       ├── formulas/                     # Interactive Mathematical reference book and inject engine
│       ├── stats/                        # Study Analytics charts, streaks, and editable memory variables
│       └── converter/                    # Global currency rate converter & dimension transformer
└── pubspec.yaml                          # Package Configuration, Assets Registry, & Dependecies Catalog
```
----

## 🛠️ Developer Setup & Launch Guide

### 1. Prerequisites
* [Flutter SDK Stable Channel](https://flutter.dev/docs/get-started/install) installed on your system.
* A connected mobile device, emulator, or modern web browser.

### 2. Running Locally
```bash
# 1. Clone this repository
git clone https://github.com/md-rounaq-ali/VoxCalc.git

# 2. Navigate to the project root folder
cd VoxCalc

# 3. Retrieve all open-source dependencies
flutter pub get

# 4. Launch the application on your connected device
flutter run
```

### 3. Build & Package Release APK
```bash
# Build a highly optimized, single universal Release APK
flutter build apk --release
```
*Your production APK will be built and saved at: `build/app/outputs/flutter-apk/app-release.apk`*

---

## 📄 License & Pricing
Licensed under the **MIT License**. VoxCalc is 100% free to deploy, distribute, and modify.
