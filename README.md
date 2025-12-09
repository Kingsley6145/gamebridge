# Gamebridge - Online Learning Platform

A modern Flutter application for learning game development, programming, UI/UX design, AI, and web development courses.

## Features

- 🎨 Beautiful, modern UI design matching the provided mockups
- 📱 Responsive mobile-first design
- 🎓 Multiple course categories: Game Development, Programming, UI/UX, AI, Web Development
- ⭐ Course ratings and student counts
- 📚 Course modules with duration tracking
- 🔔 Notification system
- 🎯 Premium course badges
- 📊 Best of the week section
- 🔥 Trendy courses showcase

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Android Emulator or iOS Simulator (or physical device)

### Installation

1. Clone the repository:
```bash
git clone <your-repo-url>
cd Gamebridge
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── course.dart          # Course, Module, and Question models
├── data/
│   └── courses_data.dart    # Sample courses data
└── screens/
    ├── home_screen.dart     # Landing page with courses
    └── course_detail_screen.dart  # Course detail page
```

## Course Categories

- **Game Development**: Unity, Unreal Engine, 3D Modeling
- **Programming**: Python, C#, JavaScript
- **UI/UX**: Design principles, Wireframing, Prototyping
- **AI**: Machine Learning, Neural Networks
- **Web Development**: React, Frontend frameworks

## Design Features

- Clean, modern interface with vibrant colors
- Smooth animations and transitions
- Card-based course layouts
- Gradient buttons and backgrounds
- Custom bottom navigation bar
- 3D-style illustrations (placeholders)

## Sample Data

The app includes 8 sample courses with:
- Course modules with durations
- Quiz questions for each course
- Ratings and student counts
- Premium content badges
- Trendy course indicators

## Customization

You can easily customize:
- Course data in `lib/data/courses_data.dart`
- Colors and themes in individual screen files
- Font styles (currently using Google Fonts - Inter)
- Course categories and modules

## Next Steps

- Add video player integration
- Implement quiz functionality
- Add user authentication
- Create course progress tracking
- Add search and filter functionality
- Implement favorites/bookmarking

## License

This project is created for educational purposes.

