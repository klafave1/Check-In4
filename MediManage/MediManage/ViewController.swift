import UIKit

class ViewController: UIViewController, CalendarViewDelegate, MedicationListViewControllerDelegate {
    private let calendarView = CalendarView()
    private var currentDate: Date?
    private var medicationListViewController: MedicationListViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Medication List"
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Calendar", style: .plain, target: nil, action: nil)
        
        view.backgroundColor = .white

        setupNavigationBar()
        setupCalendarView()
        showMedicationList(for: Date())
    }

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Medication List", style: .plain, target: self, action: #selector(toggleView))
    }

    private func setupCalendarView() {
        calendarView.delegate = self
        view.addSubview(calendarView)
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calendarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    func didSelectDate(_ date: Date) {
        self.currentDate = date
        showMedicationList(for: date)
    }

    private func showMedicationList(for date: Date) {
        medicationListViewController = MedicationListViewController()
        medicationListViewController?.selectedDate = date
        medicationListViewController?.delegate = self
        if let medicationListViewController = medicationListViewController {
            navigationController?.pushViewController(medicationListViewController, animated: true)
        }
    }

    @objc private func toggleView() {
        if navigationController?.topViewController is MedicationListViewController {
            navigationItem.rightBarButtonItem?.title = "Calendar"
            navigationItem.title = "MediManage"
            navigationController?.popViewController(animated: true)
        } else {
            navigationItem.rightBarButtonItem?.title = "Medication List"
            navigationItem.title = "MediManage"
            showMedicationList(for: Date())
        }
    }

    func didEditMedication() {
        if let date = currentDate {
            calendarView.reloadData()
        }
    }
}

// Sources:
// https://developer.apple.com/documentation/uikit
//https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/
