//
//  TaskManager.swift
//  Task Master
//
//  Created by Manvi Gumber on 2025-02-15.
//

import Foundation
import CoreData
import UIKit

class TaskManager {
    static let shared = TaskManager() // Singleton instance
    
    // Reference to the Core Data context from AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    // MARK: - Create Task
    func saveTask(title: String, description: String, dueDate: Date, priority: String, category: String, status: String) {
        let newTask = Task(context: context)
        newTask.title = title
        newTask.taskDescription = description
        newTask.dueDate = dueDate
        newTask.priority = priority
        newTask.category = category
        newTask.status = status

        do {
            try context.save()
            print("✅ Task saved successfully")
        } catch {
            print("❌ Error saving task: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Fetch Tasks
    func fetchTasks() -> [Task] {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("❌ Error fetching tasks: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Update Task
    func updateTask(task: Task, title: String, description: String, dueDate: Date, priority: String, category: String, status: String) {
        task.title = title
        task.taskDescription = description
        task.dueDate = dueDate
        task.priority = priority
        task.category = category
        task.status = status
        
        do {
            try context.save()
            print("✅ Task updated successfully")
        } catch {
            print("❌ Error updating task: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Mark Task as Completed
    func markTaskAsCompleted(task: Task) {
        task.status = "Completed"
        
        do {
            try context.save()
            print("✅ Task marked as completed")
        } catch {
            print("❌ Error marking task as completed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Delete Task
    func deleteTask(task: Task) {
        context.delete(task)
        
        do {
            try context.save()
            print("✅ Task deleted successfully")
        } catch {
            print("❌ Error deleting task: \(error.localizedDescription)")
        }
    }
}
