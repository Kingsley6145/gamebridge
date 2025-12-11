import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course.dart';
import 'firebase_service.dart';

final FirebaseService _firebaseService = FirebaseService();
List<Course> _cachedCourses = [];
bool _isInitialized = false;

// Cache key for storing courses locally
const String _coursesCacheKey = 'cached_courses';

// Initialize courses - loads from cache immediately, then fetches from Firebase
Future<void> initializeCourses() async {
  if (_isInitialized) return;
  
  // Load from cache immediately (instant loading)
  await _loadCoursesFromCache();
  
  // Fetch fresh data from Firebase in the background
  fetchCoursesFromFirebase().catchError((error) {
    print('Background fetch failed: $error');
    // Keep using cached data if fetch fails
  });
  
  _isInitialized = true;
}

// Load courses from local cache (instant)
Future<void> _loadCoursesFromCache() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_coursesCacheKey);
    
    if (cachedData != null) {
      final List<dynamic> jsonList = jsonDecode(cachedData);
      _cachedCourses = jsonList
          .map((json) => Course.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      print('Loaded ${_cachedCourses.length} courses from cache');
    } else {
      print('No cached courses found');
    }
  } catch (e) {
    print('Error loading courses from cache: $e');
  }
}

// Save courses to local cache
Future<void> _saveCoursesToCache(List<Course> courses) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = courses.map((course) => course.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString(_coursesCacheKey, jsonString);
    print('Saved ${courses.length} courses to cache');
  } catch (e) {
    print('Error saving courses to cache: $e');
  }
}

// Fetch courses from Firebase and update cache
Future<List<Course>> fetchCoursesFromFirebase() async {
  try {
    print('🔄 Fetching courses from Firebase...');
    final courses = await _firebaseService.fetchCourses();
    print('📦 Received ${courses.length} courses from Firebase');
    
    if (courses.isNotEmpty) {
      print('✅ Updating cache with ${courses.length} courses');
      _cachedCourses = courses;
      // Update cache with fresh data
      await _saveCoursesToCache(courses);
      print('💾 Cache updated successfully');
      
      // Print all course titles for debugging
      print('📚 Courses in cache:');
      for (var i = 0; i < courses.length; i++) {
        print('  ${i + 1}. ${courses[i].title} (ID: ${courses[i].id})');
      }
    } else {
      print('⚠️ WARNING: Firebase returned empty course list');
      print('   Current cache has ${_cachedCourses.length} courses');
    }
    return _cachedCourses;
  } catch (e, stackTrace) {
    print('❌ Error fetching courses: $e');
    print('Stack trace: $stackTrace');
    return _cachedCourses; // Return cached courses if fetch fails
  }
}

// Get cached courses (for immediate access)
List<Course> get allCourses => _cachedCourses;

// Force refresh courses from Firebase (clears cache first)
Future<List<Course>> forceRefreshCourses() async {
  try {
    print('🔄 Force refreshing courses from Firebase...');
    
    // Clear cache
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_coursesCacheKey);
    _cachedCourses = [];
    print('🗑️ Cache cleared');
    
    // Fetch fresh data
    return await fetchCoursesFromFirebase();
  } catch (e, stackTrace) {
    print('❌ Error force refreshing courses: $e');
    print('Stack trace: $stackTrace');
    return _cachedCourses;
  }
}

// Stream courses for real-time updates (includes cached courses immediately)
Stream<List<Course>> streamCourses() async* {
  // First emit cached courses immediately (for instant loading)
  if (_cachedCourses.isNotEmpty) {
    print('📤 Emitting ${_cachedCourses.length} cached courses');
    yield _cachedCourses;
  }
  
  // Then listen to Firebase updates
  yield* _firebaseService.streamCourses().map((courses) {
    if (courses.isNotEmpty) {
      print('🔄 Stream update: Received ${courses.length} courses from Firebase');
      _cachedCourses = courses;
      _saveCoursesToCache(courses); // Update cache when Firebase data arrives
      print('✅ Cache updated from stream with ${courses.length} courses');
      
      // Print all course titles for debugging
      for (var i = 0; i < courses.length; i++) {
        print('  ${i + 1}. ${courses[i].title} (ID: ${courses[i].id})');
      }
    } else {
      print('⚠️ Stream update: Firebase returned empty list, keeping ${_cachedCourses.length} cached courses');
    }
    return _cachedCourses;
  });
}

