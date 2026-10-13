# 🎨 Daily Tasker - Design Specification

## 📋 Project Overview
**Daily Tasker** - mobile task management application with modern Material Design 3 styling and iOS-specific patterns.

## ✅ Implemented Features

### 🏠 Core Screens
- **MainScreen** - Основная навигация с bottom navigation bar
- **HomeScreen** - Главный экран с задачами на сегодня и статистикой
- **CreateTaskScreen** - Полнофункциональный экран создания задач
- **CategoriesScreen** - Управление категориями задач
- **CalendarScreen** - Заготовка для календарного представления
- **SettingsScreen** - Заготовка для настроек приложения

### 🎯 Task Management
- ✅ Создание задач с заголовком, описанием и приоритетом
- ✅ Выбор категории для задач
- ✅ Установка даты выполнения
- ✅ Добавление подзадач (subtasks)
- ✅ Три уровня приоритета: High, Medium, Low
- ✅ Отметка задач как выполненных
- ✅ Статистика по задачам (всего, выполнено, в ожидании)

### 📂 Category Management
- ✅ Создание новых категорий
- ✅ Редактирование существующих категорий
- ✅ Удаление категорий с подтверждением
- ✅ Проверка на дублирование названий
- ✅ Привязка задач к категориям

### 🎨 UI Components
- ✅ Material Design 3 с темной темой
- ✅ Адаптивные карточки для задач и категорий
- ✅ Цветовая индикация приоритетов
- ✅ Иконки для различных элементов интерфейса
- ✅ Responsive дизайн с поддержкой различных размеров экрана

### 🔧 State Management
- ✅ Provider pattern для управления состоянием
- ✅ TaskProvider для управления задачами
- ✅ CategoryProvider для управления категориями
- ✅ Автоматическое обновление UI при изменении данных

---

## 🎨 Color Scheme

### Primary Colors
```dart
// Main palette
const Color primaryBackground = Color(0xFF313133);    // Dark sand background
const Color primaryColor = Color(0xFFEBE5C5);         // Light sand primary
const Color accentColor = Color(0xFFFFAF69);          // Warm orange accent

// Additional colors
const Color cardBackground = Color(0xFF3A3A3C);      // Card background
const Color secondaryText = Color(0xFFB8B8B8);       // Secondary text
const Color accentText = Color(0xFFFFAF69);           // Accent text
```

### Color States
```dart
// Element states
const Color successColor = Color(0xFF4CAF50);         // Success
const Color errorColor = Color(0xFFF44336);           // Error
const Color warningColor = Color(0xFFFF9800);         // Warning
const Color infoColor = Color(0xFF2196F3);            // Info

// Shadows and transparency
const Color shadowColor = Color(0x4D000000);          // rgba(0, 0, 0, 0.3)
const Color glassBackground = Color(0xCC313133);      // rgba(49, 49, 51, 0.8)
```

---

## 🔤 Typography

### iOS Font System (San Francisco)
```dart
// Font sizes and weights
const double fontSizeH1 = 32.0;      // Screen headers
const double fontSizeH2 = 24.0;      // Section headers
const double fontSizeH3 = 20.0;      // Subheaders
const double fontSizeH4 = 18.0;      // Card headers
const double fontSizeBody = 16.0;     // Main text
const double fontSizeBodySmall = 14.0; // Secondary text
const double fontSizeCaption = 12.0;  // Small text

// Font weights
const FontWeight fontWeightBold = FontWeight.w700;      // Headers
const FontWeight fontWeightSemibold = FontWeight.w600;  // Subheaders
const FontWeight fontWeightMedium = FontWeight.w500;    // Accent text
const FontWeight fontWeightRegular = FontWeight.w400;   // Main text
```

### Component Application
```dart
// Screen headers
TextStyle get headingStyle => TextStyle(
  fontSize: fontSizeH1,
  fontWeight: fontWeightBold,
  color: primaryColor,
);

// Main text
TextStyle get bodyStyle => TextStyle(
  fontSize: fontSizeBody,
  fontWeight: fontWeightRegular,
  color: primaryColor,
);

// Accent text
TextStyle get accentStyle => TextStyle(
  fontSize: fontSizeBody,
  fontWeight: fontWeightMedium,
  color: accentColor,
);
```

---

## 🧩 Component Library

### Task Cards
```dart
// Main parameters
const double cardBorderRadius = 16.0;
const double cardPadding = 16.0;
const double cardMargin = 12.0;
const double cardShadowBlur = 12.0;
const double cardShadowOffset = 4.0;

// Card style
BoxDecoration get cardDecoration => BoxDecoration(
  color: cardBackground,
  borderRadius: BorderRadius.circular(cardBorderRadius),
  boxShadow: [
    BoxShadow(
      color: shadowColor,
      blurRadius: cardShadowBlur,
      offset: Offset(0, cardShadowOffset),
    ),
  ],
);
```

