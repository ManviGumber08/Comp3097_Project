//
//  EditTaskViewController.swift
//  Task Master
//
//  Created by Manvi Gumber on 2025-02-15.
//

import UIKit

class EditTaskViewController: UIViewController {

    // MARK: - Properties

    var task: Task?

    private let allowedPriorities = ["high", "medium", "low"]
    private let allowedCategories = ["work", "study", "health", "personal"]

    // MARK: - UI Elements

    private let titleTextField = UITextField()
    private let descriptionTextField = UITextField()
    private let priorityTextField = UITextField()
    private let categoryTextField = UITextField()
    private let modeSegmentedControl = UISegmentedControl(items: ["All Day", "Specific"])
    private let dueDatePicker = UIDatePicker()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        title = "Edit Task"
        setupUI()
        populateFields()
        setupNavigationBar()
    }

    // MARK: - UI Setup

    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelEditing)
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(saveTask)
        )
    }

    private func setupUI() {
        configureTextFields()
        configureSegmentedControl()
        configureDatePicker()

        let stackView = UIStackView(arrangedSubviews: [
            titleTextField,
            descriptionTextField,
            priorityTextField,
            categoryTextField,
            modeSegmentedControl,
            dueDatePicker
        ])
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

    private func configureTextFields() {
        [titleTextField, descriptionTextField, priorityTextField, categoryTextField].forEach {
            $0.borderStyle = .roundedRect
        }

        titleTextField.placeholder = "Task Title"
        descriptionTextField.placeholder = "Description"
        priorityTextField.placeholder = "Priority (High, Medium, Low)"
        categoryTextField.placeholder = "Category (Work, Study, Health, Personal)"
    }

    private func configureSegmentedControl() {
        modeSegmentedControl.selectedSegmentIndex = 1 // Default: Specific
        modeSegmentedControl.addTarget(self, action: #selector(dateModeChanged(_:)), for: .valueChanged)
    }

    private func configureDatePicker() {
        dueDatePicker.datePickerMode = .dateAndTime
        if #available(iOS 13.4, *) {
            dueDatePicker.preferredDatePickerStyle = .wheels
        }
    }

    // MARK: - Populate Fields

    private func populateFields() {
        guard let task = task else { return }

        titleTextField.text = task.title
        descriptionTextField.text = task.taskDescription
        priorityTextField.text = task.priority
        categoryTextField.text = task.category

        if let dueDate = task.dueDate {
            dueDatePicker.date = dueDate
        }

        // Default to "Specific" mode
        modeSegmentedControl.selectedSegmentIndex = 1
        dueDatePicker.datePickerMode = .dateAndTime
    }

    // MARK: - Actions

    @objc private func dateModeChanged(_ sender: UISegmentedControl) {
        dueDatePicker.datePickerMode = sender.selectedSegmentIndex == 0 ? .date : .dateAndTime
    }

    @objc private func cancelEditing() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func saveTask() {
        guard let title = titleTextField.text, !title.isEmpty else {
            showErrorAlert(message: "Task title is required.")
            return
        }

        let priority = priorityTextField.text?.lowercased() ?? ""
        let category = categoryTextField.text?.lowercased() ?? ""

        guard allowedPriorities.contains(priority) else {
            showErrorAlert(message: "Invalid Priority. Allowed values: High, Medium, Low.")
            return
        }

        guard allowedCategories.contains(category) else {
            showErrorAlert(message: "Invalid Category. Allowed values: Work, Study, Health, Personal.")
            return
        }

        guard let task = task else { return }

        TaskManager.shared.updateTask(
            task: task,
            title: title,
            description: descriptionTextField.text ?? "",
            dueDate: dueDatePicker.date,
            priority: priority,
            category: category,
            status: task.status ?? "Pending"
        )

        navigationController?.popViewController(animated: true)
    }

    // MARK: - Helper

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Input Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
