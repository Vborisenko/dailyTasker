# 👤 User Stories - Daily Tasker

## 📋 Overview
User stories describe application functionality from user perspective in "As a user I want to..." format.

## 🧭 Menu & Navigation

### As a user I want to access different sections of the app through bottom navigation
**Acceptance Criteria:**
- Bottom navigation with 4 sections: Home, Categories, Calendar, Settings
- Active section is visually highlighted
- Simple navigation between screens
- Smooth transitions between sections

### As a user I want to see the main dashboard with today's tasks
**Acceptance Criteria:**
- Main screen displays when app launches
- Today's task list is shown with priority order
- Date is prominently displayed
- Task completion counter is visible
- Add new task button is easily accessible

## 🏷️ Category Management

### As a user I want to create new categories for organizing my tasks
**Acceptance Criteria:**
- Simple form to create category with name
- Basic validation (name required, unique names)
- Category is immediately available for use
- Success feedback is provided

### As a user I want to edit existing category names
**Acceptance Criteria:**
- Long press (1 second) on category opens edit mode
- Can change category name
- Validation prevents duplicate names
- Changes are saved automatically

### As a user I want to delete categories when they're no longer needed
**Acceptance Criteria:**
- Long press (1 second) shows delete option
- Confirmation dialog warns about deleting related tasks
- All tasks in category are deleted with category
- Bulk deletion of multiple categories is supported

## ✅ Task Management

### As a user I want to create new tasks with comprehensive details
**Acceptance Criteria:**
- Form with title and description fields
- Priority selection (High, Medium, Low)
- Category assignment (choose existing or create new)
- Due date setting (defaults to today)
- Subtask creation option
- Basic validation (title required)

### As a user I want to edit existing tasks
**Acceptance Criteria:**
- Tap on task opens edit mode
- Can change title, description, priority, and category
- Subtasks can be added, removed, or modified
- Save button updates task
- Cancel button discards changes

### As a user I want to manage subtasks within main tasks
**Acceptance Criteria:**
- Create subtasks within main tasks
- Edit subtask title and description
- Mark subtasks as completed
- Delete individual subtasks
- See subtask completion counter
- Reorder subtasks by drag and drop

### As a user I want to delete tasks with confirmation
**Acceptance Criteria:**
- Swipe left on task shows delete option
- Confirmation dialog before deletion
- Subtasks are deleted with main task
- Task is removed from list after confirmation

### As a user I want to mark tasks as completed
**Acceptance Criteria:**
- Checkbox for each task
- Visual indication when task is completed
- Progress counter updates automatically
- Completed tasks can be hidden/shown

### As a user I want to reorder tasks and subtasks
**Acceptance Criteria:**
- Drag and drop to reorder tasks
- Long press + drag for quick reordering
- Smooth animations during reordering
- Snap-to-grid for precise positioning

### As a user I want to search and filter my tasks
**Acceptance Criteria:**
- Search by task title
- Filter by priority level
- Filter by completion status
- Filter by category
- Clear filters option
- Results update in real-time

### As a user I want to view tasks in calendar format
**Acceptance Criteria:**
- Calendar view shows dates with task counts
- Tap on date shows tasks for that day
- Tasks are displayed in priority order
- Simple date navigation
- Weekend days are visible

## ⚙️ App Settings

### As a user I want to control how completed tasks are displayed
**Acceptance Criteria:**
- Toggle to show/hide completed tasks
- Default view preference for app startup
- Setting is remembered between sessions

### As a user I want to customize category display preferences
**Acceptance Criteria:**
- Show/hide category labels on tasks
- Set default category for new tasks
- Setting is applied to all new tasks

### As a user I want to access app information and legal documents
**Acceptance Criteria:**
- App version is displayed
- Build number is visible
- Developer information is accessible
- Privacy policy link is working
- Terms of service link is working

---

**Total Stories:** 25
**Completed:** 25 ✅
**Remaining:** 0
