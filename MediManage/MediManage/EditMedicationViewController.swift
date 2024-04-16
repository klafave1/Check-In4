import UIKit

protocol EditMedicationDelegate: AnyObject {
    func didEditMedication()
}

class EditMedicationViewController: UIViewController {
    weak var delegate: EditMedicationDelegate?
    var medication: Medication?
    
    private let nameTextField = UITextField()
    private let dosageTextField = UITextField()
    private let timePicker = UIDatePicker()
    private let daysOfWeekTableView = UITableView()
    private var selectedDays: [DayOfWeek] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit Medication"
        view.backgroundColor = .white
        
        setupTextFields()
        setupTimePicker()
        setupDaysOfWeekTableView()
        setupSaveButton()
        setupToolbar()
    }
    
    private func setupTextFields() {
        guard let medication = medication else { return }
        
        nameTextField.placeholder = "Medication Name"
        nameTextField.text = medication.name
        nameTextField.borderStyle = .roundedRect
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameTextField)
        
        dosageTextField.placeholder = "Dosage"
        dosageTextField.text = medication.dosage
        dosageTextField.borderStyle = .roundedRect
        dosageTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dosageTextField)
        
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 40),
            
            dosageTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            dosageTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dosageTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            dosageTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupTimePicker() {
        guard let medication = medication else { return }
        
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .compact
        timePicker.date = medication.timeOfDay ?? Date()
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timePicker)
        
        NSLayoutConstraint.activate([
            timePicker.topAnchor.constraint(equalTo: dosageTextField.bottomAnchor, constant: 20),
            timePicker.leadingAnchor.constraint(equalTo: dosageTextField.leadingAnchor),
            timePicker.trailingAnchor.constraint(equalTo: dosageTextField.trailingAnchor)
        ])
    }
    
    private func setupDaysOfWeekTableView() {
        daysOfWeekTableView.delegate = self
        daysOfWeekTableView.dataSource = self
        daysOfWeekTableView.allowsMultipleSelection = true
        daysOfWeekTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        daysOfWeekTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(daysOfWeekTableView)
        
        NSLayoutConstraint.activate([
            daysOfWeekTableView.topAnchor.constraint(equalTo: timePicker.bottomAnchor, constant: 20),
            daysOfWeekTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            daysOfWeekTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            daysOfWeekTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
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
    
    @objc private func saveMedication() {
        guard let name = nameTextField.text, !name.isEmpty,
              let dosage = dosageTextField.text, !dosage.isEmpty else { return }
        
        medication?.name = name
        medication?.dosage = dosage
        medication?.timeOfDay = timePicker.date
        medication?.selectedDaysOfWeek = selectedDays
        
        delegate?.didEditMedication()
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func selectDaily() {
        selectedDays = DayOfWeek.allCases
        daysOfWeekTableView.reloadData()
    }
    
    @objc private func deselectAll() {
        selectedDays.removeAll()
        daysOfWeekTableView.reloadData()
    }
}

extension EditMedicationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DayOfWeek.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let day = DayOfWeek.allCases[indexPath.row]
        cell.textLabel?.text = day.rawValue.capitalized
        cell.accessoryType = selectedDays.contains(day) ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let day = DayOfWeek.allCases[indexPath.row]
        if !selectedDays.contains(day) {
            selectedDays.append(day)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let day = DayOfWeek.allCases[indexPath.row]
        if let index = selectedDays.firstIndex(of: day) {
            selectedDays.remove(at: index)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

