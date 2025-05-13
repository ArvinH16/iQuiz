//
//  SwipeGuideView.swift
//  iQuiz
//
//  Created by Arvin Hakakian on 5/5/25.
//

import UIKit

class SwipeGuideView: UIView {
    
    private let titleLabel = UILabel()
    private let swipeRightLabel = UILabel()
    private let swipeLeftLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    
    var onClose: (() -> Void)?
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Swipe Gestures"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        
        swipeRightLabel.translatesAutoresizingMaskIntoConstraints = false
        swipeRightLabel.text = "⟶ Swipe Right: Submit/Next"
        swipeRightLabel.font = UIFont.systemFont(ofSize: 16)
        swipeRightLabel.numberOfLines = 0
        addSubview(swipeRightLabel)
        
        swipeLeftLabel.translatesAutoresizingMaskIntoConstraints = false
        swipeLeftLabel.text = "⟵ Swipe Left: Return to topics"
        swipeLeftLabel.font = UIFont.systemFont(ofSize: 16)
        swipeLeftLabel.numberOfLines = 0
        addSubview(swipeLeftLabel)
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("Got it!", for: .normal)
        closeButton.backgroundColor = .systemBlue
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.layer.cornerRadius = 8
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            swipeRightLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            swipeRightLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            swipeRightLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            swipeLeftLabel.topAnchor.constraint(equalTo: swipeRightLabel.bottomAnchor, constant: 16),
            swipeLeftLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            swipeLeftLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            closeButton.topAnchor.constraint(equalTo: swipeLeftLabel.bottomAnchor, constant: 20),
            closeButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 120),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
            closeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }
    
    @objc private func closeTapped() {
        onClose?()
    }
} 