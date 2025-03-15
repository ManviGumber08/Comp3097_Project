# Comp3097_Project
Task Master
Project Design Document
CRN: 54621

Team Information
Manvi Gumber - 101412099
Tenzin Thinley - 101454475

Application Overview
Task Master is a To-Do List & Task Management app designed for users to efficiently organize, categorize, and track tasks. It includes task prioritization, deadline alerts, and persistent storage using Core Data.

Key Features
Task Categories – Users can group tasks (Work, Personal, Shopping, etc.) or create custom categories.
Task Creation – Users can add tasks with a title, description, due date, and priority level.
Task Tracking – Tasks are categorized as upcoming, in-progress, overdue, or completed.
Notifications & Alerts – Reminders for upcoming or overdue tasks.
Persistent Storage – Tasks are saved using Core Data for data retention.
Filtering & Sorting – Tasks can be filtered by category, due date, or priority.
Reminders – Alerts help users stay on top of daily tasks.

Screens & Functionalities
1. Home Screen
Displays a welcome message and "View Tasks" button.
2. Task List Screen (TableViewController)
Displays tasks with title, due date, and priority.
Overdue tasks appear in red.
Users can select a specific time or set an all-day reminder.
Includes an option to add a new task.
3. Edit Task Screen
Users can modify task details (title, description, priority, category, due date).
Options to save or cancel edits.
4. Launch Screen
Displays app name, team members, and logo.

Data Storage
Stored Task Attributes:
- Task Title
- Description
- Priority (High, Medium, Low)
- Category (Work, Personal, Others)
- Due Date
- Completion Status
Storage Mechanism: Core Data (for efficient local data persistence and querying).

GUI Implementation
Built using UIKit and connected via Navigation Controller in Main.storyboard.
UI elements (buttons, labels, views) are created programmatically using UIView, UILabel, UIButton, etc.
Adheres to Apple’s Human Interface Guidelines (HIG).
Navigation
Home Screen → Task List Screen (via Show segue).
Task List Screen → Edit Task Screen (via Show segue with identifier "editTaskSegue").
Save Button in Edit Task Screen persists task data.
