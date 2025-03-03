//
//  TableViewController.swift
//  Task Master
//
//  Created by Manvi Gumber on 2025-02-15.
//

import UIKit
import CoreData

class TableViewController: UITableViewController {

    var tasks: [Task] = []
    var selectedDueDate: Date = Date()
    
    // Allowed values (in lowercase) for validation.
    let allowedPriorities = ["high", "medium", "low"]
    let allowedCategories = ["work", "study", "health", "personal"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Task List"
        
        // Use subtitle style cells – don't register a default cell.
        // Add "Add" button on the right and built-in Edit button on the left.
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addTask))
        navigationItem.leftBarButtonItem = editButtonItem
        
        // Set table view background to off white/light gray.
        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        
        fetchTasks()
    }
    
    func fetchTasks() {
        tasks = TaskManager.shared.fetchTasks()
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellIdentifier = "TaskCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        guard let cell = cell else { return UITableViewCell() }
        
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.title
        
        // Set text color based on priority.
        if let priority = task.priority?.lowercased() {
            switch priority {
            case "high":
                cell.textLabel?.textColor = .red
            case "medium":
                cell.textLabel?.textColor = .blue
            case "low":
                cell.textLabel?.textColor = .green
            default:
                cell.textLabel?.textColor = .black
            }
        } else {
            cell.textLabel?.textColor = .black
        }
        
        // Detail text: show category and due date.
        var detailText = ""
        if let category = task.category, !category.isEmpty {
            detailText += category
        }
        if let dueDate = task.dueDate {
            let formatter = DateFormatter()
            // If the event is "all day" we might show only the date.
            // (In this sample we always show date and time; you could improve this by storing an allDay flag.)
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            detailText += " • " + formatter.string(from: dueDate)
        }
        cell.detailTextLabel?.text = detailText
        cell.detailTextLabel?.textColor = .darkGray
        
        // Show a checkmark if the task is completed.
        cell.accessoryType = (task.status == "Completed") ? .checkmark : .none
        
        // If overdue and not completed, tint cell background; otherwise use off white.
        if let dueDate = task.dueDate, task.status != "Completed" {
            cell.backgroundColor = dueDate < Date() ? UIColor.systemRed.withAlphaComponent(0.3) : UIColor(white: 0.95, alpha: 1.0)
        } else {
            cell.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        }
        
        return cell
    }
    
    // Tapping a cell toggles the task’s completion status.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        if task.status == "Completed" {
            TaskManager.shared.updateTask(task: task,
                                          title: task.title ?? "",
                                          description: task.taskDescription ?? "",
                                          dueDate: task.dueDate ?? Date(),
                                          priority: task.priority ?? "",
                                          category: task.category ?? "",
                                          status: "Pending")
        } else {
            TaskManager.shared.markTaskAsCompleted(task: task)
        }
        fetchTasks()
    }
    
    // MARK: - Swipe Actions for Delete and Edit
    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
                            -> UISwipeActionsConfiguration? {
        
        // Delete Action.
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in
            let task = self.tasks[indexPath.row]
            TaskManager.shared.deleteTask(task: task)
            self.fetchTasks()
            completionHandler(true)
        }
        
        // Edit Action: Push the EditTaskViewController.
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (_, _, completionHandler) in
            let editVC = EditTaskViewController()
            editVC.task = self.tasks[indexPath.row]
            self.navigationController?.pushViewController(editVC, animated: true)
            completionHandler(true)
        }
        editAction.backgroundColor = .systemBlue
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    // MARK: - Add New Task
    @objc func addTask() {
        selectedDueDate = Date()
        
        let alert = UIAlertController(title: "New Task", message: "Enter task details", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Task title" }
        alert.addTextField { $0.placeholder = "Description" }
        alert.addTextField { $0.placeholder = "Priority (High, Medium, Low)" }
        alert.addTextField { $0.placeholder = "Category (Work, Study, Health, Personal)" }
        
        // Due Date text field with a UIDatePicker as its inputView.
        alert.addTextField { textField in
            textField.placeholder = "Due Date"
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            textField.text = formatter.string(from: self.selectedDueDate)
            
            let datePicker = UIDatePicker()
            // Default to Specific (date and time)
            datePicker.datePickerMode = .dateAndTime
            if #available(iOS 13.4, *) {
                datePicker.preferredDatePickerStyle = .wheels
            }
            textField.inputView = datePicker
            
            // Create a toolbar that contains a segmented control and a Done button.
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            
            let segmentedControl = UISegmentedControl(items: ["All Day", "Specific"])
            segmentedControl.selectedSegmentIndex = 1  // Default is Specific
            segmentedControl.addTarget(self, action: #selector(self.dateModeChanged(_:)), for: .valueChanged)
            let segmentedItem = UIBarButtonItem(customView: segmentedControl)
            
            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.donePressed))
            
            toolbar.setItems([segmentedItem, flexSpace, doneButton], animated: true)
            textField.inputAccessoryView = toolbar
            
            // When date picker changes, update selectedDueDate and text field.
            datePicker.addTarget(self, action: #selector(self.datePickerChanged(_:)), for: .valueChanged)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
            guard let titleText = alert.textFields?[0].text,
                  let descText = alert.textFields?[1].text,
                  let priorityText = alert.textFields?[2].text,
                  let categoryText = alert.textFields?[3].text,
                  !titleText.isEmpty else { return }
            
            // Validate priority.
            if !self.allowedPriorities.contains(priorityText.lowercased()) {
                self.showErrorAlert(message: "Invalid Priority. Allowed values: High, Medium, Low")
                return
            }
            // Validate category.
            if !self.allowedCategories.contains(categoryText.lowercased()) {
                self.showErrorAlert(message: "Invalid Category. Allowed values: Work, Study, Health, Personal")
                return
            }
            
            TaskManager.shared.saveTask(title: titleText,
                                        description: descText,
                                        dueDate: self.selectedDueDate,
                                        priority: priorityText,
                                        category: categoryText,
                                        status: "Pending")
            self.fetchTasks()
        }))
        
        present(alert, animated: true)
    }
    
    @objc func donePressed() {
        self.view.endEditing(true)
    }
    
    @objc func datePickerChanged(_ sender: UIDatePicker) {
        selectedDueDate = sender.date
        if let alert = presentedViewController as? UIAlertController,
           let dateTextField = alert.textFields?.last {
            let formatter = DateFormatter()
            // Adjust format based on the picker mode.
            if sender.datePickerMode == .date {
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
            } else {
                formatter.dateStyle = .medium
                formatter.timeStyle = .short
            }
            dateTextField.text = formatter.string(from: sender.date)
        }
    }
    
    @objc func dateModeChanged(_ sender: UISegmentedControl) {
        // Update the date picker's mode in the active due date text field.
        if let alert = self.presentedViewController as? UIAlertController,
           let dueDateTextField = alert.textFields?.last,
           let datePicker = dueDateTextField.inputView as? UIDatePicker {
            if sender.selectedSegmentIndex == 0 {
                // All Day selected: show date only.
                datePicker.datePickerMode = .date
            } else {
                // Specific selected: show date and time.
                datePicker.datePickerMode = .dateAndTime
            }
            // Force the datePicker to send a value changed event.
            datePicker.sendActions(for: .valueChanged)
        }
    }
    
    // Helper to show error alerts.
    func showErrorAlert(message: String) {
        let errorAlert = UIAlertController(title: "Input Error", message: message, preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
        present(errorAlert, animated: true)
    }
}