// Legacy dummy data (kept for reference but not used)
final List<Course> _dummyCourses = [
  Course(
    id: '1',
    title: 'UX Master Course',
    description: 'Master the art of user experience design',
    category: 'UI/UX',
    duration: '2h 46min',
    rating: 4.8,
    students: 680,
    isTrendy: true,
    isPremium: true,
    imageColor: 'purple',
    modules: [
      CourseModule(
        id: '1',
        title: 'Introduction to UX',
        duration: '4:28 mins',
        iconColor: 'orange',
        videoUrl: 'assets/videos/ui_ux_explained.mp4',
        markdownDescription: '''# Introduction to UX

User Experience (UX) design is the process of creating products that provide meaningful and relevant experiences to users. This involves the design of the entire process of acquiring and integrating the product, including aspects of branding, design, usability, and function.

## Key Concepts

- **User-Centered Design**: Putting the user at the center of the design process
- **Usability**: Making products easy to use and understand
- **Accessibility**: Ensuring products can be used by people with diverse abilities

## What You'll Learn

In this module, we'll cover:
- The fundamentals of UX design
- Why UX matters in product development
- The difference between UX and UI design
- Core principles of good user experience''',
      ),
      CourseModule(
        id: '2',
        title: 'Three Crucial Questions',
        duration: '8:46 mins',
        iconColor: 'lightOrange',
        videoUrl: 'assets/videos/ui_ux_explained.mp4',
        markdownDescription: '''# Three Crucial Questions

Before starting any UX project, there are three fundamental questions you must answer:

## 1. Who is the user?

Understanding your target audience is crucial. Consider:
- Demographics (age, location, occupation)
- Psychographics (interests, values, behaviors)
- Technical proficiency
- Goals and motivations

## 2. What is the user's goal?

Every user interaction has a purpose. Identify:
- Primary goals (what they want to accomplish)
- Secondary goals (nice-to-have features)
- Pain points (what frustrates them)

## 3. What does the user expect?

Users come with expectations based on:
- Previous experiences
- Industry standards
- Brand perception
- Device capabilities

## Best Practices

- Conduct user research before designing
- Create user personas
- Map user journeys
- Test assumptions with real users''',
      ),
      CourseModule(
        id: '3',
        title: 'Identifying User Needs',
        duration: '39:58 mins',
        iconColor: 'lightOrange',
        videoUrl: 'assets/videos/ui_ux_explained.mp4',
        markdownDescription: '''# Identifying User Needs

Understanding user needs is the foundation of great UX design. This module covers comprehensive techniques for discovering what users truly want and need.

## Research Methods

### 1. User Interviews
- One-on-one conversations with users
- Open-ended questions
- Deep insights into motivations

### 2. Surveys and Questionnaires
- Quantitative data collection
- Large sample sizes
- Statistical significance

### 3. Observation Studies
- Watch users in their natural environment
- Identify pain points
- Understand context

### 4. Analytics Analysis
- User behavior data
- Heatmaps and click tracking
- Conversion funnels

## Analyzing Findings

Once you've collected data:
1. **Synthesize** - Look for patterns
2. **Prioritize** - Focus on high-impact needs
3. **Validate** - Test your assumptions
4. **Document** - Create user stories and requirements

## Common Pitfalls

- Assuming you know what users want
- Ignoring edge cases
- Focusing only on happy paths
- Not validating with real users''',
      ),
      CourseModule(
        id: '4',
        title: 'Wireframing Basics',
        duration: '25:12 mins',
        iconColor: 'lightOrange',
        videoUrl: 'assets/videos/ui_ux_explained.mp4',
        markdownDescription: '''# Wireframing Basics

Wireframes are low-fidelity visual representations of a user interface. They focus on layout, structure, and functionality rather than visual design.

## What is a Wireframe?

A wireframe is like a blueprint for your design:
- Shows structure and layout
- Indicates content placement
- Defines user flow
- No colors, fonts, or images

## Types of Wireframes

### Low-Fidelity Wireframes
- Simple boxes and lines
- Quick to create
- Focus on structure

### Mid-Fidelity Wireframes
- More detail
- Actual text content
- Basic hierarchy

### High-Fidelity Wireframes
- Detailed layout
- Specific measurements
- Close to final design

## Wireframing Tools

Popular tools include:
- **Figma** - Collaborative design tool
- **Sketch** - Mac-based design tool
- **Adobe XD** - All-in-one UX solution
- **Balsamiq** - Rapid wireframing
- **Pen and Paper** - Still effective!

## Best Practices

1. Start with low-fidelity
2. Focus on functionality first
3. Keep it simple
4. Get feedback early
5. Iterate based on user testing''',
      ),
      CourseModule(
        id: '5',
        title: 'Prototyping Tools',
        duration: '32:45 mins',
        iconColor: 'lightOrange',
        videoUrl: 'assets/videos/ui_ux_explained.mp4',
        markdownDescription: '''# Prototyping Tools

Prototypes bring your designs to life, allowing you to test interactions and gather feedback before development begins.

## Why Prototype?

- **Test interactions** before coding
- **Communicate** ideas to stakeholders
- **Validate** design decisions
- **Save time** and resources

## Types of Prototypes

### Low-Fidelity Prototypes
- Paper prototypes
- Clickable wireframes
- Basic interactions

### High-Fidelity Prototypes
- Realistic designs
- Complex interactions
- Close to final product

## Popular Prototyping Tools

### Figma
- **Strengths**: Collaboration, web-based, powerful
- **Best for**: Team projects, design systems

### Adobe XD
- **Strengths**: Integration with Adobe suite
- **Best for**: Adobe ecosystem users

### Framer
- **Strengths**: Advanced animations, code components
- **Best for**: Complex interactions

### InVision
- **Strengths**: User testing, feedback collection
- **Best for**: Client presentations

## Prototyping Best Practices

1. Start simple, add complexity gradually
2. Focus on key user flows
3. Test with real users
4. Iterate based on feedback
5. Document interactions and states''',
      ),
    ],
    questions: [
      Question(
        id: '1',
        question: 'What is the primary goal of UX design?',
        options: [
          'To make products look beautiful',
          'To create products that provide meaningful and relevant experiences to users',
          'To use the latest design trends',
          'To maximize profits',
        ],
        correctAnswerIndex: 1,
      ),
      Question(
        id: '2',
        question: 'Which of these is NOT a UX research method?',
        options: [
          'User interviews',
          'A/B testing',
          'Color theory',
          'Usability testing',
        ],
        correctAnswerIndex: 2,
      ),
    ],
  ),
  Course(
    id: '2',
    title: 'UI Master Course',
    description: 'Learn modern UI design principles and techniques',
    category: 'UI/UX',
    duration: '3h 15min',
    rating: 4.9,
    students: 920,
    isTrendy: true,
    isPremium: true,
    imageColor: 'orange',
    modules: [
      CourseModule(
        id: '1',
        title: 'UI Design Fundamentals',
        duration: '12:30 mins',
        iconColor: 'orange',
        videoUrl: 'assets/videos/ui_ux_explained.mp4',
        markdownDescription: '''# UI Design Fundamentals

User Interface (UI) design focuses on the visual and interactive elements of a product. Learn the core principles that make interfaces intuitive and beautiful.

## Core Principles

### 1. Clarity
- Clear visual hierarchy
- Obvious interactive elements
- Easy to understand at a glance

### 2. Consistency
- Uniform design patterns
- Predictable interactions
- Familiar conventions

### 3. Feedback
- Visual response to actions
- Loading states
- Success/error messages

### 4. Efficiency
- Minimal steps to complete tasks
- Keyboard shortcuts
- Smart defaults

## Design Elements

- **Layout**: Structure and spacing
- **Color**: Visual hierarchy and meaning
- **Typography**: Readability and personality
- **Icons**: Universal symbols
- **Images**: Visual storytelling

## Best Practices

- Follow platform guidelines (iOS/Android/Web)
- Design for accessibility
- Test on multiple devices
- Keep it simple
- Focus on user goals''',
      ),
      CourseModule(
        id: '2',
        title: 'Color Theory in UI',
        duration: '18:45 mins',
        iconColor: 'lightOrange',
        videoUrl: 'assets/videos/ui_ux_explained.mp4',
        markdownDescription: '''# Color Theory in UI

Color is one of the most powerful tools in UI design. Understanding color theory helps you create interfaces that are both beautiful and functional.

## Color Psychology

Colors evoke emotions:
- **Blue**: Trust, stability, professionalism
- **Green**: Growth, success, nature
- **Red**: Urgency, passion, danger
- **Yellow**: Energy, optimism, caution
- **Purple**: Creativity, luxury, mystery

## Color Systems

### Primary Colors
- Main brand colors
- Used for key actions
- Limited palette (2-3 colors)

### Secondary Colors
- Supporting colors
- Used for variety
- Complementary to primary

### Neutral Colors
- Grays, whites, blacks
- Backgrounds and text
- Foundation of the design

## Accessibility

- **Contrast Ratios**: Ensure text is readable
- **Color Blindness**: Don't rely on color alone
- **WCAG Guidelines**: Follow accessibility standards

## Practical Tips

1. Start with a limited palette
2. Use color to guide attention
3. Test with real users
4. Consider cultural differences
5. Maintain consistency across screens''',
      ),
      CourseModule(
        id: '3',
        title: 'Typography Essentials',
        duration: '22:10 mins',
        iconColor: 'lightOrange',
        videoUrl: 'assets/videos/ui_ux_explained.mp4',
        markdownDescription: '''# Typography Essentials

Typography is the art of arranging type to make written language readable and appealing. In UI design, typography affects both aesthetics and usability.

## Typeface Categories

### Serif
- Traditional, formal
- Good for long-form content
- Examples: Times New Roman, Georgia

### Sans-Serif
- Modern, clean
- Excellent for screens
- Examples: Helvetica, Roboto

### Display
- Decorative, attention-grabbing
- Use sparingly
- Examples: Impact, Bebas Neue

## Typography Hierarchy

Create clear visual hierarchy:
1. **Headings** - Largest, boldest
2. **Subheadings** - Medium size
3. **Body text** - Readable size (16px+)
4. **Captions** - Smallest, supporting info

## Key Metrics

- **Font Size**: Readability on all devices
- **Line Height**: Spacing between lines (1.5-1.6x)
- **Letter Spacing**: Character spacing
- **Line Length**: Optimal reading width (50-75 chars)

## Best Practices

- Limit to 2-3 typefaces
- Ensure sufficient contrast
- Test readability
- Consider loading performance
- Use system fonts when possible
- Respect user font preferences''',
      ),
    ],
    questions: [
      Question(
        id: '1',
        question: 'What does UI stand for?',
        options: [
          'User Interface',
          'User Interaction',
          'Universal Interface',
          'User Integration',
        ],
        correctAnswerIndex: 0,
      ),
    ],
  ),
  Course(
    id: '3',
    title: 'Grow Your 3D Skills',
    description: 'Master 3D modeling and game asset creation',
    category: 'Game Development',
    duration: '5h 20min',
    rating: 4.7,
    students: 450,
    isTrendy: false,
    isPremium: false,
    imageColor: 'yellow',
    modules: [
      CourseModule(
        id: '1',
        title: 'Introduction to 3D Modeling',
        duration: '15:20 mins',
        iconColor: 'orange',
        videoUrl: 'assets/videos/ui_ux_explained.mp4',
        markdownDescription: '''# Introduction to 3D Modeling

3D modeling is the process of creating three-dimensional representations of objects using specialized software. This is the foundation of game development, animation, and visual effects.

## What is 3D Modeling?

3D modeling involves:
- Creating geometric shapes (meshes)
- Manipulating vertices, edges, and faces
- Adding detail and complexity
- Preparing models for use in games or animations

## Types of 3D Models

### Low-Poly Models
- Few polygons
- Fast rendering
- Good for games
- Stylized appearance

### High-Poly Models
- Many polygons
- Detailed and realistic
- Used for renders
- Often retopologized for games

## Modeling Techniques

### Box Modeling
- Start with primitive shapes
- Extrude and modify
- Great for beginners

### Sculpting
- Digital clay
- Organic shapes
- High detail work

### Procedural Modeling
- Algorithm-based
- Parametric control
- Efficient workflows

## Essential Tools

- **Blender** - Free, open-source
- **Maya** - Industry standard
- **3ds Max** - Popular for games
- **ZBrush** - Digital sculpting

## Getting Started

1. Learn the interface
2. Master basic tools
3. Practice with simple objects
4. Study real-world references
5. Join communities for feedback''',
      ),
      CourseModule(
        id: '2',
        title: 'Texturing Basics',
        duration: '28:45 mins',
        iconColor: 'lightOrange',
        videoUrl: 'assets/videos/ui_ux_explained.mp4',
        markdownDescription: '''# Texturing Basics

Textures bring 3D models to life by adding color, detail, and realism. Learn how to create and apply textures to your models.

## What are Textures?

Textures are 2D images applied to 3D surfaces:
- **Diffuse/Albedo**: Base color
- **Normal**: Surface detail
- **Roughness**: Surface shininess
- **Metallic**: Metal properties
- **Ambient Occlusion**: Shadow details

## Texture Maps Explained

### Diffuse Map
- Base color information
- What the material looks like
- Most important texture

### Normal Map
- Simulates surface detail
- Adds depth without geometry
- Bumps and scratches

### Roughness Map
- Controls surface shininess
- Black = glossy, White = matte
- Realistic material properties

## Creating Textures

### Methods:
1. **Photography** - Real-world photos
2. **Painting** - Digital painting tools
3. **Procedural** - Algorithm-generated
4. **Substance** - Material authoring tools

## UV Mapping

- Unwrapping 3D model to 2D space
- Essential for texture application
- Minimize seams and distortion
- Efficient use of texture space

## Best Practices

- Use appropriate resolution
- Optimize for performance
- Maintain consistent style
- Test in-game lighting
- Use texture atlases efficiently''',
      ),
      CourseModule(
        id: '3',
        title: 'Rigging and Animation',
        duration: '45:30 mins',
        iconColor: 'lightOrange',
        videoUrl: 'assets/videos/ui_ux_explained.mp4',
        markdownDescription: '''# Rigging and Animation

Rigging creates a skeleton for 3D models, enabling animation. Learn to bring your characters and objects to life.

## What is Rigging?

Rigging involves:
- Creating a skeleton (bones/armature)
- Binding mesh to skeleton (skin weighting)
- Setting up controls for animators
- Testing deformation

## Rigging Workflow

1. **Planning** - Understand movement needs
2. **Bone Creation** - Place joints correctly
3. **Weight Painting** - Control deformation
4. **Controls** - User-friendly interface
5. **Testing** - Verify all movements

## Animation Principles

### The 12 Principles:
1. **Squash and Stretch**
2. **Anticipation**
3. **Staging**
4. **Straight Ahead vs Pose to Pose**
5. **Follow Through**
6. **Slow In and Slow Out**
7. **Arc**
8. **Secondary Action**
9. **Timing**
10. **Exaggeration**
11. **Solid Drawing**
12. **Appeal**

## Keyframe Animation

- Set key poses
- Let software interpolate
- Refine timing and spacing
- Add secondary motion

## Animation Tools

- **Blender** - Free rigging and animation
- **Maya** - Industry standard
- **3ds Max** - Character Studio
- **MotionBuilder** - Motion capture

## Best Practices

- Keep rigs simple and efficient
- Test extreme poses
- Document controls
- Create reusable rigs
- Optimize for performance''',
      ),
    ],
    questions: [
      Question(
        id: '1',
        question: 'Which software is commonly used for 3D modeling?',
        options: [
          'Photoshop',
          'Blender',
          'Illustrator',
          'Figma',
        ],
        correctAnswerIndex: 1,
      ),
    ],
  ),
  Course(
    id: '4',
    title: 'Unity Game Development',
    description: 'Build games from scratch using Unity engine',
    category: 'Game Development',
    duration: '8h 45min',
    rating: 4.9,
    students: 1200,
    isTrendy: true,
    isPremium: true,
    imageColor: 'blue',
    modules: [
      CourseModule(
        id: '1',
        title: 'Unity Basics',
        duration: '20:15 mins',
        iconColor: 'orange',
        videoUrl: 'assets/videos/ui_ux_explained.mp4',
        markdownDescription: '''# Unity Basics

Unity is a powerful game engine used by millions of developers worldwide. This module introduces you to the Unity interface and core concepts.

## Unity Interface Overview

### Key Panels:
- **Scene View**: 3D workspace
- **Game View**: Player perspective
- **Hierarchy**: Object organization
- **Inspector**: Object properties
- **Project**: Asset management
- **Console**: Debug messages

## Core Concepts

### GameObjects
- Everything in Unity is a GameObject
- Empty containers for components
- Can be nested (parent-child)

### Components
- Add functionality to GameObjects
- Transform, Renderer, Collider, etc.
- Modular and reusable

### Prefabs
- Reusable GameObject templates
- Changes propagate to instances
- Essential for efficiency

## Getting Started

1. **Create a Project** - Choose template
2. **Explore the Interface** - Familiarize yourself
3. **Create GameObjects** - Add objects to scene
4. **Add Components** - Give objects behavior
5. **Test Your Scene** - Use Play button

## Essential Components

- **Transform**: Position, rotation, scale
- **Renderer**: Visual appearance
- **Collider**: Physics boundaries
- **Rigidbody**: Physics simulation
- **Script**: Custom behavior

## Best Practices

- Organize with folders
- Use prefabs for repeated objects
- Name objects clearly
- Keep scenes clean
- Save frequently!''',
      ),
      CourseModule(
        id: '2',
        title: 'C# Scripting Fundamentals',
        duration: '35:20 mins',
        iconColor: 'lightOrange',
        videoUrl: 'assets/videos/ui_ux_explained.mp4',
        markdownDescription: '''# C# Scripting Fundamentals

C# is the primary programming language for Unity. Learn the fundamentals needed to create interactive gameplay.

## C# Basics

### Variables
```csharp
int health = 100;
float speed = 5.5f;
string playerName = "Hero";
bool isAlive = true;
```

### Functions
```csharp
void Start() {
    // Called once at start
}

void Update() {
    // Called every frame
}
```

## Unity-Specific Concepts

### MonoBehaviour
- Base class for Unity scripts
- Enables Unity callbacks
- Attached to GameObjects

### Common Methods:
- `Start()` - Initialization
- `Update()` - Per-frame logic
- `FixedUpdate()` - Physics updates
- `OnCollisionEnter()` - Collision detection

## Accessing Components

```csharp
// Get component
Rigidbody rb = GetComponent<Rigidbody>();

// Access other objects
GameObject player = GameObject.Find("Player");
Transform playerTransform = player.transform;
```

## Input Handling

```csharp
// Keyboard input
if (Input.GetKey(KeyCode.Space)) {
    // Jump
}

// Mouse input
float mouseX = Input.GetAxis("Mouse X");
```

## Best Practices

- Use meaningful variable names
- Comment your code
- Keep functions focused
- Test frequently
- Learn from Unity documentation''',
      ),
      CourseModule(
        id: '3',
        title: 'Physics and Collisions',
        duration: '42:10 mins',
        iconColor: 'lightOrange',
        videoUrl: 'assets/videos/ui_ux_explained.mp4',
        markdownDescription: '''# Physics and Collisions

Unity's physics system brings realism to your games. Learn how to use physics components and handle collisions.

## Physics Components

### Rigidbody
- Enables physics simulation
- Applies gravity
- Responds to forces
- Can be kinematic (script-controlled)

### Colliders
- Define object boundaries
- Box, Sphere, Capsule, Mesh
- Trigger vs Solid
- Multiple colliders per object

## Collision Detection

### Types:
1. **Collision** - Physical contact
2. **Trigger** - Overlap detection
3. **Raycast** - Line detection

### Collision Events:
```csharp
void OnCollisionEnter(Collision collision) {
    // First contact
}

void OnCollisionStay(Collision collision) {
    // Continuous contact
}

void OnCollisionExit(Collision collision) {
    // Separation
}
```

## Trigger Events

```csharp
void OnTriggerEnter(Collider other) {
    // Object entered trigger
}

void OnTriggerExit(Collider other) {
    // Object left trigger
}
```

## Physics Materials

- **Friction**: Surface resistance
- **Bounciness**: Elasticity
- **Combine**: How materials interact

## Common Use Cases

- **Platforms**: Static colliders
- **Players**: Dynamic rigidbodies
- **Pickups**: Triggers
- **Walls**: Collision boundaries
- **Projectiles**: Raycasts

## Best Practices

- Use appropriate collider shapes
- Optimize physics calculations
- Set correct layers
- Test collision scenarios
- Use physics materials for realism''',
      ),
    ],
    questions: [
      Question(
        id: '1',
        question: 'What programming language is used in Unity?',
        options: [
          'JavaScript',
          'Python',
          'C#',
          'Java',
        ],
        correctAnswerIndex: 2,
      ),
    ],
  ),
  Course(
    id: '5',
    title: 'AI & Machine Learning Basics',
    description: 'Introduction to artificial intelligence and ML concepts',
    category: 'AI',
    duration: '6h 30min',
    rating: 4.6,
    students: 780,
    isTrendy: false,
    isPremium: true,
    imageColor: 'green',
    modules: [
      CourseModule(
        id: '1',
        title: 'What is AI?',
        duration: '10:25 mins',
        iconColor: 'orange',
        videoUrl: 'assets/videos/ui_ux_explained.mp4',
        markdownDescription: '''# What is AI?

Artificial Intelligence (AI) is the simulation of human intelligence by machines. This module introduces the fundamental concepts of AI.

## Understanding AI

AI systems can:
- **Learn** from data
- **Reason** through problems
- **Perceive** their environment
- **Make decisions** autonomously

## Types of AI

### Narrow AI
- Designed for specific tasks
- Current state of AI
- Examples: Voice assistants, image recognition

### General AI
- Human-level intelligence
- Still theoretical
- Can perform any intellectual task

## AI vs Machine Learning

- **AI**: Broad concept of intelligent machines
- **Machine Learning**: Subset of AI
- **Deep Learning**: Subset of Machine Learning

## Applications

- **Healthcare**: Diagnosis, drug discovery
- **Transportation**: Self-driving cars
- **Finance**: Fraud detection, trading
- **Entertainment**: Recommendations, gaming
- **Education**: Personalized learning

## Key Concepts

- **Data**: Fuel for AI systems
- **Algorithms**: Methods for learning
- **Training**: Process of learning
- **Inference**: Making predictions

## Getting Started

1. Understand the basics
2. Learn programming (Python recommended)
3. Study mathematics (linear algebra, calculus)
4. Practice with projects
5. Join AI communities''',
      ),
      CourseModule(
        id: '2',
        title: 'Neural Networks Explained',
        duration: '28:40 mins',
        iconColor: 'lightOrange',
        videoUrl: 'assets/videos/ui_ux_explained.mp4',
        markdownDescription: '''# Neural Networks Explained

Neural networks are computing systems inspired by biological neural networks. They form the foundation of deep learning.

## How Neural Networks Work

### Basic Structure:
- **Input Layer**: Receives data
- **Hidden Layers**: Process information
- **Output Layer**: Produces results
- **Neurons**: Basic processing units
- **Weights**: Connection strengths
- **Biases**: Activation thresholds

## Key Concepts

### Forward Propagation
- Data flows from input to output
- Each layer transforms the data
- Final layer produces prediction

### Backpropagation
- Learning algorithm
- Adjusts weights based on errors
- Minimizes prediction mistakes

### Activation Functions
- **ReLU**: Most common
- **Sigmoid**: Smooth curve
- **Tanh**: Centered output
- **Softmax**: Probability distribution

## Types of Neural Networks

### Feedforward Networks
- Basic structure
- One-way data flow
- Good for classification

### Convolutional Neural Networks (CNN)
- Image processing
- Pattern recognition
- Computer vision tasks

### Recurrent Neural Networks (RNN)
- Sequential data
- Natural language processing
- Time series prediction

## Training Process

1. **Initialize** weights randomly
2. **Forward pass** through network
3. **Calculate** loss/error
4. **Backpropagate** to update weights
5. **Repeat** until convergence

## Best Practices

- Start with simple architectures
- Use appropriate activation functions
- Regularize to prevent overfitting
- Monitor training progress
- Validate on separate data''',
      ),
      CourseModule(
        id: '3',
        title: 'Training Your First Model',
        duration: '55:20 mins',
        iconColor: 'lightOrange',
        videoUrl: 'assets/videos/ui_ux_explained.mp4',
        markdownDescription: '''# Training Your First Model

Hands-on guide to training your first machine learning model. We'll use Python and popular libraries like TensorFlow or PyTorch.

## Prerequisites

- Python installed
- Basic Python knowledge
- Understanding of data structures
- NumPy and Pandas familiarity

## Step-by-Step Process

### 1. Data Preparation
```python
import pandas as pd
from sklearn.model_selection import train_test_split

# Load data
data = pd.read_csv('dataset.csv')

# Split into features and labels
X = data.drop('target', axis=1)
y = data['target']

# Split into train/test sets
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)
```

### 2. Model Selection
- Choose appropriate algorithm
- Consider problem type (classification/regression)
- Start simple, iterate

### 3. Training
```python
from sklearn.ensemble import RandomForestClassifier

# Create model
model = RandomForestClassifier(n_estimators=100)

# Train model
model.fit(X_train, y_train)
```

### 4. Evaluation
```python
from sklearn.metrics import accuracy_score

# Make predictions
predictions = model.predict(X_test)

# Calculate accuracy
accuracy = accuracy_score(y_test, predictions)
print(f"Accuracy: {accuracy}")
```

## Common Challenges

- **Overfitting**: Model memorizes training data
- **Underfitting**: Model too simple
- **Data Quality**: Garbage in, garbage out
- **Feature Engineering**: Choosing right features

## Best Practices

- Start with simple models
- Clean and preprocess data
- Use cross-validation
- Monitor training metrics
- Test on unseen data
- Document your process''',
      ),
    ],
    questions: [
      Question(
        id: '1',
        question: 'What is the difference between AI and Machine Learning?',
        options: [
          'They are the same thing',
          'ML is a subset of AI',
          'AI is a subset of ML',
          'They are completely unrelated',
        ],
        correctAnswerIndex: 1,
      ),
    ],
  ),
  Course(
    id: '6',
    title: 'React Web Development',
    description: 'Build modern web applications with React',
    category: 'Web Development',
    duration: '7h 15min',
    rating: 4.8,
    students: 1500,
    isTrendy: true,
    isPremium: false,
    imageColor: 'teal',
    modules: [
      CourseModule(
        id: '1',
        title: 'React Fundamentals',
        duration: '18:30 mins',
        iconColor: 'orange',
        videoUrl: 'assets/videos/ui_ux_explained.mp4',
        markdownDescription: '''# React Fundamentals

React is a JavaScript library for building user interfaces. Learn the core concepts that make React powerful and popular.

## What is React?

React is:
- **Component-based**: Build reusable UI pieces
- **Declarative**: Describe what UI should look like
- **Virtual DOM**: Efficient updates
- **Unidirectional Data Flow**: Predictable state

## Key Concepts

### Components
```jsx
function Welcome() {
  return <h1>Hello, World!</h1>;
}
```

### JSX
- JavaScript syntax extension
- Write HTML-like code in JavaScript
- Gets compiled to JavaScript

### Virtual DOM
- React's representation of the DOM
- Efficient diffing algorithm
- Only updates what changed

## Setting Up React

### Create React App:
```bash
npx create-react-app my-app
cd my-app
npm start
```

### Basic Structure:
```
my-app/
  src/
    App.js
    index.js
  public/
    index.html
```

## Your First Component

```jsx
import React from 'react';

function App() {
  return (
    <div className="App">
      <h1>Hello React!</h1>
    </div>
  );
}

export default App;
```

## React Hooks

- **useState**: Manage component state
- **useEffect**: Handle side effects
- **useContext**: Access context
- **Custom hooks**: Reusable logic

## Best Practices

- Keep components small
- Use functional components
- Extract reusable logic
- Follow naming conventions
- Use PropTypes or TypeScript''',
      ),
      CourseModule(
        id: '2',
        title: 'Components and Props',
        duration: '25:15 mins',
        iconColor: 'lightOrange',
        videoUrl: 'assets/videos/ui_ux_explained.mp4',
        markdownDescription: '''# Components and Props

Components are the building blocks of React applications. Props allow you to pass data between components.

## What are Components?

Components are:
- **Reusable**: Use multiple times
- **Composable**: Combine to build complex UIs
- **Isolated**: Manage their own state
- **Independent**: Can be tested separately

## Function Components

```jsx
function Button(props) {
  return <button>{props.label}</button>;
}
```

## Props

Props (properties) are:
- **Read-only**: Cannot be modified
- **Passed down**: From parent to child
- **Any type**: Strings, numbers, objects, functions

### Using Props:
```jsx
function Greeting(props) {
  return <h1>Hello, {props.name}!</h1>;
}

// Usage
<Greeting name="Alice" />
```

### Destructuring Props:
```jsx
function Greeting({ name, age }) {
  return <h1>Hello, {name}! You are {age}.</h1>;
}
```

## Component Composition

```jsx
function Card({ title, content }) {
  return (
    <div className="card">
      <h2>{title}</h2>
      <p>{content}</p>
    </div>
  );
}

function App() {
  return (
    <div>
      <Card title="First" content="Content 1" />
      <Card title="Second" content="Content 2" />
    </div>
  );
}
```

## Children Prop

```jsx
function Container({ children }) {
  return <div className="container">{children}</div>;
}

// Usage
<Container>
  <p>This is a child</p>
</Container>
```

## Best Practices

- Keep components focused
- Use descriptive prop names
- Validate props with PropTypes
- Don't mutate props
- Extract complex components''',
      ),
      CourseModule(
        id: '3',
        title: 'State Management',
        duration: '32:45 mins',
        iconColor: 'lightOrange',
        videoUrl: 'assets/videos/ui_ux_explained.mp4',
        markdownDescription: '''# State Management

State management is crucial for building interactive React applications. Learn how to manage and update component state.

## What is State?

State is:
- **Component data**: Values that can change
- **Reactive**: UI updates when state changes
- **Local**: Belongs to specific component
- **Mutable**: Can be updated

## useState Hook

```jsx
import { useState } from 'react';

function Counter() {
  const [count, setCount] = useState(0);
  
  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={() => setCount(count + 1)}>
        Increment
      </button>
    </div>
  );
}
```

## State Updates

### Functional Updates:
```jsx
setCount(prevCount => prevCount + 1);
```

### Multiple State Variables:
```jsx
const [name, setName] = useState('');
const [age, setAge] = useState(0);
```

## Lifting State Up

When multiple components need the same state:

```jsx
function App() {
  const [count, setCount] = useState(0);
  
  return (
    <div>
      <Display count={count} />
      <Controls count={count} setCount={setCount} />
    </div>
  );
}
```

## Context API

For global state:

```jsx
const ThemeContext = createContext();

function App() {
  const [theme, setTheme] = useState('light');
  
  return (
    <ThemeContext.Provider value={{ theme, setTheme }}>
      <Content />
    </ThemeContext.Provider>
  );
}
```

## External State Management

### Redux:
- Predictable state container
- Centralized state
- Time-travel debugging

### Zustand:
- Lightweight
- Simple API
- Less boilerplate

## Best Practices

- Keep state as low as possible
- Use functional updates
- Avoid unnecessary re-renders
- Consider state management libraries for complex apps
- Normalize state structure''',
      ),
    ],
    questions: [
      Question(
        id: '1',
        question: 'What is React?',
        options: [
          'A database',
          'A JavaScript library for building user interfaces',
          'A programming language',
          'A design tool',
        ],
        correctAnswerIndex: 1,
      ),
    ],
  ),
  Course(
    id: '7',
    title: 'Python Programming Mastery',
    description: 'Master Python from basics to advanced concepts',
    category: 'Programming',
    duration: '10h 20min',
    rating: 4.7,
    students: 2100,
    isTrendy: false,
    isPremium: false,
    imageColor: 'indigo',
    modules: [
      CourseModule(
        id: '1',
        title: 'Python Basics',
        duration: '22:10 mins',
        iconColor: 'orange',
        videoUrl: 'assets/videos/ui_ux_explained.mp4',
        markdownDescription: '''# Python Basics

Python is a versatile, beginner-friendly programming language. Learn the fundamentals that form the foundation of Python programming.

## Why Python?

- **Readable**: Easy to understand syntax
- **Versatile**: Web, data science, AI, automation
- **Large Community**: Extensive libraries and support
- **In-Demand**: High job market value

## Basic Syntax

### Variables:
```python
name = "Alice"
age = 25
height = 5.6
is_student = True
```

### Data Types:
- **int**: Whole numbers
- **float**: Decimal numbers
- **str**: Text strings
- **bool**: True/False
- **list**: Ordered collections
- **dict**: Key-value pairs

## Control Flow

### Conditionals:
```python
if age >= 18:
    print("Adult")
elif age >= 13:
    print("Teenager")
else:
    print("Child")
```

### Loops:
```python
# For loop
for i in range(5):
    print(i)

# While loop
while count < 10:
    count += 1
```

## Functions

```python
def greet(name):
    return f"Hello, {name}!"

# Call function
message = greet("Alice")
```

## Getting Started

1. Install Python
2. Choose an IDE (VS Code, PyCharm)
3. Write your first program
4. Practice regularly
5. Build projects

## Best Practices

- Use meaningful variable names
- Write clear comments
- Follow PEP 8 style guide
- Test your code
- Read error messages carefully''',
      ),
      CourseModule(
        id: '2',
        title: 'Data Structures',
        duration: '38:25 mins',
        iconColor: 'lightOrange',
        videoUrl: 'assets/videos/ui_ux_explained.mp4',
        markdownDescription: '''# Data Structures

Data structures organize and store data efficiently. Understanding them is crucial for writing efficient Python programs.

## Lists

Ordered, mutable collections:

```python
fruits = ['apple', 'banana', 'orange']
fruits.append('grape')
fruits[0]  # 'apple'
```

### List Methods:
- `append()`: Add item
- `remove()`: Remove item
- `sort()`: Sort list
- `len()`: Get length

## Dictionaries

Key-value pairs:

```python
person = {
    'name': 'Alice',
    'age': 25,
    'city': 'New York'
}
person['name']  # 'Alice'
```

### Dictionary Methods:
- `keys()`: Get all keys
- `values()`: Get all values
- `items()`: Get key-value pairs
- `get()`: Safe access

## Tuples

Ordered, immutable collections:

```python
coordinates = (10, 20)
x, y = coordinates  # Unpacking
```

## Sets

Unordered, unique elements:

```python
unique_numbers = {1, 2, 3, 4, 5}
unique_numbers.add(6)
```

## Choosing the Right Structure

- **List**: Ordered, may have duplicates
- **Tuple**: Immutable, ordered
- **Set**: Unique elements, fast lookup
- **Dict**: Key-value mapping

## Common Operations

### List Comprehension:
```python
squares = [x**2 for x in range(10)]
```

### Dictionary Comprehension:
```python
squared = {x: x**2 for x in range(5)}
```

## Best Practices

- Choose appropriate structure
- Understand time complexity
- Use list comprehensions
- Leverage built-in methods
- Consider memory usage''',
      ),
      CourseModule(
        id: '3',
        title: 'Object-Oriented Programming',
        duration: '45:50 mins',
        iconColor: 'lightOrange',
        videoUrl: 'assets/videos/ui_ux_explained.mp4',
        markdownDescription: '''# Object-Oriented Programming

Object-Oriented Programming (OOP) organizes code around objects and classes. It's a powerful paradigm for building complex applications.

## Core Concepts

### Classes and Objects:
```python
class Dog:
    def __init__(self, name, breed):
        self.name = name
        self.breed = breed
    
    def bark(self):
        return f"{self.name} says Woof!"

# Create object
my_dog = Dog("Buddy", "Golden Retriever")
```

## The Four Pillars

### 1. Encapsulation
- Bundling data and methods
- Private attributes (use `_` prefix)
- Controlled access

### 2. Inheritance
```python
class Animal:
    def speak(self):
        pass

class Dog(Animal):
    def speak(self):
        return "Woof!"
```

### 3. Polymorphism
- Same interface, different implementations
- Method overriding
- Duck typing

### 4. Abstraction
- Hide complex implementation
- Show only essential features
- Abstract base classes

## Class Attributes vs Instance Attributes

```python
class Circle:
    pi = 3.14159  # Class attribute
    
    def __init__(self, radius):
        self.radius = radius  # Instance attribute
```

## Special Methods

```python
class Person:
    def __init__(self, name):
        self.name = name
    
    def __str__(self):
        return f"Person: {self.name}"
    
    def __repr__(self):
        return f"Person('{self.name}')"
```

## Best Practices

- Use meaningful class names
- Keep classes focused
- Use composition over inheritance
- Follow SOLID principles
- Document your classes''',
      ),
    ],
    questions: [
      Question(
        id: '1',
        question: 'Which of these is a Python data type?',
        options: [
          'int',
          'string',
          'list',
          'All of the above',
        ],
        correctAnswerIndex: 3,
      ),
    ],
  ),
  Course(
    id: '8',
    title: 'Unreal Engine 5 Basics',
    description: 'Create stunning games with Unreal Engine 5',
    category: 'Game Development',
    duration: '9h 10min',
    rating: 4.9,
    students: 890,
    isTrendy: true,
    isPremium: true,
    imageColor: 'red',
    modules: [
      CourseModule(
        id: '1',
        title: 'UE5 Interface Overview',
        duration: '15:30 mins',
        iconColor: 'orange',
        videoUrl: 'assets/videos/ui_ux_explained.mp4',
        markdownDescription: '''# UE5 Interface Overview

Unreal Engine 5 features a powerful interface designed for game development. This module introduces you to the essential panels and tools.

## Main Interface Panels

### Viewport
- 3D scene view
- Real-time preview
- Camera controls
- Object manipulation

### Content Browser
- Asset management
- Folder organization
- Search and filter
- Import/export

### World Outliner
- Scene hierarchy
- Object organization
- Selection management
- Visibility controls

### Details Panel
- Object properties
- Component management
- Transform controls
- Material assignment

### Toolbar
- Play/Pause simulation
- Build lighting
- Package project
- Quick actions

## Navigation Controls

- **Mouse**: Rotate view
- **Right-Click + Drag**: Pan view
- **Scroll Wheel**: Zoom
- **F**: Focus on selection
- **G**: Game view toggle

## Essential Workflows

1. **Creating Objects**: Drag from Content Browser
2. **Selecting**: Click in viewport or outliner
3. **Transforming**: Use gizmo handles
4. **Duplicating**: Ctrl+D or Alt+Drag
5. **Deleting**: Delete key

## Customization

- Rearrange panels
- Save layout presets
- Customize shortcuts
- Create custom toolbars

## Best Practices

- Organize assets in folders
- Use consistent naming
- Save frequently
- Learn keyboard shortcuts
- Customize your workspace''',
      ),
      CourseModule(
        id: '2',
        title: 'Blueprints Visual Scripting',
        duration: '40:20 mins',
        iconColor: 'lightOrange',
        videoUrl: 'assets/videos/ui_ux_explained.mp4',
        markdownDescription: '''# Blueprints Visual Scripting

Blueprints are Unreal Engine's visual scripting system. Create gameplay without writing code!

## What are Blueprints?

Blueprints are:
- **Visual**: Node-based scripting
- **Powerful**: Full game logic capability
- **Accessible**: No coding required
- **Fast**: Rapid prototyping

## Blueprint Types

### Level Blueprints
- Scene-specific logic
- Global events
- Level-wide interactions

### Class Blueprints
- Reusable objects
- Component-based
- Can be spawned

### Function Libraries
- Reusable functions
- Static methods
- Utility functions

## Basic Concepts

### Nodes
- **Events**: Trigger actions
- **Functions**: Perform operations
- **Variables**: Store data
- **Flow Control**: Conditionals and loops

### Example Blueprint:
```
Event BeginPlay
  → Print String "Hello World"
```

## Common Nodes

- **Print String**: Debug output
- **Set Variable**: Store values
- **Branch**: If/else logic
- **For Loop**: Iteration
- **Get Actor Location**: Access properties

## Variables

### Types:
- **Boolean**: True/False
- **Integer**: Whole numbers
- **Float**: Decimal numbers
- **String**: Text
- **Vector**: 3D coordinates
- **Object Reference**: Game objects

## Best Practices

- Organize nodes clearly
- Use comments
- Name variables descriptively
- Test frequently
- Reuse functions
- Learn from examples''',
      ),
      CourseModule(
        id: '3',
        title: 'Creating Your First Level',
        duration: '52:15 mins',
        iconColor: 'lightOrange',
        videoUrl: 'assets/videos/ui_ux_explained.mp4',
        markdownDescription: '''# Creating Your First Level

Build your first playable level in Unreal Engine 5. Learn the complete workflow from blank scene to finished level.

## Planning Your Level

Before building:
1. **Sketch** your layout
2. **Define** gameplay goals
3. **List** required assets
4. **Plan** player flow
5. **Consider** performance

## Building the Environment

### Step 1: Set Up Geometry
- Use BSP brushes for prototyping
- Create basic shapes
- Block out the level

### Step 2: Add Details
- Import or create meshes
- Place static meshes
- Add props and decorations

### Step 3: Lighting
- Place directional lights
- Add point lights for ambiance
- Use spotlights for focus
- Build lighting

### Step 4: Materials
- Apply base materials
- Create material instances
- Adjust properties

## Level Design Principles

### Flow
- Guide player movement
- Create clear paths
- Use visual cues

### Pacing
- Vary intensity
- Provide rest areas
- Build tension gradually

### Scale
- Appropriate proportions
- Comfortable spaces
- Epic moments

## Adding Gameplay

### Player Start
- Place Player Start actor
- Set spawn location
- Test player movement

### Triggers
- Create trigger volumes
- Add Blueprint logic
- Test interactions

### Collectibles
- Place pickup actors
- Add collection logic
- Create feedback

## Testing and Iteration

1. **Play Test**: Run through level
2. **Identify Issues**: Note problems
3. **Adjust**: Fix and improve
4. **Repeat**: Iterate until polished

## Best Practices

- Start simple
- Block out first
- Test frequently
- Get feedback early
- Optimize performance
- Document your process''',
      ),
    ],
    questions: [
      Question(
        id: '1',
        question: 'What is Blueprint in Unreal Engine?',
        options: [
          'A color scheme',
          'A visual scripting system',
          'A texture type',
          'A lighting system',
        ],
        correctAnswerIndex: 1,
      ),
    ],
  ),
];

List<Course> getTrendyCourses() {
  return allCourses.where((course) => course.isTrendy).toList();
}

List<Course> getBestOfTheWeek() {
  return allCourses.take(5).toList();
}