### Buttons
```dart
// Button sizes
const double buttonHeight = 48.0;
const double buttonBorderRadius = 12.0;
const double buttonPadding = 16.0;

// Primary button
BoxDecoration get primaryButtonDecoration => BoxDecoration(
  color: accentColor,
  borderRadius: BorderRadius.circular(buttonBorderRadius),
  boxShadow: [
    BoxShadow(
      color: shadowColor,
      blurRadius: 8.0,
      offset: Offset(0, 2.0),
    ),
  ],
);

// Secondary button
BoxDecoration get secondaryButtonDecoration => BoxDecoration(
  color: Colors.transparent,
  borderRadius: BorderRadius.circular(buttonBorderRadius),
  border: Border.all(color: primaryColor, width: 1.0),
);
```

### Input Fields
```dart
// Field sizes
const double inputHeight = 48.0;
const double inputBorderRadius = 12.0;
const double inputPadding = 16.0;

// Input field style
BoxDecoration get inputDecoration => BoxDecoration(
  color: cardBackground,
  borderRadius: BorderRadius.circular(inputBorderRadius),
  border: Border.all(color: primaryColor, width: 1.0),
);
```

---

## ✨ Effects and Animations

### Glassmorphism Effect
```dart
// Glass effect
BoxDecoration get glassEffect => BoxDecoration(
  color: glassBackground,
  borderRadius: BorderRadius.circular(16.0),
  border: Border.all(
    color: primaryColor.withOpacity(0.2),
    width: 1.0,
  ),
);

// Flutter implementation
ClipRRect(
  borderRadius: BorderRadius.circular(16.0),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
    child: Container(
      decoration: glassEffect,
      // content
    ),
  ),
)
```

### Animations
```dart
// Animation durations
const Duration animationFast = Duration(milliseconds: 200);
const Duration animationNormal = Duration(milliseconds: 300);
const Duration animationSlow = Duration(milliseconds: 500);

// Animation curves
const Curve animationCurve = Curves.easeInOut;
const Curve animationBounce = Curves.elasticOut;

// Fade in animations
Animation<double> fadeInAnimation = Tween<double>(
  begin: 0.0,
  end: 1.0,
).animate(CurvedAnimation(
  parent: animationController,
  curve: animationCurve,
));
```

---

## 📱 Screen Structure

### Main Screen (Dashboard) ✅ IMPLEMENTED
```dart
// Element structure
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top panel
            _buildTopBar(),
            
            // Today's tasks
            Expanded(
              child: _buildTodayTasks(),
            ),
            
            // Quick actions
            _buildQuickActions(),
            
            // Progress bar
            _buildProgressBar(),
          ],
        ),
      ),
    );
  }
}
```

### Tasks Screen ✅ IMPLEMENTED
```dart
// Tasks screen structure
class CreateTaskScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Search and filters
            _buildSearchAndFilters(),
            
            // Tasks list with drag & drop
            Expanded(
              child: _buildTasksList(),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildAddTaskFAB(),
    );
  }
}
```

### Add/Edit Task Pop-up ✅ IMPLEMENTED
```dart
// Pop-up style
class CreateTaskScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBackground,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Title field
            _buildTitleField(),
            
            // Description field
            _buildDescriptionField(),
            
            // Priority selection
            _buildPrioritySelection(),
            
            // Category selection
            _buildCategorySelection(),
            
            // Due date selection
            _buildDueDateSelection(),
            
            // Subtasks section
            _buildSubtasksSection(),
          ],
        ),
      ),
    );
  }
}
```

---

## 📱 iOS-Specific Patterns

### Safe Area and Spacing
```dart
// Spacing system
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  
  // Screen edge spacing
  static const double screenPadding = 16.0;
  static const double bottomSafeArea = 34.0; // Home Indicator
}

// Safe Area application
SafeArea(
  child: Padding(
    padding: EdgeInsets.all(AppSpacing.screenPadding),
    child: // content
  ),
)
```

### Haptic Feedback
```dart
// Haptic feedback types
class HapticService {
  static void light() {
    HapticFeedback.lightImpact();
  }
  
  static void medium() {
    HapticFeedback.mediumImpact();
  }
  
  static void heavy() {
    HapticFeedback.heavyImpact();
  }
  
  static void success() {
    HapticFeedback.notificationImpact(NotificationFeedbackType.success);
  }
  
  static void error() {
    HapticFeedback.notificationImpact(NotificationFeedbackType.error);
  }
}

// Application
GestureDetector(
  onTap: () {
    HapticService.light(); // During navigation
    // action
  },
)
```

