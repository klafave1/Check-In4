import UIKit

protocol CalendarViewDelegate: AnyObject {
    func didSelectDate(_ date: Date)
}

class CalendarView: UIView {
    // MARK: - Properties
    private let calendar = Calendar.current
    private var currentDate: Date = Date()
    private var collectionView: UICollectionView!
    private var notesForDates: [Date: String] = [:]
    private var headerLabel: UILabel!
    
    weak var delegate: CalendarViewDelegate?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCollectionView()
        setupNavigationButtons()
        updateHeader()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup methods
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        headerLabel = UILabel()
        headerLabel.textAlignment = .center
        addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: topAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerLabel.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CalendarCell.self, forCellWithReuseIdentifier: "CalendarCell")
        
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupNavigationButtons() {
        let prevButton = UIButton(type: .system)
        prevButton.setTitle("<", for: .normal)
        prevButton.addTarget(self, action: #selector(previousMonth), for: .touchUpInside)
        
        let nextButton = UIButton(type: .system)
        nextButton.setTitle(">", for: .normal)
        nextButton.addTarget(self, action: #selector(nextMonth), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [prevButton, nextButton])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: headerLabel.topAnchor),
            stackView.trailingAnchor.constraint(equalTo: headerLabel.trailingAnchor),
            stackView.heightAnchor.constraint(equalTo: headerLabel.heightAnchor)
        ])
    }
    
    // MARK: - Button Actions
    @objc private func previousMonth() {
        currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate)!
        updateHeader()
        reloadData()
    }
    
    @objc private func nextMonth() {
        currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate)!
        updateHeader()
        reloadData()
    }
    
    private func updateHeader() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        let monthYearString = dateFormatter.string(from: currentDate)
        headerLabel.text = monthYearString
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegateFlowLayout

extension CalendarView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let range = calendar.range(of: .day, in: .month, for: currentDate) else { return 0 }
        
        let firstDayComponents = calendar.dateComponents([.year, .month], from: currentDate)
        guard let firstDayOfMonth = calendar.date(from: firstDayComponents) else { return 0 }
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        let totalDays = range.count
        let leadingEmptyCells = firstWeekday - calendar.firstWeekday
        let trailingEmptyCells = (7 - ((totalDays + leadingEmptyCells) % 7)) % 7
        
        return totalDays + leadingEmptyCells + trailingEmptyCells
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        var dateComponents = DateComponents()
        dateComponents.year = calendar.component(.year, from: currentDate)
        dateComponents.month = calendar.component(.month, from: currentDate)
        dateComponents.day = 1 // Start from the 1st day of the month
        let firstDayOfMonth = calendar.date(from: dateComponents)!
        
        let daysToAdd = indexPath.item - calendar.component(.weekday, from: firstDayOfMonth) + 1
        let date = calendar.date(byAdding: .day, value: daysToAdd, to: firstDayOfMonth)!
        
        if calendar.component(.month, from: date) == calendar.component(.month, from: currentDate) {
            cell.textLabel.text = "\(calendar.component(.day, from: date))"
        } else {
            cell.textLabel.text = ""
        }
        
        let hasNotes = notesForDates[date] != nil
        cell.backgroundColor = hasNotes ? .yellow : .white
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 7
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
        let date = calendar.date(byAdding: .day, value: indexPath.item, to: firstDayOfMonth)!
        delegate?.didSelectDate(date)
    }
}

// Sources:
// https://developer.apple.com/documentation/uikit
//https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/
//https://developer.apple.com/documentation/uikit/uicollectionview
