//
//  QuestionViewController.swift
//  iQuiz
//
//  Created by Arvin Hakakian on 5/5/25.
//

import UIKit

class QuestionViewController: UIViewController {
    private let quiz: Quiz
    private let questionIndex: Int
    private var score: Int
    private var selectedAnswerIndex: Int?
    
    private let questionLabel = UILabel()
    private let optionsStackView = UIStackView()
    private let submitButton = UIButton(type: .system)
    
    init(quiz: Quiz, questionIndex: Int, score: Int) {
        self.quiz = quiz
        self.questionIndex = questionIndex
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
        
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        questionLabel.font = UIFont.boldSystemFont(ofSize: 22)
        questionLabel.textAlignment = .center
        questionLabel.numberOfLines = 0
        questionLabel.text = quiz.questions[questionIndex].text
        view.addSubview(questionLabel)
        
        optionsStackView.translatesAutoresizingMaskIntoConstraints = false
        optionsStackView.axis = .vertical
        optionsStackView.spacing = 16
        optionsStackView.distribution = .fillEqually
        view.addSubview(optionsStackView)
        
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.setTitle("Submit", for: .normal)
        submitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        submitButton.backgroundColor = .systemBlue
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.layer.cornerRadius = 10
        submitButton.isEnabled = false
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        view.addSubview(submitButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            questionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            questionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            optionsStackView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 32),
            optionsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            optionsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            submitButton.topAnchor.constraint(equalTo: optionsStackView.bottomAnchor, constant: 48),
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            submitButton.widthAnchor.constraint(equalToConstant: 200),
            submitButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Back",
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        
        setupOptionsButtons()
    }
    
    private func setupOptionsButtons() {
        let options = quiz.questions[questionIndex].options
        
        for (index, option) in options.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(option, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.systemBlue.cgColor
            button.layer.cornerRadius = 8
            button.tag = index
            button.heightAnchor.constraint(equalToConstant: 50).isActive = true
            button.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
            
            optionsStackView.addArrangedSubview(button)
        }
    }
    
    @objc private func optionTapped(_ sender: UIButton) {
        for case let button as UIButton in optionsStackView.arrangedSubviews {
            button.backgroundColor = .clear
            button.setTitleColor(.systemBlue, for: .normal)
        }
        
        sender.backgroundColor = .systemBlue
        sender.setTitleColor(.white, for: .normal)
        
        selectedAnswerIndex = sender.tag
        
        submitButton.isEnabled = true
    }
    
    @objc private func submitTapped() {
        guard let selectedAnswerIndex = selectedAnswerIndex else { return }
        
        let answerVC = AnswerViewController(
            quiz: quiz,
            questionIndex: questionIndex,
            score: score,
            userAnswerIndex: selectedAnswerIndex
        )
        
        navigationController?.pushViewController(answerVC, animated: true)
    }
    
    @objc private func backTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    private func setupSwipeGestures() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
    }
    
    @objc private func handleSwipeRight() {
        if let _ = selectedAnswerIndex {
            submitTapped()
        }
    }
    
    @objc private func handleSwipeLeft() {
        // Show alert to confirm abandoning quiz
        let alert = UIAlertController(
            title: "Abandon Quiz?",
            message: "Your progress will be lost. Are you sure?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Abandon", style: .destructive) { [weak self] _ in
            self?.navigationController?.popToRootViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
} 