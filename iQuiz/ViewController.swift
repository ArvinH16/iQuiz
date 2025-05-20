//
//  ViewController.swift
//  iQuiz
//
//  Created by Arvin Hakakian on 5/5/25.
//

import UIKit

struct Question {
    let text: String
    let options: [String]
    let correctAnswerIndex: Int
}

struct Quiz {
    let title: String
    let description: String
    let icon: String
    var questions: [Question]
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let tableView = UITableView()
    private let userDefaults = UserDefaults.standard
    private let hasSeenSwipeGuideKey = "hasSeenSwipeGuide"
    private let refreshControl = UIRefreshControl()
    private var timer: Timer?
    
    private var quizzes: [Quiz] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        loadQuizData()
        setupRefreshTimer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupRefreshTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    private func setupNavigationBar() {
        title = "iQuiz"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let settingsButton = UIBarButtonItem(
            image: UIImage(systemName: "gear"),
            style: .plain,
            target: self,
            action: #selector(settingsTapped)
        )
        navigationItem.rightBarButtonItem = settingsButton
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(QuizTableViewCell.self, forCellReuseIdentifier: "QuizCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup pull to refresh
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func loadQuizData() {
        // First try to load from local storage
        if let savedQuizzes = QuizDataStore.shared.loadQuizzes() {
            self.quizzes = QuizDataStore.shared.convertToAppQuizzes(savedQuizzes)
            self.tableView.reloadData()
        } else {
            // Use the default quizzes if no saved data
            self.quizzes = defaultQuizzes
            self.tableView.reloadData()
        }
        
        // Only try to refresh from network if we're online
        if NetworkManager.shared.isConnected {
            let interval = SettingsManager.shared.refreshInterval
            if QuizDataStore.shared.shouldRefresh(interval: interval) {
                refreshData()
            }
        }
    }
    
    private func setupRefreshTimer() {
        // Cancel any existing timer
        timer?.invalidate()
        
        // Set up a new timer if auto-refresh is enabled
        let interval = SettingsManager.shared.refreshInterval
        if interval > 0 {
            timer = Timer.scheduledTimer(
                timeInterval: TimeInterval(interval * 60),
                target: self,
                selector: #selector(refreshData),
                userInfo: nil,
                repeats: true
            )
        }
    }
    
    @objc private func refreshData() {
        if !NetworkManager.shared.isConnected {
            // Show no network alert
            let alert = UIAlertController(
                title: "No Network Connection",
                message: "You are currently offline. Please check your internet connection and try again.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            refreshControl.endRefreshing()
            return
        }
        
        NetworkManager.shared.downloadQuizData(from: SettingsManager.shared.apiUrl) { [weak self] result in
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
                
                switch result {
                case .success(let downloadedQuizzes):
                    // Save the quizzes
                    QuizDataStore.shared.saveQuizzes(downloadedQuizzes)
                    
                    // Update the UI
                    self?.quizzes = QuizDataStore.shared.convertToAppQuizzes(downloadedQuizzes)
                    self?.tableView.reloadData()
                    
                case .failure(let error):
                    print("Failed to download quizzes: \(error)")
                    // Show error alert if this wasn't a background refresh
                    if self?.refreshControl.isRefreshing ?? false {
                        let alert = UIAlertController(
                            title: "Download Failed",
                            message: "Failed to download quiz data: \(error.localizedDescription)",
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(alert, animated: true)
                    }
                }
            }
        }
    }
    
    @objc private func settingsTapped() {
        let settingsVC = SettingsViewController()
        settingsVC.onDataRefreshed = { [weak self] in
            self?.loadQuizData()
            self?.setupRefreshTimer()
        }
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quizzes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuizCell", for: indexPath) as! QuizTableViewCell
        let quiz = quizzes[indexPath.row]
        cell.configure(with: quiz)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedQuiz = quizzes[indexPath.row]
        
        if !selectedQuiz.questions.isEmpty {
            if !userDefaults.bool(forKey: hasSeenSwipeGuideKey) {
                showSwipeGuide(for: selectedQuiz)
            } else {
                navigateToQuiz(selectedQuiz)
            }
        }
    }
    
    private func showSwipeGuide(for quiz: Quiz) {
        let guideView = SwipeGuideView()
        guideView.translatesAutoresizingMaskIntoConstraints = false
        guideView.onClose = { [weak self] in
            UIView.animate(withDuration: 0.3, animations: {
                guideView.alpha = 0
            }) { _ in
                guideView.removeFromSuperview()
                self?.userDefaults.setValue(true, forKey: self?.hasSeenSwipeGuideKey ?? "")
                self?.navigateToQuiz(quiz)
            }
        }
        
        view.addSubview(guideView)
        guideView.alpha = 0
        
        NSLayoutConstraint.activate([
            guideView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            guideView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            guideView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
        ])
        
        UIView.animate(withDuration: 0.3) {
            guideView.alpha = 1
        }
    }
    
    private func navigateToQuiz(_ quiz: Quiz) {
        let questionVC = QuestionViewController(quiz: quiz, questionIndex: 0, score: 0)
        navigationController?.pushViewController(questionVC, animated: true)
    }
    
    // Default quizzes to use if no network data is available
    private let defaultQuizzes: [Quiz] = [
        Quiz(title: "Mathematics", 
            description: "Test your math skills", 
            icon: "number.circle",
            questions: [
                Question(text: "What is 2+2?", options: ["3", "4", "5"], correctAnswerIndex: 1),
                Question(text: "What is 7×8?", options: ["54", "56", "58"], correctAnswerIndex: 1),
                Question(text: "What is the square root of 9?", options: ["3", "4", "9"], correctAnswerIndex: 0)
            ]),
        Quiz(title: "Marvel Super Heroes", 
            description: "How well do you know Marvel?", 
            icon: "bolt.circle",
            questions: [
                Question(text: "Who is Iron Man?", options: ["Tony Stark", "Steve Rogers", "Bruce Banner"], correctAnswerIndex: 0),
                Question(text: "What is Captain America's shield made of?", options: ["Steel", "Adamantium", "Vibranium"], correctAnswerIndex: 2),
                Question(text: "Who is Thor's brother?", options: ["Odin", "Loki", "Heimdall"], correctAnswerIndex: 1)
            ]),
        Quiz(title: "Science", 
            description: "Quiz on scientific facts", 
            icon: "atom",
            questions: [
                Question(text: "What is the chemical symbol for water?", options: ["WA", "H2O", "W"], correctAnswerIndex: 1),
                Question(text: "What planet is known as the Red Planet?", options: ["Venus", "Mars", "Jupiter"], correctAnswerIndex: 1),
                Question(text: "What is the hardest natural substance on Earth?", options: ["Diamond", "Platinum", "Gold"], correctAnswerIndex: 0)
            ])
    ]
}

class QuizTableViewCell: UITableViewCell {
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(iconImageView)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .systemBlue
        
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        
        contentView.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = .darkGray
        
        NSLayoutConstraint.activate([
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(with quiz: Quiz) {
        titleLabel.text = quiz.title
        descriptionLabel.text = quiz.description
        iconImageView.image = UIImage(systemName: quiz.icon)
    }
}

