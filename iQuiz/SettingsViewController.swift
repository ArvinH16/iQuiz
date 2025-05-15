import UIKit

class SettingsViewController: UIViewController {
    
    private let urlLabel = UILabel()
    private let urlTextField = UITextField()
    private let checkNowButton = UIButton(type: .system)
    private let refreshLabel = UILabel()
    private let refreshSlider = UISlider()
    private let refreshValueLabel = UILabel()
    private let saveButton = UIButton(type: .system)
    
    var onDataRefreshed: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .systemBackground
        setupViews()
        loadSettings()
    }
    
    private func setupViews() {
        // URL Label
        urlLabel.text = "Data URL"
        urlLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(urlLabel)
        
        // URL TextField
        urlTextField.borderStyle = .roundedRect
        urlTextField.placeholder = "Enter URL"
        urlTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(urlTextField)
        
        // Check Now Button
        checkNowButton.setTitle("Check Now", for: .normal)
        checkNowButton.addTarget(self, action: #selector(checkNowTapped), for: .touchUpInside)
        checkNowButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(checkNowButton)
        
        // Refresh Interval Label
        refreshLabel.text = "Auto Refresh Interval (minutes)"
        refreshLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(refreshLabel)
        
        // Refresh Slider
        refreshSlider.minimumValue = 0
        refreshSlider.maximumValue = 60
        refreshSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        refreshSlider.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(refreshSlider)
        
        // Refresh Value Label
        refreshValueLabel.text = "0 (disabled)"
        refreshValueLabel.textAlignment = .center
        refreshValueLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(refreshValueLabel)
        
        // Save Button
        saveButton.setTitle("Save", for: .normal)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            urlLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            urlLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            urlLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            urlTextField.topAnchor.constraint(equalTo: urlLabel.bottomAnchor, constant: 8),
            urlTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            urlTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            checkNowButton.topAnchor.constraint(equalTo: urlTextField.bottomAnchor, constant: 16),
            checkNowButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            refreshLabel.topAnchor.constraint(equalTo: checkNowButton.bottomAnchor, constant: 30),
            refreshLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            refreshLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            refreshSlider.topAnchor.constraint(equalTo: refreshLabel.bottomAnchor, constant: 16),
            refreshSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            refreshSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            refreshValueLabel.topAnchor.constraint(equalTo: refreshSlider.bottomAnchor, constant: 8),
            refreshValueLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            saveButton.topAnchor.constraint(equalTo: refreshValueLabel.bottomAnchor, constant: 30),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func loadSettings() {
        urlTextField.text = SettingsManager.shared.apiUrl
        let interval = SettingsManager.shared.refreshInterval
        refreshSlider.value = Float(interval)
        updateRefreshLabel(interval)
    }
    
    @objc private func sliderValueChanged() {
        let value = Int(refreshSlider.value)
        updateRefreshLabel(value)
    }
    
    private func updateRefreshLabel(_ value: Int) {
        if value == 0 {
            refreshValueLabel.text = "0 (disabled)"
        } else {
            refreshValueLabel.text = "\(value) minutes"
        }
    }
    
    @objc private func saveTapped() {
        guard let url = urlTextField.text, !url.isEmpty else {
            showAlert(message: "Please enter a valid URL")
            return
        }
        
        SettingsManager.shared.apiUrl = url
        SettingsManager.shared.refreshInterval = Int(refreshSlider.value)
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func checkNowTapped() {
        guard let url = urlTextField.text, !url.isEmpty else {
            showAlert(message: "Please enter a valid URL")
            return
        }
        
        if !NetworkManager.shared.isConnected {
            showAlert(message: "No network connection available. Please check your internet connection and try again.")
            return
        }
        
        // Show loading indicator
        let loadingAlert = UIAlertController(title: nil, message: "Loading data...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating()
        loadingAlert.view.addSubview(loadingIndicator)
        present(loadingAlert, animated: true)
        
        NetworkManager.shared.downloadQuizData(from: url) { [weak self] result in
            DispatchQueue.main.async {
                loadingAlert.dismiss(animated: true) {
                    switch result {
                    case .success(let quizzes):
                        // Save the URL since it worked
                        SettingsManager.shared.apiUrl = url
                        
                        // Save the quizzes
                        QuizDataStore.shared.saveQuizzes(quizzes)
                        
                        self?.showAlert(message: "Successfully downloaded \(quizzes.count) quizzes!")
                        self?.onDataRefreshed?()
                        
                    case .failure(let error):
                        self?.showAlert(message: "Failed to download data: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
} 