import UIKit

protocol MedicationListViewControllerDelegate: AnyObject {
    func didEditMedication()
}

class MedicationListViewController: UIViewController {
    var selectedDate: Date?
    weak var delegate: MedicationListViewControllerDelegate?
    
    private var medications: [Medication] = [] {
        didSet {
            filterMedicationsForSelectedDay()
        }
    }
    
    private var filteredMedications: [Medication] = []
    
    private let tableView = UITableView()
    private let noMedicationsLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Medication List"
        view.backgroundColor = .white
        
        setupTableView()
        setupNoMedicationsLabel()
        setupNavigationBar()
        loadMedications()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupNoMedicationsLabel() {
        noMedicationsLabel.text = "No upcoming medications"
        noMedicationsLabel.textAlignment = .center
        noMedicationsLabel.isHidden = true
        view.addSubview(noMedicationsLabel)
        noMedicationsLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noMedicationsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noMedicationsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addMedication))
    }
    
    @objc private func addMedication() {
        let addMedicationVC = AddMedicationViewController()
        addMedicationVC.delegate = self
        navigationController?.pushViewController(addMedicationVC, animated: true)
    }
    
    private func filterMedicationsForSelectedDay() {
        guard let selectedDate = selectedDate else { return }
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: selectedDate)
        let selectedDay = DayOfWeek.allCases[weekday - 1]
        
        filteredMedications = medications.filter { medication in
            if !medication.selectedDaysOfWeek.isEmpty {
                return medication.selectedDaysOfWeek.contains(selectedDay)
            }
            return false
        }
        
        noMedicationsLabel.isHidden = !filteredMedications.isEmpty
        tableView.reloadData()
    }
    
    private func saveMedications() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(medications) {
            UserDefaults.standard.set(encoded, forKey: "medications")
        }
    }
    
    private func loadMedications() {
        if let savedData = UserDefaults.standard.data(forKey: "medications"),
           let loadedMedications = try? JSONDecoder().decode([Medication].self, from: savedData) {
            medications = loadedMedications
            filterMedicationsForSelectedDay()
        }
    }
}

extension MedicationListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMedications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let medication = filteredMedications[indexPath.row]
        cell.textLabel?.text = medication.name
        return cell
    }
}

extension MedicationListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            self.deleteMedication(at: indexPath)
            completionHandler(true)
        }
        deleteAction.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    private func deleteMedication(at indexPath: IndexPath) {
        medications.remove(at: indexPath.row)
        saveMedications()
        filterMedicationsForSelectedDay()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let medication = filteredMedications[indexPath.row]
        showEditMedicationViewController(with: medication)
    }
    
    private func showEditMedicationViewController(with medication: Medication) {
        let editMedicationVC = EditMedicationViewController()
        editMedicationVC.medication = medication
        editMedicationVC.delegate = self
        navigationController?.pushViewController(editMedicationVC, animated: true)
    }
}

extension MedicationListViewController: AddMedicationDelegate {
    func didAddMedication(_ medication: Medication) {
        medications.append(medication)
        saveMedications()
        filterMedicationsForSelectedDay()
    }
}

extension MedicationListViewController: EditMedicationDelegate {
    func didEditMedication() {
        delegate?.didEditMedication()
    }
}

// Sources:
//https://developer.apple.com/documentation/uikit/uitableview
//https://developer.apple.com/documentation/foundation/jsonencoder
//https://programmingwithswift.com/uitableviewcell-swipe-actions-with-swift/
//https://developer.apple.com/documentation/swiftdata/adding-and-editing-persistent-data-in-your-app"
//https://developer.apple.com/documentation/uikit/uibarbuttonitem
//https://developer.apple.com/documentation/uikit/uinavigationitem
