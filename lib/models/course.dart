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
  final String? coverImagePath; // Path to cover image (asset path or URL)
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
    this.coverImagePath,
    required this.modules,
    required this.questions,
  });

  // Helper function to parse image path (handles empty strings and null)
  static String? _parseImagePath(String? path) {
    if (path == null || path.isEmpty || path.trim().isEmpty) {
      return null;
    }
    return path.trim();
  }

  // Factory constructor to create Course from JSON
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      rating: (json['rating'] is num) ? json['rating'].toDouble() : double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      students: (json['students'] is num) ? json['students'].toInt() : int.tryParse(json['students']?.toString() ?? '0') ?? 0,
      isTrendy: json['isTrendy'] == true || json['isTrendy'] == 'true',
      isPremium: json['isPremium'] == true || json['isPremium'] == 'true',
      imageColor: json['imageColor']?.toString() ?? 'purple',
      coverImagePath: _parseImagePath(
        json['coverImagePath']?.toString() ?? 
        json['coverImage']?.toString() ?? 
        json['imageUrl']?.toString()
      ),
      modules: (json['modules'] as List<dynamic>?)
          ?.map((module) => CourseModule.fromJson(Map<String, dynamic>.from(module)))
          .toList() ?? [],
      questions: (json['questions'] as List<dynamic>?)
          ?.map((question) => Question.fromJson(Map<String, dynamic>.from(question)))
          .toList() ?? [],
    );
  }

  // Convert Course to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'duration': duration,
      'rating': rating,
      'students': students,
      'isTrendy': isTrendy,
      'isPremium': isPremium,
      'imageColor': imageColor,
      'coverImagePath': coverImagePath,
      'modules': modules.map((module) => module.toJson()).toList(),
      'questions': questions.map((question) => question.toJson()).toList(),
    };
  }
}

class CourseModule {
  final String id;
  final String title;
  final String duration;
  final String iconColor; // For play button color
  final String videoUrl; // Video file path or URL
  final String markdownDescription; // Markdown formatted description
  final String htmlContent; // HTML content for practical activity

  CourseModule({
    required this.id,
    required this.title,
    required this.duration,
    required this.iconColor,
    required this.videoUrl,
    required this.markdownDescription,
    this.htmlContent = '',
  });

  // Factory constructor to create CourseModule from JSON
  factory CourseModule.fromJson(Map<String, dynamic> json) {
    return CourseModule(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      iconColor: json['iconColor']?.toString() ?? 'orange',
      videoUrl: (json['videoUrl']?.toString() ?? '').trim(),
      markdownDescription: json['markdownDescription']?.toString() ?? '',
      htmlContent: json['htmlContent']?.toString() ?? '',
    );
  }

  // Convert CourseModule to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'duration': duration,
      'iconColor': iconColor,
      'videoUrl': videoUrl,
      'markdownDescription': markdownDescription,
      'htmlContent': htmlContent,
    };
  }
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

  // Factory constructor to create Question from JSON
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      options: (json['options'] as List<dynamic>?)
          ?.map((option) => option.toString())
          .toList() ?? [],
      correctAnswerIndex: (json['correctAnswerIndex'] is num) 
          ? json['correctAnswerIndex'].toInt() 
          : int.tryParse(json['correctAnswerIndex']?.toString() ?? '0') ?? 0,
    );
  }

  // Convert Question to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
    };
  }
}

