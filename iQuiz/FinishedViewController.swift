//
//  FinishedViewController.swift
//  iQuiz
//
//  Created by Arvin Hakakian on 5/5/25.
//

import UIKit

class FinishedViewController: UIViewController {
    private let quiz: Quiz
    private let score: Int
    
    private let titleLabel = UILabel()
    private let scoreLabel = UILabel()
    private let nextButton = UIButton(type: .system)
    
    init(quiz: Quiz, score: Int) {
        self.quiz = quiz
        self.score = score
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSwipeGestures()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = quiz.title
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.boldSystemFont(ofSize: 28)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.text = getFeedbackText()
        view.addSubview(titleLabel)
        
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.font = UIFont.systemFont(ofSize: 22)
        scoreLabel.textAlignment = .center
        scoreLabel.text = "Your score: \(score) of \(quiz.questions.count) correct"
        view.addSubview(scoreLabel)
        
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.setTitle("Finish", for: .normal)
        nextButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        nextButton.backgroundColor = .systemBlue
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.layer.cornerRadius = 10
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        view.addSubview(nextButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 48),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            scoreLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            scoreLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            scoreLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            nextButton.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 48),
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: 200),
            nextButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Back",
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
    }
    
    private func getFeedbackText() -> String {
        let percentage = Double(score) / Double(quiz.questions.count)
        
        if percentage == 1.0 {
            return "Perfect! 🎉"
        } else if percentage >= 0.75 {
            return "Great job! 🌟"
        } else if percentage >= 0.5 {
            return "Good effort! 👍"
        } else if percentage >= 0.25 {
            return "Not bad! 🤔"
        } else {
            return "Better luck next time! 📚"
        }
    }
    
    @objc private func nextTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc private func backTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    private func setupSwipeGestures() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(nextTapped))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(backTapped))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
    }
} 