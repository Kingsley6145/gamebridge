class Course {
  final String id;
  final String title;
  final String description;
  final String category;
  final String duration;
  final double rating;
  final int students;
  final bool isTrendy;
  final bool isPremium;
  final String imageColor; // For gradient/color background
  final List<CourseModule> modules;
  final List<Question> questions;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.duration,
    required this.rating,
    required this.students,
    this.isTrendy = false,
    this.isPremium = false,
    required this.imageColor,
    required this.modules,
    required this.questions,
  });
}

class CourseModule {
  final String id;
  final String title;
  final String duration;
  final String iconColor; // For play button color
  final String videoUrl; // Video file path or URL
  final String markdownDescription; // Markdown formatted description

  CourseModule({
    required this.id,
    required this.title,
    required this.duration,
    required this.iconColor,
    required this.videoUrl,
    required this.markdownDescription,
  });
}

class Question {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
  });
}

