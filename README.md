# Wine Quest App

A Flutter application for wine recommendations based on user preferences.

## Features

- Intro screen with two options: for users with and without wine experience
- Audio recording for experienced users to express their wine preferences
- Questionnaire for less experienced users to select their preferences
- Integration with a wine recommendation API
- Beautiful, minimalistic UI with a modern design

## Getting Started

### Prerequisites

- Flutter 3.7.0 or higher
- Dart 3.0.0 or higher

### Installation

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the application

## Architecture

The app follows a modular architecture with BLoC pattern for state management:

- `models/`: Data models
- `bloc/`: BLoC implementation for state management
- `screens/`: UI screens
- `services/`: API and business logic services
- `widgets/`: Reusable UI components

## API Integration

The app interacts with a wine recommendation API:

- API base URL: `http://10.16.112.87:8000/api`
- Endpoints:
  - `POST /process`: Submit audio or questionnaire data
  - `GET /status/{job_id}`: Check processing status
