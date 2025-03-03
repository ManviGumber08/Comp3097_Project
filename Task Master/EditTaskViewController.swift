//
//  EditTaskViewController.swift
//  Task Master
//
//  Created by Manvi Gumber on 2025-02-15.
//

import UIKit

class EditTaskViewController: UIViewController {

    var task: Task?
    
    // Allowed values (in lowercase) for validation.
    let allowedPriorities = ["high", "medium", "low"]
    let allowedCategories = ["work", "study", "health", "personal"]
    
    // UI Elements for the form.
    let titleTextField = UITextField()
    let descriptionTextField = UITextField()
    let priorityTextField = UITextField()
    let categoryTextField = UITextField()
    // Add a segmented control for All Day vs Specific.
    let modeSegmentedControl = UISegmentedControl(items: ["All Day", "Specific"])
    let dueDatePicker = UIDatePicker()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        self.title = "Edit Task"
        setupUI()
        populateFields()
        
        // Add Cancel and Save buttons.
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self,
                                                           action: #selector(cancelEditing))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                            target: self,
                                                            action: #selector(saveTask))
    }
    
    func setupUI() {
        // Configure text fields.
        titleTextField.borderStyle = .roundedRect
        titleTextField.placeholder = "Task Title"
        
        descriptionTextField.borderStyle = .roundedRect
        descriptionTextField.placeholder = "Description"
        
        priorityTextField.borderStyle = .roundedRect
        priorityTextField.placeholder = "Priority (High, Medium, Low)"
        
        categoryTextField.borderStyle = .roundedRect
        categoryTextField.placeholder = "Category (Work, Study, Health, Personal)"
        
        // Configure mode segmented control.
        modeSegmentedControl.selectedSegmentIndex = 1  // Default: Specific
        modeSegmentedControl.addTarget(self, action: #selector(dateModeChanged(_:)), for: .valueChanged)
        
        // Configure dueDatePicker.
        dueDatePicker.datePickerMode = .dateAndTime
        if #available(iOS 13.4, *) {
            dueDatePicker.preferredDatePickerStyle = .wheels
        }
        
        // Create a stack view containing all UI elements.
        let stackView = UIStackView(arrangedSubviews: [titleTextField, descriptionTextField, priorityTextField, categoryTextField, modeSegmentedControl, dueDatePicker])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    func populateFields() {
        guard let task = task else { return }
        titleTextField.text = task.title
        descriptionTextField.text = task.taskDescription
        priorityTextField.text = task.priority
        categoryTextField.text = task.category
        if let dueDate = task.dueDate {
            dueDatePicker.date = dueDate
        }
        // Optionally, if you store an all-day flag, update the segmented control.
        // For now, default to "Specific".
        modeSegmentedControl.selectedSegmentIndex = 1
        dueDatePicker.datePickerMode = .dateAndTime
    }
    
    @objc func dateModeChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            // All Day selected.
            dueDatePicker.datePickerMode = .date
        } else {
            // Specific selected.
            dueDatePicker.datePickerMode = .dateAndTime
        }
    }
    
    @objc func cancelEditing() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func saveTask() {
        guard let titleText = titleTextField.text, !titleText.isEmpty else {
            showErrorAlert(message: "Task title is required")
            return
        }
        
        // Validate priority.
        if let priority = priorityTextField.text, !allowedPriorities.contains(priority.lowercased()) {
            showErrorAlert(message: "Invalid Priority. Allowed values: High, Medium, Low")
            return
        }
        
        // Validate category.
        if let category = categoryTextField.text, !allowedCategories.contains(category.lowercased()) {
            showErrorAlert(message: "Invalid Category. Allowed values: Work, Study, Health, Personal")
            return
        }
        
        TaskManager.shared.updateTask(task: task!,
                                      title: titleText,
                                      description: descriptionTextField.text ?? "",
                                      dueDate: dueDatePicker.date,
                                      priority: priorityTextField.text ?? "",
                                      category: categoryTextField.text ?? "",
                                      status: task?.status ?? "Pending")
        navigationController?.popViewController(animated: true)
    }
    
    // Helper function to show error alerts.
    func showErrorAlert(message: String) {
        let errorAlert = UIAlertController(title: "Input Error", message: message, preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
        present(errorAlert, animated: true)
    }
}
