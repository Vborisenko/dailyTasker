# 📊 Data Models - Daily Tasker

## 📋 Overview
Description of all data models, their characteristics and relationships in Daily Tasker application.

## 🎯 Core Models

### Task
Main model for representing user task.

**Characteristics:**
- `id` (String) - unique task identifier
- `title` (String) - task title (required)
- `description` (String?) - task description (optional)
- `priority` (Priority) - task priority (High, Medium, Low)
- `isCompleted` (bool) - completion status
- `createdAt` (DateTime) - creation date
- `dueDate` (DateTime?) - due date (optional)

**Relationships:**
- Belongs to a specific date
- Has priority level

### Priority
Enum for defining task priority.

**Values:**
- `High` - high priority
- `Medium` - medium priority  
- `Low` - low priority

## 🗄️ Database Structure

### Main tables:
1. **tasks** - tasks

### Indexes:
- `tasks.due_date` - for fast date search
- `tasks.priority` - for priority filtering
- `tasks.is_completed` - for completion status

## 📱 Data Flow

### Task creation:
1. User fills the form
2. Data validation
3. Create `Task` object
4. Save to local database
5. Update UI

### Task completion:
1. User marks task as complete
2. Update `Task` object
3. Save to database
4. Update UI and counters

### Task editing:
1. User edits task
2. Validate changes
3. Update `Task` object
4. Save to database
5. Update UI