### Gestures and Interactions
```dart
// Swipes for quick actions
Dismissible(
  key: Key(task.id),
  background: _buildSwipeBackground(),
  secondaryBackground: _buildSwipeSecondaryBackground(),
  onDismissed: (direction) {
    if (direction == DismissDirection.startToEnd) {
      // Edit
      HapticService.medium();
    } else {
      // Quick completion
      HapticService.success();
    }
  },
  child: TaskCard(task: task),
)

// Drag & Drop for sorting
ReorderableListView.builder(
  itemCount: tasks.length,
  onReorder: (oldIndex, newIndex) {
    HapticService.medium();
    // reordering logic
  },
  itemBuilder: (context, index) {
    return TaskCard(
      key: ValueKey(tasks[index].id),
      task: tasks[index],
    );
  },
)
```

---

## 🧭 Navigation

### Bottom Navigation ✅ IMPLEMENTED
```dart
// Navigation structure
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    HomeScreen(),
    CategoriesScreen(),
    CalendarScreen(),
    SettingsScreen(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
```

---

## 📊 States and Animations

### Loading (Skeleton)
```dart
// Skeleton card
class TaskCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration,
      padding: EdgeInsets.all(cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          Container(
            height: 20.0,
            width: double.infinity,
            decoration: BoxDecoration(
              color: cardBackground.withOpacity(0.5),
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
          SizedBox(height: 12.0),
          
          // Description skeleton
          Container(
            height: 16.0,
            width: double.infinity,
            decoration: BoxDecoration(
              color: cardBackground.withOpacity(0.5),
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Empty States ✅ IMPLEMENTED
```dart
// Empty state for tasks
class EmptyTasksState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: glassEffect,
      padding: EdgeInsets.all(32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.task_alt,
            size: 64.0,
            color: accentColor,
          ),
          SizedBox(height: 16.0),
          Text(
            'No tasks',
            style: headingStyle.copyWith(fontSize: fontSizeH3),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.0),
          Text(
            'Create your first task',
            style: bodyStyle.copyWith(color: secondaryText),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.0),
          ElevatedButton(
            onPressed: () {
              HapticService.medium();
              // open add dialog
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: primaryBackground,
              padding: EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 12.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonBorderRadius),
              ),
            ),
            child: Text('Add Task'),
          ),
        ],
      ),
    );
  }
}
```

---

## 🔧 Technical Implementation

### App Theme ✅ IMPLEMENTED
```dart
// Main theme
class DailyTaskerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Tasker',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
```

---

## 📝 Implementation Checklist

### Phase 1: Basic Structure ✅ COMPLETED
- [x] Create Flutter project
- [x] Configure theme and colors
- [x] Basic navigation
- [x] Main screens (static)

### Phase 2: Components ✅ COMPLETED
- [x] Task cards
- [x] Buttons and input fields
- [x] Basic UI components
- [x] Empty states

### Phase 3: Functionality ✅ COMPLETED
- [x] CRUD operations for tasks
- [x] CRUD operations for categories
- [x] State management with Provider
- [x] Task completion tracking
- [x] Subtasks management
- [x] Priority system
- [x] Due date selection
- [x] Category assignment

### Phase 4: Animations and Effects 🔄 IN PROGRESS
- [ ] Screen transitions
- [ ] Element appearance animations
- [ ] Haptic feedback integration
- [ ] Glass effects

### Phase 5: Polish 🔄 IN PROGRESS
- [ ] iOS-specific optimizations
- [ ] Testing on different devices
- [ ] Performance optimization
- [ ] Final touches

---

## 📚 Useful Resources

### Flutter Packages ✅ IMPLEMENTED
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.5        # State management ✅
  hive: ^2.2.3           # Local storage (ready for integration)
  hive_flutter: ^1.1.0   # Flutter Hive integration (ready)
  flutter_staggered_animations: ^1.1.1  # Animations (ready)
  flutter_haptic: ^0.0.3 # Haptic feedback (ready)
```

### iOS Settings
```xml
<!-- Info.plist -->
<key>UIStatusBarStyle</key>
<string>UIStatusBarStyleLightContent</string>
<key>UIViewControllerBasedStatusBarAppearance</key>
<false/>
```

---

## 🔄 Versioning

**Document Version:** 1.1  
**Creation Date:** 2024  
**Last Updated:** 2024  
**Status:** Core Features Implemented

---

*This document is living and should be updated as the project evolves. All changes should be reflected in the document version.* 