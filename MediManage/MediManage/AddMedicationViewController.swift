import UIKit

protocol AddMedicationDelegate: AnyObject {
    func didAddMedication(_ medication: Medication)
}

class AddMedicationViewController: UIViewController {
    
    weak var delegate: AddMedicationDelegate?
    
    private let nameTextField = UITextField()
    private let dosageTextField = UITextField()
    private let timePicker = UIDatePicker()
    private var selectedDays: [DayOfWeek] = []
    
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Medication"
        view.backgroundColor = .white
        
        setupTextFields()
        setupTimePicker()
        setupTableView()
        setupSaveButton()
        setupToolbar()
    }
    
    private func setupTextFields() {
        nameTextField.placeholder = "Medication Name"
        nameTextField.borderStyle = .roundedRect
        view.addSubview(nameTextField)
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Setup dosage text field
        dosageTextField.placeholder = "Dosage"
        dosageTextField.borderStyle = .roundedRect
        view.addSubview(dosageTextField)
        dosageTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dosageTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            dosageTextField.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            dosageTextField.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            dosageTextField.heightAnchor.constraint(equalTo: nameTextField.heightAnchor)
        ])
    }
    
    private func setupTimePicker() {
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .compact
        view.addSubview(timePicker)
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timePicker.topAnchor.constraint(equalTo: dosageTextField.bottomAnchor, constant: 20),
            timePicker.leadingAnchor.constraint(equalTo: dosageTextField.leadingAnchor),
            timePicker.trailingAnchor.constraint(equalTo: dosageTextField.trailingAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: timePicker.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: timePicker.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: timePicker.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupSaveButton() {
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveMedication))
        navigationItem.rightBarButtonItem = saveButton
    }
    
    private func setupToolbar() {
        let dailyButton = UIBarButtonItem(title: "Daily", style: .plain, target: self, action: #selector(selectDaily))
        let deselectAllButton = UIBarButtonItem(title: "Deselect All", style: .plain, target: self, action: #selector(deselectAll))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarItems = [dailyButton, space, deselectAllButton]
        navigationController?.isToolbarHidden = false
    }
    
    @objc private func deselectAll() {
        selectedDays.removeAll()
        tableView.reloadData()
    }
    
    @objc private func selectDaily() {
        selectedDays = DayOfWeek.allCases
        tableView.reloadData()
    }
    
    @objc private func saveMedication() {
        guard let name = nameTextField.text, !name.isEmpty,
              let dosage = dosageTextField.text, !dosage.isEmpty else {
            // Show alert for invalid input
            let alertController = UIAlertController(title: "Error", message: "Please enter medication name and dosage", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
            return
        }
        
        if !selectedDays.isEmpty {
            let medication = Medication(name: name, dosage: dosage, timeOfDay: timePicker.date, selectedDaysOfWeek: selectedDays)
            delegate?.didAddMedication(medication)
            navigationController?.popViewController(animated: true)
        } else {
            // Show alert for selecting at least one day
            let alertController = UIAlertController(title: "Error", message: "Please select at least one day for the medication", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }
}

extension AddMedicationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DayOfWeek.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let day = DayOfWeek.allCases[indexPath.row]
        cell.textLabel?.text = day.rawValue.capitalized
        if selectedDays.contains(day) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedDay = DayOfWeek.allCases[indexPath.row]
        
        // Toggle selection: if it's already selected, remove it; otherwise, add it
        if selectedDays.contains(selectedDay) {
            if let indexToRemove = selectedDays.firstIndex(of: selectedDay) {
                selectedDays.remove(at: indexToRemove)
            }
        } else {
            selectedDays.append(selectedDay)
        }
        
        tableView.reloadData()
    }
}

