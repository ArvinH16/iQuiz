//
//  AnswerViewController.swift
//  iQuiz
//
//  Created by Arvin Hakakian on 5/5/25.
//

import UIKit

class AnswerViewController: UIViewController {
    private let quiz: Quiz
    private let questionIndex: Int
    private var score: Int
    private let userAnswerIndex: Int
    
    // UI Elements
    private let questionLabel = UILabel()
    private let resultLabel = UILabel()
    private let correctAnswerLabel = UILabel()
    private let nextButton = UIButton(type: .system)
    
    init(quiz: Quiz, questionIndex: Int, score: Int, userAnswerIndex: Int) {
        self.quiz = quiz
        self.questionIndex = questionIndex
        self.score = score
        self.userAnswerIndex = userAnswerIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSwipeGestures()
        evaluateAnswer()
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
        
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        resultLabel.font = UIFont.boldSystemFont(ofSize: 28)
        resultLabel.textAlignment = .center
        view.addSubview(resultLabel)
        
        correctAnswerLabel.translatesAutoresizingMaskIntoConstraints = false
        correctAnswerLabel.font = UIFont.systemFont(ofSize: 18)
        correctAnswerLabel.textAlignment = .center
        correctAnswerLabel.numberOfLines = 0
        view.addSubview(correctAnswerLabel)
        
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.setTitle("Next", for: .normal)
        nextButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        nextButton.backgroundColor = .systemBlue
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.layer.cornerRadius = 10
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        view.addSubview(nextButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            questionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            questionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            resultLabel.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 48),
            resultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            resultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            correctAnswerLabel.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 24),
            correctAnswerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            correctAnswerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            nextButton.topAnchor.constraint(equalTo: correctAnswerLabel.bottomAnchor, constant: 48),
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
    
    private func evaluateAnswer() {
        let question = quiz.questions[questionIndex]
        let correctAnswerIndex = question.correctAnswerIndex
        let isCorrect = userAnswerIndex == correctAnswerIndex
        
        if isCorrect {
            score += 1
        }
        
        resultLabel.text = isCorrect ? "Correct! 👍" : "Incorrect 😥"
        resultLabel.textColor = isCorrect ? .systemGreen : .systemRed
        
        let correctAnswer = question.options[correctAnswerIndex]
        correctAnswerLabel.text = "The correct answer is: \(correctAnswer)"
    }
    
    @objc private func nextTapped() {
        // Check if there are more questions
        if questionIndex + 1 < quiz.questions.count {
            // Go to next question
            let nextQuestionVC = QuestionViewController(
                quiz: quiz,
                questionIndex: questionIndex + 1,
                score: score
            )
            navigationController?.pushViewController(nextQuestionVC, animated: true)
        } else {
            // Go to finished screen
            let finishedVC = FinishedViewController(
                quiz: quiz,
                score: score
            )
            navigationController?.pushViewController(finishedVC, animated: true)
        }
    }
    
    @objc private func backTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    private func setupSwipeGestures() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(nextTapped))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
    }
    
    @objc private func handleSwipeLeft() {
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